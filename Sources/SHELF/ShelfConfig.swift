//
// ShelfConfig.swift
//
// Written by Ky on 2024-11-14.
// Copyright waived. No rights reserved.
//
// This file is part of SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation

import UuidTools



/// Configuration for SHELF
///
/// Use this when you need to tweak the behvior of SHELF
///
/// - SeeAlso: ``ShelfContext``
public struct ShelfConfig: ShelfData, Sendable {
    
    /// This configuration's ID
    public var id: UUID
    
    /// Where the object store lives
    public var storageLocation: StorageLocation
    
    
    public init(id: UUID) {
        self.init(
            id: id,
            storageLocation: .onlyInMemory)
    }
    
    init(id: UUID, storageLocation: StorageLocation) {
        self.id = id
        self.storageLocation = storageLocation
    }
}



public extension __ShelfContextProtocol {
    typealias Config = ShelfConfig
}



// MARK: - Constant(s)

public extension ShelfConfig {
    
    /// The ID that a SHELF config uses by default.
    ///
    /// You can specify one if you want to, but if you don't, it'll always be this.
    ///
    /// This isn't a specific magical or special UUID or anthing like that; We literally generated it while writing this file.
    static let defaultId = UUID(uuid: (0x45,0xF2,0x3C,0x5F, 0x24,0x68, 0x46,0x4D, 0x97,0x6F, 0x4C,0x1D,0xD2,0x0D,0xEB,0x19))
}



// MARK: - Subtypes

public extension ShelfConfig {
    enum StorageLocation: Codable, Sendable {
        
        /// This location means that all the SHELF data will be sored in (and read from) memory.
        /// Any data persisted to the drive in previous runs will neither be read, nor overwritten.
        /// Changes will still occur and the in-memory database will behave exactly like a persisted one, except none of the data will be saved and future runs will not be able to access any of it.
        case onlyInMemory
        
        
        /// This location is what most people might expect: SHELF will read data from an object-storage database persisted to the drive, and all changes will be written to it.
        ///
        /// - Parameter directory: A local file url (`file:///Path/to/store/`) pointing to the directory where the object store is persisted
        case local(directory: URL)
    }
}



// MARK: - Default configs

public extension ShelfConfig {
    
    /// Create a new SHELF config, with pre-set values matching the given semantic paradigm.
    ///
    /// If you wanna set these values yourself, you should probably use initializers that let you do that instead of this one.
    /// Or don't. I'm a doc comment, not a cop.
    ///
    /// - Parameter paradigm: The semantic paradigm describing the reason you want to create a new SHELF config.
    init(paradigm: NewConfigParadigm) {
        self.init(
            id: paradigm.id,
            storageLocation: paradigm.storageLocation
        )
    }
    
    
    /// A default paradigm for why you'd want a SHELF config
    enum NewConfigParadigm {
        
        /// The golden path is the way SHELF is meant to be used
        case goldenPath
        
        /// Devs are encouraged to explicitly set a `shelfContext`. if they don't, then this paradigm applies
        case devNeverExplicitlySetContext
    }
}



private extension ShelfConfig.NewConfigParadigm {
    /// A UUID appropriate for this paradigm
    var id: UUID {
        switch self {
        case .goldenPath,
                .devNeverExplicitlySetContext:
                .init()
        }
    }
    
    
    /// The storage location that this paradigm prescribes
    var storageLocation: ShelfConfig.StorageLocation {
        switch self {
        case .goldenPath:                  .local(directory: .defaultObjectStoreDirectory)
        case .devNeverExplicitlySetContext: .onlyInMemory
        }
    }
}

