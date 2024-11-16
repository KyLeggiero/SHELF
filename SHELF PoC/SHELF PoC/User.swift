//
// User.swift
//
// Written by Ky on 2024-11-15.
// Copyright waived. No rights reserved.
//
// This file is part of the Proof-of-Contept app for SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation

import SHELF



struct User: ShelfData {
    let id: UUID
    var name: String = ""
    
    
    init(id: UUID) {
        self.id = id
    }
}
