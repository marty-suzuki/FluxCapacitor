//
//  Dispatcher.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

public protocol DispatchValue {}

extension DispatchValue {
    static var dispatchKey: String {
        return String(describing: self)
    }
}

public final class Dispatcher {
    public static let shared = Dispatcher()
    
    let dataStore = DataStore()
    
    private init() {}
    
    public func register<T: Storable>(_ object: T, handler: @escaping (T.DispatchValueType) -> ()) {
        dataStore.insert(object, handler: handler)
    }
    
    public func unregister<T: Storable>(_ object: T) {
        dataStore[T.DispatchValueType.dispatchKey] = nil
    }
    
    public func dispatch<T: DispatchValue>(_ dispatchValue: T) {
        guard let hadnler = dataStore[T.dispatchKey]?.handler as? (T) -> () else { return }
        hadnler(dispatchValue)
    }
    
    public func unregisterAll() {
        dataStore.removeAll()
    }
}
