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
public struct ShelfQuery<Value> {
    /// The current or initial (if box == nil) value of the state
    @usableFromInline
    var _value: Value

    /// The value's location, or nil if not yet known.
    @usableFromInline
    var _location: AnyLocation<Value>?

    /// Creates a state property that stores an initial wrapped value.
    ///
    /// You don't call this initializer directly. Instead, OpenSwiftUI
    /// calls it for you when you declare a property with the `@State`
    /// attribute and provide an initial value:
    ///
    ///     struct MyView: View {
    ///         @State private var isPlaying: Bool = false
    ///
    ///         // ...
    ///     }
    ///
    /// OpenSwiftUI initializes the state's storage only once for each
    /// container instance that you declare. In the above code, OpenSwiftUI
    /// creates `isPlaying` only the first time it initializes a particular
    /// instance of `MyView`. On the other hand, each instance of `MyView`
    /// creates a distinct instance of the state. For example, each of
    /// the views in the following ``VStack`` has its own `isPlaying` value:
    ///
    ///     var body: some View {
    ///         VStack {
    ///             MyView()
    ///             MyView()
    ///         }
    ///     }
    ///
    /// - Parameter value: An initial value to store in the state
    ///   property.
    public init(wrappedValue value: Value) {
        _value = value
        _location = nil
    }

    /// Creates a state property that stores an initial value.
    ///
    /// This initializer has the same behavior as the ``init(wrappedValue:)``
    /// initializer. See that initializer for more information.
    ///
    /// - Parameter value: An initial value to store in the state
    ///   property.
    @_alwaysEmitIntoClient
    public init(initialValue value: Value) {
        _value = value
    }

    /// The underlying value referenced by the state variable.
    ///
    /// This property provides primary access to the value's data. However, you
    /// don't typically access `wrappedValue` explicitly. Instead, you gain
    /// access to the wrapped value by referring to the property variable that
    /// you create with the `@State` attribute.
    ///
    /// In the following example, the button's label depends on the value of
    /// `isPlaying` and the button's action toggles the value of `isPlaying`.
    /// Both of these accesses implicitly access the state property's wrapped
    /// value:
    ///
    ///     struct PlayButton: View {
    ///         @State private var isPlaying: Bool = false
    ///
    ///         var body: some View {
    ///             Button(isPlaying ? "Pause" : "Play") {
    ///                 isPlaying.toggle()
    ///             }
    ///         }
    ///     }
    ///
    public var wrappedValue: Value {
        get {
            getValue(forReading: true)
        }
        nonmutating set {
            guard let _location else {
                return
            }
            _location.set(newValue, transaction: Transaction())
        }
    }

    /// A binding to the state value.
    ///
    /// Use the projected value to get a ``Binding`` to the stored value. The
    /// binding provides a two-way connection to the stored value. To access
    /// the `projectedValue`, prefix the property variable with a dollar
    /// sign (`$`).
    ///
    /// In the following example, `PlayerView` projects a binding of the state
    /// property `isPlaying` to the `PlayButton` view using `$isPlaying`. That
    /// enables the play button to both read and write the value:
    ///
    ///     struct PlayerView: View {
    ///         var episode: Episode
    ///         @State private var isPlaying: Bool = false
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                     .foregroundStyle(isPlaying ? .primary : .secondary)
    ///                 PlayButton(isPlaying: $isPlaying)
    ///             }
    ///         }
    ///     }
    ///
    public var projectedValue: Binding<Value> {
        let value = getValue(forReading: false)
        guard let _location else {
//            Log.runtimeIssues("Accessing State's value outside of being installed on a View. This will result in a constant Binding of the initial value and will not update.")
            return .constant(value)
        }
        return Binding(value: value, location: _location)
    }
}

extension ShelfQuery where Value: ExpressibleByNilLiteral {
    /// Creates a state property without an initial value.
    ///
    /// This initializer behaves like the ``init(wrappedValue:)`` initializer
    /// with an input of `nil`. See that initializer for more information.
    @inlinable
    public init() {
        self.init(wrappedValue: nil)
    }
}



extension ShelfQuery {
    private func getValue(forReading: Bool) -> Value {
        guard let _location else {
            return _value
        }
        if GraphHost.isUpdating {
            if forReading {
                _location.wasRead = true
            }
            return _value
        } else {
            return _location.get()
        }
    }
}



extension ShelfQuery: DynamicProperty {
    public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container _: _GraphValue<V>,
        fieldOffset: Int,
        inputs _: inout _GraphInputs
    ) {
        let attribute = Attribute(value: ())
        let box = StatePropertyBox<Value>(signal: WeakAttribute(attribute))
        buffer.append(box, fieldOffset: fieldOffset)
    }
}



private struct StatePropertyBox<Value>: DynamicPropertyBox {
    let signal: WeakAttribute<Void>
    var location: StoredLocation<Value>?

    typealias Property = ShelfQuery<Value>
    func destroy() {}
    mutating func reset() { location = nil }
    mutating func update(property: inout ShelfQuery<Value>, phase: _GraphInputs.Phase) -> Bool {
        let locationChanged = location == nil
        if location == nil {
            location = property._location as? StoredLocation ?? StoredLocation(
                initialValue: property._value,
                host: .currentHost,
                signal: signal
            )
        }
        let signalChanged = signal.changedValue()?.changed ?? false
        property._value = location!.updateValue
        property._location = location!
        return (signalChanged ? location!.wasRead : false) || locationChanged
    }
    func getState<V>(type _: V.Type) -> Binding<V>? {
        guard Value.self == V.self,
              let location
        else {
            return nil
        }
        let value = location.get()
        let binding = Binding(value: value, location: location)
        return binding as? Binding<V>
    }
}
