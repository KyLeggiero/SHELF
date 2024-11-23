//
// test conveniences.swift
//
// Written by Ky on 2024-11-22.
// Copyright waived. No rights reserved.
//
// This file is part of SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation

import SHELF



struct SimpleObject: ShelfData, Equatable {
    let id: ShelfId
    var name: String?
    
    init(id: ShelfId) {
        self.id = id
        self.name = nil
    }
    
    init(id: ShelfId = .init(), name: String) {
        self.id = id
        self.name = name
    }
}



let difficultStrings = [
    "Z̤͔ͧ̑̓ä͖̭̈̇lͮ̒ͫǧ̗͚̚o̙̔ͮ̇͐̇",
    "اختبار النص",
    "من left اليمين to الى right اليسار",
    "a‭b‮c‭d‮e‭f‮g", // aaaaa
    "﷽﷽﷽﷽﷽﷽﷽﷽﷽﷽﷽﷽﷽﷽﷽﷽",
    "👱👱🏻👱🏼👱🏽👱🏾👱🏿",
    "🧟🧟‍♀️🧟‍♂️",
    "👨‍❤️‍💋‍👨👩‍👩‍👧‍👦🏳️‍⚧️🇵🇷",
]



extension DriveLocation {
    static func newTestLocation() -> Self {
        .explicit(path: NSTemporaryDirectory() + "/SHELF Tests/\(UUID())/.objectStore/") // URL.objectStoreDefaultDirectoryName
    }
}
