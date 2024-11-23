//
// ShelfSerializer.swift
//
// Written by Ky on 2024-11-22.
// Copyright waived. No rights reserved.
//
// This file is part of SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



/// Something whose only job is to read/write SHELF objects to/from a SHELF object store
internal protocol ShelfSerializer {
    
    /// Attempts to find the raw data of the SHELF object with the given ID.
    ///
    /// Types conforming to this protocol are required to implement this, but callers interacting with this protocol are discouraged from using it.
    /// Instead, callers should use ``read(objectWithId:)``, which deals with typechecked objects rather than raw data
    ///
    /// - Parameter id: The ID of the object to search for
    /// - Returns: The raw data of the object with the given ID, or `nil` if no such object is present in the store
    /// - Throws: A ``ReadError`` if any error occurs while attempting to read the raw data from the store
    @available(*, deprecated, renamed: "read(objectWithId:)", message: "Direct usage of this function is discouraged. Instead, use `read(objectWithId:)`, which automatically manages deserialization & identifier juggling")
    func __readRawData(forObjectWithId id: ShelfId) async throws(Shelf.ReadError) -> Data?
    
    
    /// Attempts to write the given pre-serialized SHELF object to the store.
    ///
    /// Types conforming to this protocol are required to implement this, but callers interacting with this protocol are discouraged from using it.
    /// Instead, callers should use ``write(object:)``, which deals with typechecked objects rather than raw data
    ///
    /// - Attention: The given data _**MUST**_ be a serialized `ShelfData` instance.
    ///     SHELF assumes this, and can break if that's not true.
    ///     Because of this, We recommend you **use ``write(object:)`` instead** of using this function directly.
    ///
    /// - Parameters:
    ///   - rawObjectData: The raw data content of the object to save in the store. This _**must always**_ be pre-serialized ``ShelfData``
    ///   - id:            The ID of the object to store. This will also be duplicated in the `objectData` because `objectData` _**must always**_ be serialized ``ShelfData``
    /// - Throws: A ``WriteError`` if any error occurs while attempting to write the data to the store
    @available(*, deprecated, renamed: "write(object:)", message: "Direct usage of this function is discouraged. Instead, use `write(object:)`, which automatically manages serialization & identifier juggling")
    func __write(rawObjectData: Data, withId id: ShelfId) async throws(Shelf.WriteError)
}



internal extension ShelfSerializer {
    /// Attempts to write the given SHELF object to the store.
    ///
    /// - Parameter object: The object to save in the store.
    /// - Throws: A ``WriteError`` if any error occurs while attempting to write the object from the store
    func write<Object: ShelfData>(object: Object) async throws(Shelf.WriteError) {
        let data: Data
        
        do {
            data = try object.jsonData()
        }
        catch {
            throw .couldNotSerializeObject(cause: error)
        }
        
        try await __write(rawObjectData: data, withId: object.id)
    }
    
    
    /// Attempts to find & parse the SHELF object with the given ID
    ///
    /// - Parameter id: The ID of the object to search for
    /// - Returns: The object with the given ID, or `nil` if no such object is present in the store
    /// - Throws: A ``ReadError`` if any error occurs while attempting to read the object from the store
    func read<Object: ShelfData>(objectWithId id: ShelfId) async throws(Shelf.ReadError) -> Object? {
        guard let rawData = try await __readRawData(forObjectWithId: id) else {
            return nil
        }
        
        do {
            return try Object(jsonData: rawData)
        }
        catch {
            throw .couldNotParseObject(cause: error)
        }
    }
}
