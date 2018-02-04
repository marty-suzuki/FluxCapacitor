//
//  PrimitiveValueTests.swift
//  FluxCapacitorTests
//
//  Created by marty-suzuki on 2018/02/04.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import XCTest
@testable import FluxCapacitor

class PrimitiveValueTests: XCTestCase {
    var variable: Variable<Int>!

    override func setUp() {
        super.setUp()

        self.variable = Variable<Int>(0)
    }
    
    func testInitialValue() {
        XCTAssertEqual(variable.value, 0)
    }

    func testObserveAndClean() {
        let expect = expectation(description: "will change value")

        let dust = variable.observe { value in
            XCTAssertEqual(value, 2)
            XCTAssertEqual(self.variable.value, 2)
            expect.fulfill()
        }

        variable.value = 2

        waitForExpectations(timeout: 0.1, handler: nil)

        dust.clean()
    }

    func testCleanCalledBeforeNofity() {
        variable.observe { _ in
            XCTFail()
        }
        .clean()

        variable.value = 1
    }

    func testObserveAndDustButer() {
        let expect = expectation(description: "will change value")

        var dustBuster = DustBuster()

        variable.observe { value in
            XCTAssertEqual(value, 4)
            XCTAssertEqual(self.variable.value, 4)
            expect.fulfill()
        }
        .cleaned(by: dustBuster)

        variable.value = 4

        waitForExpectations(timeout: 0.1, handler: nil)

        dustBuster = DustBuster()
    }
    
    func testDustBusterReleasedBeforeNofity() {
        var dustBuster = DustBuster()

        variable.observe { _ in
            XCTFail()
        }
        .cleaned(by: dustBuster)

        dustBuster = DustBuster()

        variable.value = 3
    }

    func testInitialValueAsConstant() {
        let constant = Constant(variable)
        XCTAssertEqual(constant.value, 0)
    }

    func testObserveAndCleanAsConstant() {
        let constant = Constant(variable)
        let expect = expectation(description: "will change value")

        let dust = constant.observe { value in
            XCTAssertEqual(value, 2)
            XCTAssertEqual(constant.value, 2)
            expect.fulfill()
        }

        variable.value = 2

        waitForExpectations(timeout: 0.1, handler: nil)

        dust.clean()
    }

    func testCleanCalledBeforeNofityAsConstant() {
        let constant = Constant(variable)
        constant.observe { _ in
            XCTFail()
        }
        .clean()

        variable.value = 1
    }

    func testObserveAndDustButerAsConstant() {
        let constant = Constant(variable)
        let expect = expectation(description: "will change value")

        var dustBuster = DustBuster()

        constant.observe { value in
            XCTAssertEqual(value, 4)
            XCTAssertEqual(constant.value, 4)
            expect.fulfill()
        }
        .cleaned(by: dustBuster)

        variable.value = 4

        waitForExpectations(timeout: 0.1, handler: nil)

        dustBuster = DustBuster()
    }

    func testDustBusterReleasedBeforeNofityAsConstant() {
        let constant = Constant(variable)
        var dustBuster = DustBuster()

        constant.observe { _ in
            XCTFail()
        }
        .cleaned(by: dustBuster)

        dustBuster = DustBuster()

        variable.value = 3
    }
}
