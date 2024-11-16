//
// ShelfQuery.swift
//
// Written by Ky on 2024-11-14.
// Copyright waived. No rights reserved.
//
// This file is part of SHELF, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation
@preconcurrency import SafePointer
#if canImport(SwiftUI)
import SwiftUI
#endif



@propertyWrapper
public struct ShelfQuery<WrappedValue: ShelfData>: Sendable {
//    public var wrappedValue: WrappedValue
//
//    public init(wrappedValue: WrappedValue) {
//        self.wrappedValue = wrappedValue
//    }
//    
//    
//    public init() {
//        self.init(wrappedValue: .init(id: UUID()))
//    }
    
//    private var _value: WrappedValue
    private var _storage: SafeMutablePointer<WrappedValue>
    
    public init(wrappedValue: WrappedValue) {
//        self._value = wrappedValue
        self._storage = SafeMutablePointer(to: wrappedValue)
    }
    
    public init() {
        self.init(wrappedValue: .init(id: .init()))
    }
    
    public var wrappedValue: WrappedValue {
        get { return _storage.pointee /*?? _value*/ }
        nonmutating set { _storage.pointee = newValue }
    }
    
    
    
    #if canImport(SwiftUI)
    public var projectedValue: Binding<WrappedValue> {
        .init {
            self.wrappedValue
        } set: { newValue, _ in
            self.wrappedValue.update(to: newValue)
        }
    }
    #endif
}
