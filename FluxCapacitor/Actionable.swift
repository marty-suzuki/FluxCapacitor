//
//  Actionable.swift
//  Pods
//
//  Created by marty-suzuki on 2017/07/29.
//
//

import Foundation

public protocol Actionable {
    associatedtype DispatchValueType: DispatchValue
    var dispatcher: Dispatcher { get }
}

extension Actionable {
    public func invoke(_ dispatchValue: DispatchValueType) {
        dispatcher.dispatch(dispatchValue)
    }
}
