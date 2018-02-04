//
//  ObjectStore.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

/// Store objects that adopting `Storable` protocol.
final class ObjectStore {
    private let mutex = PThreadMutex()
    private var observers: [DispatchStateKey : AnyObject] = [:]
    
    func object<T: Storable>() -> T? {
        defer { mutex.unlock() }; mutex.lock()
        return observers[T.DispatchStateType.key] as? T
    }
    
    func insert<T: Storable>(_ object: T) {
        defer { mutex.unlock() }; mutex.lock()
        let key = T.DispatchStateType.key
        guard observers[key] == nil else { return }
        observers[key] = object
    }

    func remove<T: Storable>(forType type: T.Type) {
        defer { mutex.unlock() }; mutex.lock()
        observers[T.DispatchStateType.key] = nil
    }
    
    func removeAll() {
        defer { mutex.unlock() }; mutex.lock()
        observers.removeAll()
    }
}
