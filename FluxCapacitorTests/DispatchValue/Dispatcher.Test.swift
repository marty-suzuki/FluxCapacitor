//
//  Dispatcher.Test.swift
//  FluxCapacitorTests
//
//  Created by marty-suzuki on 2017/08/07.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor

extension Dispatcher {
    enum Test: DispatchValue {
        typealias RelatedStoreType = TestStore
        typealias RelatedActionType = TestAction
        
        case removeNumber(Int)
        case addNumber(Int)
        case removeAllNumbers
    }
}
