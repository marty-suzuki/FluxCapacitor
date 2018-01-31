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
    private let mutex = PThreadMutex()
    
    private(set) var isCleaned: Bool = false
    
    init(_ cleanAction: @escaping () -> ()) {
        self.cleanAction = cleanAction
    }
    
    public func cleaned(by buster: DustBuster) {
        buster.insert(self)
    }
    
    public func clean() {
        defer { mutex.unlock() }; mutex.lock()
        guard let action = cleanAction, !isCleaned else { return }
        cleanAction = nil
        isCleaned = true
        action()
    }
}

public final class DustBuster {
    private var dusts: [Dust] = []
    private let mutex = PThreadMutex()
    
    public init() {}
    
    deinit {
        defer { mutex.unlock() };  mutex.lock()
        dusts.forEach { $0.clean() }
        dusts.removeAll(keepingCapacity: false)
    }
    
    func insert(_ dust: Dust) {
        defer { mutex.unlock() }; mutex.lock()
        dusts.append(dust)
    }
}
