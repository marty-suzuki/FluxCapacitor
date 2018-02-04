//
//  Dispatcher.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

/// Represents Flux-Dispatcher.
///
/// - seealso: [flux-concepts Dispatcher](https://github.com/facebook/flux/tree/master/examples/flux-concepts#dispatcher)
public final class Dispatcher {
    let objectStore = ObjectStore()

    private init() {}

    func register<T: Storable>(_ object: T) {
        objectStore.insert(object)
    }

    func unregister<T: Storable>(_ object: T) {
        objectStore.remove(forType: T.self)
    }

    func dispatch<T: DispatchState>(_ dispatchState: T) {
        typealias U = T.RelatedStoreType.DispatchStateType
        guard let state = dispatchState as? U else { return }

        let store = T.RelatedStoreType.instantiate()
        store.reduce(with: state)
    }
}

extension Dispatcher {
    /// Represents single Dispatcher.
    public static let shared = Dispatcher()

    /// Unregister all Stores dispatching.
    public func unregisterAll() {
        objectStore.removeAll()
    }
}
