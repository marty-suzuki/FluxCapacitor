//
//  Storable.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

public protocol Storable: class {
    associatedtype DispatchValueType: DispatchValue
    init()
}

extension Storable {
    static var dispatcher: Dispatcher { return .shared }
    
    public static func instantiate() -> Self {
        return dispatcher.registrationDataStore.object(for: Self.self) ?? .init()
    }
    
    public var dispatcher: Dispatcher { return .shared }
    
    public func unregister() {
        dispatcher.unregister(self)
    }
    
    public func register(handler: @escaping (DispatchValueType) -> Void) {
        dispatcher.register(self, handler: handler)
    }
    
    public func subscribe(in object: AnyObject, handler: () -> ()) {
        dispatcher.subscribe(in: object, handler: handler)
    }
}
