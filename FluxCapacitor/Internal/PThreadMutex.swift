//
//  PThreadMutex.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/09/24.
//
//

import Foundation

/// A pthread_mutex wrapper
final class PThreadMutex {
    private let mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
    
    init() {
        pthread_mutex_init(mutex, nil)
    }
    
    deinit {
        pthread_mutex_destroy(mutex)
        mutex.deinitialize()
        mutex.deallocate(capacity: 1)
    }
    
    func lock() {
        pthread_mutex_lock(mutex)
    }
    
    func unlock() {
        pthread_mutex_unlock(mutex)
    }
}
