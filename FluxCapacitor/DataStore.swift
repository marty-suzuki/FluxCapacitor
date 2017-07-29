//
//  DataStore.swift
//  Pods
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

final class DataStore {
    struct Observer {
        weak private(set) var object: AnyObject?
        let handler: Any
    }
    
    private var mutex: pthread_mutex_t = pthread_mutex_t()
    private var observers: [String : Observer] = [:]
    
    init() {
        pthread_mutex_init(&mutex, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    subscript(_ key: String) -> Observer? {
        set {
            lock()
            observers[key] = newValue
            unlock()
        }
        get {
            lock()
            let observer = observers[key]
            unlock()
            return observer
        }
    }
    
    func object<T: Storable>(for type: T.Type) -> T? {
        return self[T.DispatchValueType.dispatchKey]?.object as? T
    }
    
    func insert<T: Storable>(_ object: T, handler: @escaping (T.DispatchValueType) -> ()) {
        defer { unlock() }
        lock()
        guard observers[T.DispatchValueType.dispatchKey] == nil else { return }
        observers[T.DispatchValueType.dispatchKey] = Observer(object: object, handler: handler)
    }
    
    func removeAll() {
        lock()
        observers.removeAll()
        unlock()
    }
    
    private func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    private func unlock() {
        pthread_mutex_unlock(&mutex)
    }
}
