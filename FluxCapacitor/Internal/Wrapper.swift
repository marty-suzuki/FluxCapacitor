//
//  Wrapper.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2018/02/04.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

final class Wrapper<Element> {

    private var _value: Element
    private let mutex = PThreadMutex()

    var value: Element {
        get {
            return _value
        }
        set {
            defer { mutex.unlock() }; mutex.lock()
            _value = newValue
        }
    }

    init(_ value: Element) {
        self._value = value
    }
}
