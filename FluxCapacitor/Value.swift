//
//  Value.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2018/02/03.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

// MARK: ValueState

public protocol ValueState {}
public enum Immutable: ValueState {}
public enum Mutable: ValueState {}


// MARK: - Value

public final class Value<State: ValueState, Element> {

    private let wrapper: Wrapper<Element>
    private let notifyCenter: ValueNotifyCenter<Element>

    private init(wrapper: Wrapper<Element>, notifyCenter: ValueNotifyCenter<Element>) {
        self.wrapper = wrapper
        self.notifyCenter = notifyCenter
    }

    public func observe(on excuteQueue: ExecuteQueue = .current, changes: @escaping (Element) -> Void) -> Dust {
        return notifyCenter.addObserver(excuteQueue: excuteQueue, changes: changes)
    }
}

// MARK: - Constant

public typealias Constant<Element> = Value<Immutable, Element>

extension Value where State == Immutable {
    public var value: Element {
        return wrapper.value
    }

    public convenience init(_ variable: Variable<Element>) {
        self.init(wrapper: variable.wrapper, notifyCenter: variable.notifyCenter)
    }
}


// MARK: - Variable

public typealias Variable<Element> = Value<Mutable, Element>

extension Value where State == Mutable {
    public var value: Element {
        get {
            return wrapper.value
        }
        set {
            wrapper.value = newValue
            notifyCenter.notifyChanges(value: newValue)
        }
    }

    public convenience init(_ value: Element) {
        self.init(wrapper: .init(value), notifyCenter: .init())
    }
}
