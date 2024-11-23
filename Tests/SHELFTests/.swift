
        let testObject_chris = SimpleObject(name: "Chris")
        try await shelf.save(testObject_chris)
        retrieved = try #require(try await shelf.object(withId: testObject_chris.id))
        #expect(retrieved == testObject_chris)