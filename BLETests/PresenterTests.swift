//
//  PresenterTests.swift
//  BLE
//
//  Created by Daniel Wallace on 22/06/16.
//  Copyright © 2016 Daniel Wallace. All rights reserved.
//

import XCTest
@testable import BLE

class PresenterTests: XCTestCase {
    
    class MockSensorTag:SensorTag {
        var startWasCalled = false
        var stopWasCalled = false
        func start() {
            startWasCalled = true
        }
        func stop() {
            stopWasCalled = true
        }
    }
    
    
    
    var mockSensorTag:MockSensorTag!
    var presenter:Presenter!
    
    override func setUp() {
        super.setUp()
        mockSensorTag = MockSensorTag()
        presenter = Presenter()
        presenter.sensorTag = mockSensorTag
    }
    
    override func tearDown() {
        mockSensorTag = nil
        presenter = nil
        super.tearDown()
    }
    
    func testStart() {
        presenter.onStartButtonPressed()
        XCTAssertTrue(mockSensorTag.startWasCalled)
    }
    
    func testStop() {
        presenter.onStopButtonPressed()
        XCTAssertTrue(mockSensorTag.stopWasCalled)
    }
}
