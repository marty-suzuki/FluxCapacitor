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
    init(dispatcher: Dispatcher)
}

extension Storable {
    static var dispatcher: Dispatcher { return .shared }
    
    public static func instantiate() -> Self {
        return dispatcher.observerDataStore.object(for: Self.self) ?? .init(dispatcher: dispatcher)
    }
    
    public var dispatcher: Dispatcher { return .shared }
    
    public func unregister() {
        dispatcher.unregister(self)
    }
    
    public func register(handler: @escaping (DispatchValueType) -> Void) {
        dispatcher.register(self) { [weak self] value in
            handler(value)
            guard let me = self else { return }
            let subscribers = me.dispatcher.subscriberDataStore.subscribers(of: me)
            subscribers.forEach {
                guard let h = $0.handler as? (DispatchValueType) -> () else { return }
                h(value)
            }
        }
    }
    
    public func subscribe(changed handler: @escaping (DispatchValueType) -> ()) -> Dust {
        let key = DispatchValueType.dispatchKey
        let token = dispatcher.subscriberDataStore.insert(self, handler: handler).token
        return Dust { [weak self] in
            self?.dispatcher.subscriberDataStore.removeSubscriber(ofKey: key, andToken: token)
        }
    }
}
