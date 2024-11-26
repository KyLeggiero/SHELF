//
// Shelf.swift
//
// Written by Ky on 2024-11-22.
// Copyright waived. No rights reserved.
//
// This file is part of SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation

import SerializationTools
import SimpleLogging



/// This is the primary interface to SHELF if you're not using platform sugar like SHELFPlusSwiftUI
public struct Shelf {
    
    /// Configuration details for this SHELF store
    let config: ShelfConfig
    
    /// Handles the actual (de)serialization of the database and its objects
    private var serializer: ShelfSerializer
    
    
    /// Initializes or connects to a SHELF store.
    ///
    /// - Attention: This is `fileprivate` because it powers other initilizers. I shouldn't be used directly.
    ///
    /// - Parameters:
    ///   - config:                  Configuration details for this SHELF store
    ///
    ///   - preferLoadingPastConfig: Whether SHELF should prefer loading any configuration it can from the found pre-existing object store.
    ///                              If true, the only config that will be acknowledged is whatever is just enough to find the existing object store's config, and that existing config will be read in.
    ///                              If false, the given config will take higher priority over the existing one.
    ///                              If true and there is no pre-existing config, then the in-memory one will be used (obviously).
    ///
    ///   - serializer:              A SHELF serializer appropriate for this config
    ///
    /// - Throws: An ``InitError`` if initialization fails
    fileprivate init(config: ShelfConfig, preferLoadingPastConfig: Bool, serializer: ShelfSerializer) async throws(InitError) {
        if preferLoadingPastConfig {
            do {
                self.config = try await .init(loadingFrom: config.storageLocation) ?? config
                self.serializer = await config.createNewSerializer()
            }
            catch {
                log(error: error, "Failed to load existing config. Backing up to provided config")
                self.config = config
                self.serializer = serializer
            }
        }
        else {
            self.config = config
            self.serializer = serializer
        }
    }
}



// MARK: - Initialization

public extension Shelf {
    
    /// Initializes or connects to a SHELF store
    ///
    /// - Parameters:
    ///   - config:                  Configuration details for this SHELF store
    ///
    ///   - preferLoadingPastConfig: _optional_ - Whether SHELF should prefer loading any configuration it can from the found pre-existing object store.
    ///                              If true, the only config that will be acknowledged is whatever is just enough to find the existing object store's config, and that existing config will be read in.
    ///                              If false, the given config will take higher priority over the existing one.
    ///                              If true and there is no pre-existing config, then the in-memory one will be used (obviously).
    ///                              Defaults to `true`
    ///
    /// - Throws: An ``InitError`` if initialization fails
    init(config: ShelfConfig, preferLoadingPastConfig: Bool = true) async throws (InitError) {
        try await self.init(
            config: config,
            preferLoadingPastConfig: preferLoadingPastConfig,
            serializer: await config.createNewSerializer()
        )
    }
    
    
    /// Initializes or connects to a SHELF store.
    ///
    /// If a store is found at the given location, this uses that one.
    ///
    /// If no store could be found at that location, a new one is created with a new configuration.
    ///
    /// - Parameter location: Where the SHELF store is located
    ///
    /// - Throws: An ``InitError`` if initialization fails
    init(at location: ShelfConfig.StorageLocation) async throws (InitError) {
        try await self.init(
            config: .init(storageLocation: location),
            preferLoadingPastConfig: true
        )
    }
    
    
    /// Initializes or connects to a SHELF store
    ///
    /// - Parameter paradigm: The semantic paradigm describing the reason you want to create a new SHELF
    ///
    /// - Throws: An ``InitError`` if initialization fails
    init(paradigm: ShelfConfig.NewConfigParadigm) async throws(InitError) {
        try await self.init(
            config: .init(paradigm: paradigm),
            preferLoadingPastConfig: paradigm.preferLoadingPastConfig
        )
    }
    
    
    /// Initializes or connects to a SHELF store
    ///
    /// This assumes a golden path: that this executable is a typical application, the SHELF store is where applications typically store their data, the SHELF database & config file have the default name, etc.
    ///
    /// - Throws: An ``InitError`` if initialization fails
    init() async throws(InitError) {
        try await self.init(at: .defaultOnDrive)
    }
}



public extension Shelf {
    enum InitError: Error {
        //case couldNotLoadExistingConfig
    }
}



// MARK: - API: Querying

public extension Shelf {
    
    /// Attempts to find the SHELF object with the given ID
    ///
    /// - Parameter id: The ID of the object to search for
    /// - Returns: The object with the given ID, or `nil` if no such object is present in the store
    /// - Throws: A ``ReadError`` if any error occurs while attempting to read the object from the store
    func object<Object: ShelfData>(withId id: ShelfId) async throws(ReadError) -> Object? {
        try await serializer.read(objectWithId: id)
    }
}



