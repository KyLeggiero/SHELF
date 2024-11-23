//
// InMemoryShelfSerializer.swift
//
// Written by Ky on 2024-11-22.
// Copyright waived. No rights reserved.
//
// This file is part of SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



/// The implementation of the in-memory-only SHELF location
internal final actor InMemoryShelfSerializer: ShelfSerializer {
    
    /// Stores all objects written only to memory
    private var inMemoryStore: [ShelfId : Data] = [:]
    
    
    func __readRawData(forObjectWithId id: ShelfId) async throws(Shelf.ReadError) -> Data? {
        return inMemoryStore[id]
    }
    
    func __write(rawObjectData: Data, withId id: ShelfId) async throws(Shelf.WriteError) {
        inMemoryStore[id] = rawObjectData
    }
}
