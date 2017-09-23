//
//  PThreadMutex.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/09/24.
//
//

import Foundation

final class PThreadMutex {
    private var mutex: pthread_mutex_t = pthread_mutex_t()
    
    init() {
        pthread_mutex_init(&mutex, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    func unlock() {
        pthread_mutex_unlock(&mutex)
    }
}
