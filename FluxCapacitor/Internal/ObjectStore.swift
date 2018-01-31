//
//  ObjectStore.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

final class ObjectStore {

    private let mutex = PThreadMutex()
    private var observers: [DispatchKey : AnyObject] = [:]
    
    func object<T: Storable>() -> T? {
        defer { mutex.unlock() }; mutex.lock()
        return observers[T.DispatchStateType.dispatchKey] as? T
    }
    
    func insert<T: Storable>(_ object: T) {
        defer { mutex.unlock() }; mutex.lock()
        guard observers[T.DispatchStateType.dispatchKey] == nil else { return }
        observers[T.DispatchStateType.dispatchKey] = object
    }

    func remove<T: Storable>(forType type: T.Type) {
        defer { mutex.unlock() }; mutex.lock()
        observers[T.DispatchStateType.dispatchKey] = nil
    }
    
    func removeAll() {
        defer { mutex.unlock() }; mutex.lock()
        observers.removeAll()
    }
}

