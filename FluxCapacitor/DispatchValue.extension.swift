//
//  DispatchValue.extension.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/09/24.
//
//

import Foundation

extension DispatchValue {
    static var dispatchKey: String {
        return String(describing: self)
    }
}
