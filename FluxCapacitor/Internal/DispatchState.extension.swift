//
//  DispatchState.extension.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/09/24.
//
//

import Foundation

// MARK: - DispatchStateKey

/// Represents a key of DispatchState.
struct DispatchStateKey: Hashable {
    fileprivate let key: String

    var hashValue: Int {
        return key.hashValue
    }

    static func == (lhs: DispatchStateKey, rhs: DispatchStateKey) -> Bool {
        return lhs.key == rhs.key
    }
}


// MARK: - DispatchState extension

extension DispatchState {
    /// Represents a specified key.
    static var key: DispatchStateKey {
        return DispatchStateKey(key: String(describing: self))
    }
}
