//
//  Storable.swift
//  Pods
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

public protocol Storable: class {
    associatedtype DispatchValueType: DispatchValue
    var dispatcher: Dispatcher { get }
    init(dispatcher: Dispatcher)
}

extension Storable {
    public static func make(dispatcher: Dispatcher = .shared) -> Self {
        return dispatcher.dataStore.object(for: Self.self) ?? .init(dispatcher: dispatcher)
    }
    
    public func unregister() {
        dispatcher.unregister(self)
    }
    
    public func register(handler: @escaping (DispatchValueType) -> Void) {
        dispatcher.register(self, handler: handler)
    }
}
