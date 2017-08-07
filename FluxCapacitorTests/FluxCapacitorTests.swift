//
//  FluxCapacitorTests.swift
//  FluxCapacitorTests
//
//  Created by marty-suzuki on 2017/08/07.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import XCTest
@testable import FluxCapacitor

class FluxCapacitorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let action = TestAction()

        let store = TestStore.instantiate()
        XCTAssertEqual(store.numbers, [])

        action.invoke(.addNumber(1))
        XCTAssertEqual(store.numbers.first, 1)

        action.invoke(.addNumber(2))
        action.invoke(.addNumber(3))
        XCTAssertEqual(store.numbers.count, 3)

        action.invoke(.removeNumber(1))
        XCTAssertEqual(store.numbers.first, 2)

        action.invoke(.removeAllNumbers)
        XCTAssertEqual(store.numbers, [])

        let store2 = TestStore.instantiate()
        XCTAssertEqual(store.numbers, store2.numbers)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
