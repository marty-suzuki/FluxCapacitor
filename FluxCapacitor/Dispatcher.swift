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
    static let shared = Dispatcher()
    
    let observerDataStore = ObserverDataStore()
    let subscriberDataStore = SubscriberDataStore()
    
    private init() {}
    
    func register<T: Storable>(_ object: T, handler: @escaping (T.DispatchValueType) -> ()) {
        observerDataStore.insert(object, handler: handler)
    }
    
    func unregister<T: Storable>(_ object: T) {
        observerDataStore[T.DispatchValueType.dispatchKey] = nil
    }
    
    public func dispatch<T: DispatchValue>(_ dispatchValue: T) {
        guard let hadnler = observerDataStore[T.dispatchKey]?.handler as? (T) -> () else { return }
        hadnler(dispatchValue)
    }
    
    public func unregisterAll() {
        observerDataStore.removeAll()
    }
}
