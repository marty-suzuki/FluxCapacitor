//
//  ActionTests.swift
//  FluxCapacitor
//
//  Created by marty-suzuki on 2017/08/07.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import XCTest
@testable import FluxCapacitor

class ActionTests: XCTestCase {
    var action: TestAction!
    var store: TestStore!
    
    override func setUp() {
        super.setUp()
        
        store = TestStore.instantiate()
        action = TestAction()
    }
    
    override func tearDown() {
        super.tearDown()
        
        store.numbers.value.removeAll()
    }
    
    func testAddNumber() {
        action.invoke(.addNumber(1))
        XCTAssertEqual(store.numbers.value.first, 1)
    }
    
    func testRemoveNumber() {
        action.invoke(.addNumber(2))
        XCTAssertEqual(store.numbers.value.first, 2)
        
        action.invoke(.removeNumber(2))
        XCTAssertEqual(store.numbers.value.first, nil)
    }
    
    func testRemoveAll() {
        action.invoke(.addNumber(1))
        action.invoke(.addNumber(2))
        action.invoke(.addNumber(3))
        XCTAssertEqual(store.numbers.value.count, 3)
        
        action.invoke(.removeAllNumbers)
        XCTAssert(store.numbers.value.isEmpty)
    }
}
