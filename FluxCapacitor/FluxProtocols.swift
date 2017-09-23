//
//  FluxProtocols.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/09/24.
//
//

import Foundation

// MARK: - DispatchValue
public protocol DispatchValue {
    associatedtype RelatedStoreType: Storable
    associatedtype RelatedActionType: Actionable
}

// MARK: - Actionable
public protocol Actionable {
    associatedtype DispatchValueType: DispatchValue
    var dispatcher: Dispatcher { get }
}

// MARK: - Storable
public protocol Storable: class {
    associatedtype DispatchValueType: DispatchValue
    var dispatcher: Dispatcher { get }
    init(dispatcher: Dispatcher)
}