public extension Shelf {
    
    /// An error which might occur while attempting to read from the object store
    enum ReadError: Error {
        
        /// The object file exists, but can't be read from
        /// - Parameter cause: The OS-given reason why the file could not be read
        case couldNotReadObjectFile(cause: Error)
        
        /// The object file exists, and SHELF sucessfully read the raw data inside it, but that data couldn't be deserialized into the in-memory object itself
        /// - Parameter cause: The OS-given reason why the object could not be parsed
        case couldNotParseObject(cause: Error)
    }
}



// MARK: - API: Persisting

public extension Shelf {
    
    /// Attempts to save the given SHELF object to the store
    ///
    /// - Parameter object: The object to save
    /// - Throws: A ``WriteError`` if any error occurs while attempting to write the object to the store
    mutating func save<Object: ShelfData>(_ object: Object) async throws(WriteError) {
        try await serializer.write(object: object)
    }
}



public extension Shelf {
    
    /// An error which might occur while attempting to write to the object store
    enum WriteError: Error {
        
        /// The object was successfully converted into raw data, but that data could not be written to the object file
        /// - Parameter cause: The OS-given reason why the file could not be written
        case couldNotWriteObjectFile(cause: Error)
        
        /// The in-memory representation of the object could not be converted into the raw data that would be written to the store
        /// - Parameter cause: The OS-given reason why the object could not be serialized
        case couldNotSerializeObject(cause: Error)
    }
}



public extension Shelf {
    /// Thrown when there was a failed attempt to delete the whole database
    enum WholeDatabaseDeleteError: Error {
        
        /// The dev attempted to delete the database, but failed to properly pass the whole-database delete token
        case badDeleteToken
        
        /// The dev properly passed the whole-database delete token, and SHELF tried to perform that deletion, but the deletion failed for some reason outside the control of SHELF
        /// - Parameter cause: The reason the deletion failed (often a platform error)
        case couldNotPerformApprovedDeletion(cause: Error)
    }
}



// MARK: - Deleting

public extension Shelf {
    
    /// Attempts to delete the a SHELF object from the store with the given ID.
    ///
    /// - Parameters:
    ///   - id: The ID of the object to delete
    ///
    /// - Throws: A ``DeleteError`` if any error occurs while attempting to delete the object from the store
    mutating func delete(objectWithId staleId: ShelfId) async throws(DeleteError) {
        try await serializer.delete(objectWithId: staleId)
    }
}



public extension Shelf {
    
    /// An error which might occur while attempting to delete an object from the object store
    enum DeleteError: Error {
        
        /// The object's file was successfully found in the database, but that object file could not be deleted
        /// - Parameter cause: The OS-given reason why the file could not be deleted
        case couldNotDeleteObjectFile(cause: Error)
    }
}



// MARK: - Nuking

public extension Shelf {
    
    /// 🛑 Deletes all the data in this SHELF object store database.
    ///
    /// This function returns a token for database deletion.
    /// You must then call `imSure(oath:)` on that token, and pass it the following oath as a static string in your source code file:
    /// ```
    /// I understand that this action will permanently delete all data in this SHELF database.
    /// This cannot be undone once I pass this token back.
    /// I vow that this decision is the most correct for this situation, and there is no better choice I could make in this moment.
    ///
    /// Black sphinx of quartz, judge my vow.
    /// ```
    ///
    /// After you've given your oath to the token, pass the token back to `nuke_whole_database_DANGEROUS(token:)` within 60 seconds.
    ///
    /// If you've properly created the token with this function, said the oath to the token, and passed the token back within 60 seconds, then the database will be deleted.
    ///
    /// - Attention: If you do not complete this ritual perfectly the first time, a `.fault`-level message will be logged describing the reason the ritual failed
    @MainActor
    mutating func nuke_whole_database_DANGEROUS() throws(WholeDatabaseDeleteError) -> WholeDatabaseDeletionConfirmationToken {
        try serializer.delete_all_data__DANGEROUS__()
    }
    
    
    /// 🛑 Deletes all the data in this SHELF object store database.
    ///
    /// See the documentation for `delete_all_data__DANGEROUS__()` to understand how this function works.
    @MainActor
    mutating func nuke_whole_database_DANGEROUS(token: WholeDatabaseDeletionConfirmationToken) throws(WholeDatabaseDeleteError) {
        try serializer.delete_all_data__DANGEROUS__(token: token)
    }
}
