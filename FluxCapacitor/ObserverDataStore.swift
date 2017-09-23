//
//  ObserverDataStore.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

final class ObserverDataStore {
    struct Observer {
        private(set) var object: AnyObject?
        let handler: Any
    }
    
    private let mutex = PThreadMutex()
    private var observers: [String : Observer] = [:]
    
    subscript(_ key: String) -> Observer? {
        set {
            mutex.lock()
            observers[key] = newValue
            mutex.unlock()
        }
        get {
            mutex.lock()
            let observer = observers[key]
            mutex.unlock()
            return observer
        }
    }
    
    func object<T: Storable>(for type: T.Type) -> T? {
        return self[T.DispatchValueType.dispatchKey]?.object as? T
    }
    
    func handler<T: Storable>(for type: T.Type) -> (T.DispatchValueType) -> () {
        guard let hadnler = self[T.DispatchValueType.dispatchKey]?.handler as? (T.DispatchValueType) -> () else {
            _ = T.instantiate()
            return handler(for: T.self)
        }
        return hadnler
    }
    
    func insert<T: Storable>(_ object: T, handler: @escaping (T.DispatchValueType) -> ()) {
        defer { mutex.unlock() }; mutex.lock()
        guard observers[T.DispatchValueType.dispatchKey] == nil else { return }
        observers[T.DispatchValueType.dispatchKey] = Observer(object: object, handler: handler)
    }
    
    func removeAll() {
        defer { mutex.unlock() }; mutex.lock()
        observers.removeAll()
    }
}

