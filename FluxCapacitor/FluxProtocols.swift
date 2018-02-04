//
//  FluxProtocols.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/09/24.
//
//

import Foundation

// MARK: - DispatchState

/// Bridging Store and Action.
public protocol DispatchState {
    associatedtype RelatedStoreType: Storable
    associatedtype RelatedActionType: Actionable
}


// MARK: - Actionable

/// Represents Flux-Action
///
/// - seealso: [flux-concepts Actions](https://github.com/facebook/flux/tree/master/examples/flux-concepts#actions)
public protocol Actionable {
    associatedtype DispatchStateType: DispatchState
}


// MARK: - Storable

/// Represents Flux-Store
///
/// - seealso: [flux-concepts Store](https://github.com/facebook/flux/tree/master/examples/flux-concepts#store)
public protocol Storable: class {
    associatedtype DispatchStateType: DispatchState
    init()

    /// `Dispatcher` calls it if specified state dispatched.
    ///
    /// - parameter state: A `DispatchState` that dispatched from `Dispatcher`.
    func reduce(with state: DispatchStateType)
}
