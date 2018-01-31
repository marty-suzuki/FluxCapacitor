//
//  Actionable.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

extension Actionable {
    public func invoke(_ dispatchValue: DispatchStateType) {
        Dispatcher.shared.dispatch(dispatchValue)
    }
}
