//
//  SubscriberDataStore.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/31.
//
//

import Foundation

final class SubscriberDataStore {
    struct Subscriber {
        let token: String
        let handler: Any
    }
    
    private let mutex = PThreadMutex()
    private var _subscribers: [String : [Subscriber]] = [:]

    func insert<T: Storable>(_ store: T, handler: @escaping (T.DispatchValueType) -> ()) -> Subscriber {
        mutex.lock()
        let uuid = UUID().uuidString
        let subscriber = Subscriber(token: uuid, handler: handler)
        let oneOfList = _subscribers[T.DispatchValueType.dispatchKey] ?? []
        let newList = [oneOfList, [subscriber]].flatMap { $0 }
        _subscribers[T.DispatchValueType.dispatchKey] = newList
        mutex.unlock()
        return subscriber
    }
    
    func subscribers<T: Storable>(of store: T) -> [Subscriber] {
        return _subscribers[T.DispatchValueType.dispatchKey] ?? []
    }
    
    func removeSubscriber(ofKey key: String, andToken token: String) {
        defer { mutex.unlock() }; mutex.lock()
        guard
            let oneOfList = _subscribers[key],
            let index = oneOfList.index(where: { $0.token == token })
        else { return }
        var newList = oneOfList
        newList.remove(at: index)
        _subscribers[key] = newList
    }
    
    func removeAll() {
        defer { mutex.unlock() }; mutex.lock()
        _subscribers.removeAll()
    }
}

