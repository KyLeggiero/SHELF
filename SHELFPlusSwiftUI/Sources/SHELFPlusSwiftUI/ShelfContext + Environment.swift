//
// ShelfContext + Environment.swift
//
// Written by Ky on 2024-11-14.
// Copyright waived. No rights reserved.
//
// This file is part of SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import SwiftUI




private extension ShelfContext {
    struct Key: SwiftUI.EnvironmentKey {
        static let defaultValue = ShelfContext.Guts(config: .init(paradigm: .devNeverExplicitlySetContext))
    }
}



@available(macOS 10.15, *)
public extension EnvironmentValues {
    /// Carry the SHELF context through your SwiftUI app by using this environment variable!
    ///
    /// ```swift
    /// ContentView()
    ///     .environment(\.shelfContext, myAppSpecficiShelfContext)
    /// ```
    /// ```swift
    /// struct MySubview: View {
    ///     @Environment(\.shelfContext)
    ///     private var shelfContext
    ///
    ///     // ...
    /// ```
    var shelfContext: ShelfContext.Guts {
        get { self[ShelfContext.Key.self] }
        set { self[ShelfContext.Key.self] = newValue }
    }
}
