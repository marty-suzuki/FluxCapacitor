//
//  Storable.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

extension Storable {
    /// Initialize a store.
    ///
    /// - note: If a `Store` has already been registered in `Dispatcher`, it returns stored one.
    ///         If a `Store` is not registered, creates new instance and register it in `Dispatcher` before returns it.
    ///
    /// - returns: Self
    public static func instantiate() -> Self {
        let dispatcher = Dispatcher.shared
        let store: Self = dispatcher.objectStore.object() ?? .init()
        dispatcher.register(store)
        return store
    }

    /// Unregister itself from Dispatcher.
    public func clear() {
        Dispatcher.shared.unregister(self)
    }
}
