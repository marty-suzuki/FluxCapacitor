//
//  DispatchState.extension.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/09/24.
//
//

import Foundation

struct DispatchKey: Hashable {
    fileprivate let value: String

    var hashValue: Int {
        return value.hashValue
    }
}

extension DispatchKey {
    static func == (lhs: DispatchKey, rhs: DispatchKey) -> Bool {
        return lhs.value == rhs.value
    }
}

extension DispatchState {
    static var dispatchKey: DispatchKey {
        return DispatchKey(value: String(describing: self))
    }
}
