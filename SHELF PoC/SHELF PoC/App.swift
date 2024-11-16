//
// App.swift
//
// Written by Ky on 2024-11-14.
// Copyright waived. No rights reserved.
//
// This file is part of the Proof-of-Contept app for SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import SwiftUI
import SHELF



@main
struct App: SwiftUI.App {
    
    @ShelfContext
    private var shelfContext
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.shelfContext, shelfContext)
        }
    }
}
