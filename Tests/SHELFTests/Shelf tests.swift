//
// Shelf tests.swift
//
// Written by Ky on 2024-11-22.
// Copyright waived. No rights reserved.
//
// This file is part of SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation
import Testing

import SHELF



struct InMemoryTests {
    
    @Test(arguments: [
        .onlyInMemory,
        .local(.newTestLocation()),
    ] as [ShelfConfig.StorageLocation])
    func writeAndReadSimpleData(storageLocation: ShelfConfig.StorageLocation) async throws {
        let shelf = await Shelf(config: .init(id: .init(), storageLocation: storageLocation))
        
        let testObject_arc = SimpleObject(name: "Arc")
        try await shelf.save(testObject_arc)
        var retrieved: SimpleObject = try #require(try await shelf.object(withId: testObject_arc.id))
        #expect(retrieved == testObject_arc)
        
        let testObject_chris = SimpleObject(name: "Chris")
        try await shelf.save(testObject_chris)
        retrieved = try #require(try await shelf.object(withId: testObject_chris.id))
        #expect(retrieved == testObject_chris)
        
        for difficultString in difficultStrings {
            let testObject = SimpleObject(name: difficultString)
            try await shelf.save(testObject)
            retrieved = try #require(try await shelf.object(withId: testObject.id))
            #expect(retrieved == testObject)
        }
        
        for i in (0...10_000) {
            let testObject = SimpleObject(name: "Generated Test Object #\(i)")
            try await shelf.save(testObject)
            retrieved = try #require(try await shelf.object(withId: testObject.id))
            #expect(retrieved == testObject)
        }
    }
}
