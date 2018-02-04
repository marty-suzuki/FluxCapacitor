//
//  PrimitiveValue.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2018/02/03.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

// MARK: ValueTrait

/// Represents traits for PrimitiveValue.
public protocol ValueTrait {}


// MARK: - PrimitiveValue

/// Be able to observe changes of a value.
public final class PrimitiveValue<Trait: ValueTrait, Element> {
    private let _value: MutexValue<Element>
    private let notifyCenter: ValueNotifyCenter<Element>

    private init(value: MutexValue<Element>, notifyCenter: ValueNotifyCenter<Element>) {
        self._value = value
        self.notifyCenter = notifyCenter
    }

    /// Observe changes of a value on specified queue.
    ///
    /// - note: Default excuteQueue is `ExecuteQueue.current`.
    ///
    /// - parameter excuteQueue: Queue to notify changes on.
    /// - parameter ignoreFirst: Ignore immediate value.
    /// - parameter changes: Changes handler of a value.
    ///
    /// - returns: A `Dust`
    public func observe(on excuteQueue: ExecuteQueue = .current,
                        ignoreFirst: Bool = false,
                        changes: @escaping (Element) -> Void) -> Dust {
        if !ignoreFirst {
            changes(_value.rawValue)
        }
        return notifyCenter.addObserver(excuteQueue: excuteQueue, changes: changes)
    }
}


// MARK: - Constant

/// Represents immutable trait.
public enum ImmutableTrait: ValueTrait {}

/// Represents a immutable value based on `PrimitiveValue`.
public typealias Constant<Element> = PrimitiveValue<ImmutableTrait, Element>

extension PrimitiveValue where Trait == ImmutableTrait {
    /// getter
    public var value: Element {
        return _value.rawValue
    }

    /// Initialize as `PrimitiveValue<ImmutableTrait, Element>` from `PrimitiveValue<MutableTrait, Element>`.
    ///
    /// - parameter variable: Take over states of a variable.
    public convenience init(_ variable: Variable<Element>) {
        self.init(value: variable._value, notifyCenter: variable.notifyCenter)
    }
}


// MARK: - Variable

/// Represents mutable trait.
public enum MutableTrait: ValueTrait {}

/// Represents a mutable value based on `PrimitiveValue`.
public typealias Variable<Element> = PrimitiveValue<MutableTrait, Element>

extension PrimitiveValue where Trait == MutableTrait {
    /// getter / setter of a value. If you set newValue, notify changes.
    public var value: Element {
        get {
            return _value.rawValue
        }
        set {
            _value.rawValue = newValue
            notifyCenter.notifyChanges(value: newValue)
        }
    }

    /// Initialize as `PrimitiveValue<MutableTrait, Element>` with a given initial value.
    ///
    /// - parameter value: Initial value.
    public convenience init(_ value: Element) {
        self.init(value: .init(value), notifyCenter: .init())
    }
}
