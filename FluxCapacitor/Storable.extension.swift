//
//  Storable.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

extension Storable {
    public static func instantiate() -> Self {
        let dispatcher = Dispatcher.shared
        let store: Self = dispatcher.objectStore.object() ?? .init()
        dispatcher.register(store)
        return store
    }

    public func clear() {
        Dispatcher.shared.unregister(self)
    }
}
