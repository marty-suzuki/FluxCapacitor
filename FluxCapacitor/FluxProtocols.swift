//
//  FluxProtocols.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/09/24.
//
//

import Foundation

// MARK: - DispatchState
public protocol DispatchState {
    associatedtype RelatedStoreType: Storable
    associatedtype RelatedActionType: Actionable
}

// MARK: - Actionable
public protocol Actionable {
    associatedtype DispatchStateType: DispatchState
}

// MARK: - Storable
public protocol Storable: class {
    associatedtype DispatchStateType: DispatchState
    init()
    func reduce(with state: DispatchStateType)
}
