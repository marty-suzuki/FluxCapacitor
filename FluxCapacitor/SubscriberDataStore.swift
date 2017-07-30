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
    
    private var mutex: pthread_mutex_t = pthread_mutex_t()
    private var _subscribers: [String : [Subscriber]] = [:]
    
    init() {
        pthread_mutex_init(&mutex, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    func insert<T: Storable>(_ store: T, handler: @escaping (T.DispatchValueType) -> ()) -> Subscriber {
        lock()
        let uuid = UUID().uuidString
        let subscriber = Subscriber(token: uuid, handler: handler)
        let oneOfList = _subscribers[T.DispatchValueType.dispatchKey] ?? []
        let newList = [oneOfList, [subscriber]].flatMap { $0 }
        _subscribers[T.DispatchValueType.dispatchKey] = newList
        unlock()
        return subscriber
    }
    
    func subscribers<T: Storable>(of store: T) -> [Subscriber] {
        return _subscribers[T.DispatchValueType.dispatchKey] ?? []
    }
    
    func removeSubscriber(ofKey key: String, andToken token: String) {
        defer { unlock() }
        lock()
        guard
            let oneOfList = _subscribers[key],
            let index = oneOfList.index(where: { $0.token == token })
        else { return }
        var newList = oneOfList
        newList.remove(at: index)
        _subscribers[key] = newList
    }
    
    func removeAll() {
        lock()
        _subscribers.removeAll()
        unlock()
    }
    
    private func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    private func unlock() {
        pthread_mutex_unlock(&mutex)
    }
}
