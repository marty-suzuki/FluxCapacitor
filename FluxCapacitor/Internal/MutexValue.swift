//
//  MutexValue.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2018/02/04.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

/// A value wrapper
final class MutexValue<Element> {
    private var _rawValue: Element
    private let mutex = PThreadMutex()

    var rawValue: Element {
        get {
            return _rawValue
        }
        set {
            defer { mutex.unlock() }; mutex.lock()
            _rawValue = newValue
        }
    }

    init(_ rawValue: Element) {
        self._rawValue = rawValue
    }
}
