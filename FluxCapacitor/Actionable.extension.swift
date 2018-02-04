//
//  Actionable.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

extension Actionable {
    /// Invokes a dispatch with dispatchState.
    public func invoke(_ dispatchState: DispatchStateType) {
        Dispatcher.shared.dispatch(dispatchState)
    }
}
