//
//  Actionable.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

extension Actionable {
    public var dispatcher: Dispatcher { return .shared }
    
    public func invoke(_ dispatchValue: DispatchValueType) {
        dispatcher.dispatch(dispatchValue)
    }
}
