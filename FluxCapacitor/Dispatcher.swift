//
//  Dispatcher.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

// MARK: - Dispatcher
public final class Dispatcher {
    public static let shared = Dispatcher()

    let objectStore = ObjectStore()

    private init() {}

    public func unregisterAll() {
        objectStore.removeAll()
    }
    
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
