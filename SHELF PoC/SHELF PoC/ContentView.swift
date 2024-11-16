//
// ContentView.swift
//
// Written by Ky on 2024-11-14.
// Copyright waived. No rights reserved.
//
// This file is part of the Proof-of-Contept app for SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import SwiftUI

import SHELF



struct ContentView: View {
    
    @ShelfQuery
    private var user: User
    
    @Environment(\.shelfContext)
    private var shelfContext
    
    var body: some View {
        VStack {
            Text("Hello, \(user.name)!")
                .font(.largeTitle)
            
            TextField("Change my name", text: $user.name)
            
            Button("Forget me!") {
//                shelfContext.delete(user)
            }
        }
    }
}



#Preview {
    ContentView()
}
