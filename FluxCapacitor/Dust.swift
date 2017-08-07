//
//  Dust.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/31.
//
//

import Foundation

public final class Dust {
    private var cleanAction: (() -> ())?
    private var mutex: pthread_mutex_t = pthread_mutex_t()
    
    private(set) var isCleaned: Bool = false
    
    init(_ cleanAction: @escaping () -> ()) {
        self.cleanAction = cleanAction
        pthread_mutex_init(&mutex, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    public func cleaned(by buster: DustBuster) {
        buster.insert(self)
    }
    
    public func clean() {
        defer { pthread_mutex_unlock(&mutex) }
        pthread_mutex_lock(&mutex)
        guard let action = cleanAction, !isCleaned else { return }
        cleanAction = nil
        isCleaned = true
        action()
    }
}

public final class DustBuster {
    private var dusts: [Dust] = []
    private var mutex: pthread_mutex_t = pthread_mutex_t()
    
    public init() {
        pthread_mutex_init(&mutex, nil)
    }
    
    deinit {
        lock()
        dusts.forEach { $0.clean() }
        dusts.removeAll(keepingCapacity: false)
        unlock()
        pthread_mutex_destroy(&mutex)
    }
    
    func insert(_ dust: Dust) {
        lock()
        dusts.append(dust)
        unlock()
    }
    
    private func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    private func unlock() {
        pthread_mutex_unlock(&mutex)
    }
}
