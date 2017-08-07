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
    typealias DispatchValueType = Dispatcher.Test

    var numbers: [Int] = []
    
    let dispatcher: Dispatcher

    required init(dispatcher: Dispatcher) {
        self.dispatcher = dispatcher
        
        register { [weak self] in
            switch $0 {
            case .addNumber(let value):
                self?.numbers.append(value)
            case .removeNumber(let value):
                guard let index = self?.numbers.index(of: value) else { return }
                self?.numbers.remove(at: index)
            case .removeAllNumbers:
                self?.numbers.removeAll()
            }
        }
    }
}
