//
// LocalDriveShelfSerializer.swift
//
// Written by Ky on 2024-11-22.
// Copyright waived. No rights reserved.
//
// This file is part of SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



/// The star of the show, humbly working the magic from the booth behind the scenes. This handles persisting/retrieving objects to/from the store on the machine's local drive
internal struct LocalDriveShelfSerializer {
    private let resolvedLocation: URL
    private let fileManager: FileManager
}



internal extension LocalDriveShelfSerializer {
    init(location: DriveLocation, fileManager: FileManager = .default) {
        self.init(
            resolvedLocation: .init(location),
            fileManager: fileManager
        )
    }
}



extension LocalDriveShelfSerializer: ShelfSerializer {
    
    func __readRawData(forObjectWithId id: ShelfId) async throws(Shelf.ReadError) -> Data? {
        let objectFileUrl = objectUrl(for: id)
        let objectFilePath = objectFileUrl.path(percentEncoded: false)
        
        guard fileManager.fileExists(atPath: objectFilePath) else {
            return nil
        }
        
        do {
            return try Data(contentsOf: objectFileUrl)
        }
        catch {
            throw .couldNotReadObjectFile(cause: error)
        }
    }
    
    
    mutating func __write(rawObjectData: Data, withId id: ShelfId) async throws(Shelf.WriteError) {
        // TODO: Batch into queued transactions
        
        let objectFileUrl = objectUrl(for: id)
        
        do {
            try fileManager.createDirectory(at: objectFileUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
            try rawObjectData.write(to: objectFileUrl, options: [.atomic])
        }
        catch {
            throw .couldNotWriteObjectFile(cause: error)
        }
    }
    
    
    mutating func __update(objectWithId id: ShelfId, newRawData: Data) async throws(Shelf.WriteError) {
        try await __write(rawObjectData: newRawData, withId: id)
    }
    
    
    mutating func delete(objectWithId id: ShelfId) async throws(Shelf.DeleteError) {
        // TODO: Batch into queued transactions
        
        let objectFileUrl = objectUrl(for: id)
        
        do {
            try fileManager.removeItem(at: objectFileUrl)
        }
        catch {
            throw .couldNotDeleteObjectFile(cause: error)
        }
    }
    
    
    
    func __deleteAllData() throws(Shelf.WholeDatabaseDeleteError) {
        do {
            try fileManager.removeItem(at: resolvedLocation)
        }
        catch {
            throw .couldNotPerformApprovedDeletion(cause: error)
        }
    }
}



// MARK: - Object finding

private extension LocalDriveShelfSerializer {
    
    /// The URL where the object with the given ID would be inside this store
    ///
    /// - Parameter id: The ID of the object which would be at the returned URL
    /// - Returns: The URL where the object with the given ID would be
    func objectUrl(for id: ShelfId) -> URL {
        let strings = id.shelfStrings
        
        return resolvedLocation
            .appending(components: strings.topFolderName, strings.subFolderName)
            .appending(component: strings.objectName)
    }
}
