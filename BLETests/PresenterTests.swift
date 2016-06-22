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
    
    class View:UIInterface {
        
        var enableStartButtonWasCalled = false
        var enableStartButtonArgument:Bool = false
        var enableStopButtonWasCalled = false
        var enableStopButtonArgument:Bool = true
        
        func enableStartButton(_ enable: Bool){
            enableStartButtonWasCalled = true
            enableStartButtonArgument = enable
        }
        func enableStopButton(_ enable: Bool){
            enableStopButtonWasCalled = true
            enableStopButtonArgument = enable
        }
    }
    
    var mockSensorTag:MockSensorTag!
    var mockView:View!
    var presenter:Presenter!
    
    override func setUp() {
        super.setUp()
        presenter = Presenter()

        mockSensorTag = MockSensorTag()
        presenter.sensorTag = mockSensorTag
        
        mockView = View()
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
    
    func testOnCreate() {
        let returned = presenter.onCreate(mockView)
        XCTAssertTrue(returned === presenter)
        XCTAssertTrue(mockView === presenter.ui)
        XCTAssertTrue(mockView.enableStopButtonWasCalled)
        XCTAssertFalse(mockView.enableStopButtonArgument)
    }
}
