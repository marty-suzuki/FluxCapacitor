//
//  Dust.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/31.
//
//

import Foundation

/// Represents an Action-based dust.
public final class Dust {
    private var cleanAction: (() -> ())?
    private let mutex = PThreadMutex()
    
    private(set) var isCleaned: Bool = false
    
    init(_ cleanAction: @escaping () -> ()) {
        self.cleanAction = cleanAction
    }

    /// Adds `self` to `dustBuster`.
    ///
    /// - parameter buster: `DustBuster` to add `self` to.
    public func cleaned(by buster: DustBuster) {
        buster.insert(self)
    }

    /// If it is not cleaned, execute cancel action.
    public func clean() {
        defer { mutex.unlock() }; mutex.lock()
        guard let action = cleanAction, !isCleaned else { return }
        cleanAction = nil
        isCleaned = true
        action()
    }
}

/// Cleaner that cleans added dusts on `deinit`.
public final class DustBuster {
    private var dusts: [Dust] = []
    private let mutex = PThreadMutex()

    /// Initializer
    public init() {}
    
    deinit {
        clean()
    }
    
    func insert(_ dust: Dust) {
        defer { mutex.unlock() }; mutex.lock()
        dusts.append(dust)
    }

    /// Cleans all dusts that containing.
    public func clean() {
        defer { mutex.unlock() };  mutex.lock()
        dusts.forEach { $0.clean() }
        dusts.removeAll(keepingCapacity: false)
    }
}
