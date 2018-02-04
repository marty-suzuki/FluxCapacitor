//
//  TestStore.swift
//  FluxCapacitorTests
//
//  Created by marty-suzuki on 2017/08/07.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor

class TestStore: Storable {
    typealias DispatchStateType = Dispatcher.Test

    let numbers = Variable<[Int]>([])
    
    required init() {}

    func reduce(with state: Dispatcher.Test) {
        switch state {
        case .addNumber(let value):
            numbers.value.append(value)
        case .removeNumber(let value):
            numbers.value = numbers.value.filter { $0 != value }
        case .removeAllNumbers:
            numbers.value.removeAll()
        }
    }
}
