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



/// This is the primary interface to SHELF if you're not using platform sugar like SHELFPlusSwiftUI
public struct Shelf {
    
    /// Configuration details for this SHELF store
    let config: ShelfConfig
    
    private let serializer: ShelfSerializer
}



public extension Shelf {
    
    /// References a SHELF store at the given drive location
    ///
    /// - Parameter driveLocation: The location on the drive where this SHELF store is persisted
    init(config: ShelfConfig) async {
        self.init(
            config: config,
            serializer: await config.createNewSerializer()
        )
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
    func save<Object: ShelfData>(_ object: Object) async throws(WriteError) {
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
