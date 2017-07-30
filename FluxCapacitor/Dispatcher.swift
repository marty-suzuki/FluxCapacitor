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
    
    let registrationDataStore = DataStore()
    //let subscriptionDataStore = DataStore()
    
    private init() {}
    
    func register<T: Storable>(_ object: T, handler: @escaping (T.DispatchValueType) -> ()) {
        registrationDataStore.insert(object, handler: handler)
    }
    
    func unregister<T: Storable>(_ object: T) {
        registrationDataStore[T.DispatchValueType.dispatchKey] = nil
    }
    
    public func dispatch<T: DispatchValue>(_ dispatchValue: T) {
        guard let hadnler = registrationDataStore[T.dispatchKey]?.handler as? (T) -> () else { return }
        hadnler(dispatchValue)
    }
    
    public func unregisterAll() {
        registrationDataStore.removeAll()
    }
    
    func subscribe(in object: AnyObject, handler: () -> ()) {
        
    }
}
