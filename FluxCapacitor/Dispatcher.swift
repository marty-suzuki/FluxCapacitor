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
    static let shared = Dispatcher()

    let observerDataStore = ObserverDataStore()
    let subscriberDataStore = SubscriberDataStore()

    private init() {}

    public func unregisterAll() {
        observerDataStore.removeAll()
    }
    
    func register<T: Storable>(_ object: T, handler: @escaping (T.DispatchValueType) -> ()) {
        observerDataStore.insert(object, handler: handler)
    }

    func unregister<T: Storable>(_ object: T) {
        observerDataStore[T.DispatchValueType.dispatchKey] = nil
    }

    func dispatch<T: DispatchValue>(_ dispatchValue: T) {
        let handler = observerDataStore.handler(for: T.RelatedStoreType.self)
        guard let value = dispatchValue as? T.RelatedStoreType.DispatchValueType else { return }
        handler(value)
    }
}
