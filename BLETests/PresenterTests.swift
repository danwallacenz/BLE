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
        
        var delegate: SensorTagDelegate?
        var startWasCalled = false
        var stopWasCalled = false
        
        func start() {
            startWasCalled = true
        }
        
        func stop() {
            stopWasCalled = true
        }
    }
    
    class MockView:UIInterface {
        
        var enableStartButtonWasCalled = false
        var enableStartButtonArgument:Bool = false
        var enableStopButtonWasCalled = false
        var enableStopButtonArgument:Bool = true
        
        var displayAmbientTemperatureWasCalled = false
        var displayAmbientTemperatureArgument:Double = -88.8
        var displayInfraredTemperatureWasCalled = false
        var displayInfraredTemperatureArgument:Double = -99.9
        
        func enableStartButton(_ enable: Bool){
            enableStartButtonWasCalled = true
            enableStartButtonArgument = enable
        }
        func enableStopButton(_ enable: Bool){
            enableStopButtonWasCalled = true
            enableStopButtonArgument = enable
        }
        
        func displayAmbient(temperature: Double) {
            displayAmbientTemperatureWasCalled = true
            displayAmbientTemperatureArgument = temperature
        }
        
        func displayInfrared(temperature: Double) {
            displayInfraredTemperatureWasCalled = true
            displayInfraredTemperatureArgument = temperature
        }
    }
    
    var mockSensorTag:MockSensorTag!
    var mockView:MockView!
    var presenter:Presenter!
    
    override func setUp() {
        super.setUp()
        
        presenter = Presenter()

        mockSensorTag = MockSensorTag()
        presenter.sensorTag = mockSensorTag
        
        mockView = MockView()
        let _ = presenter.onCreate(mockView)
    }
    
    override func tearDown() {
        mockSensorTag = nil
        presenter = nil
        mockView = nil
        super.tearDown()
    }
    
    func testStart() {
        // when
        presenter.onStartButtonPressed()
        //then
        XCTAssertTrue(mockSensorTag.startWasCalled)
        XCTAssertTrue(mockView.enableStopButtonWasCalled)
        XCTAssertTrue(mockView.enableStopButtonArgument)
        XCTAssertTrue(mockView.enableStartButtonWasCalled)
        XCTAssertFalse(mockView.enableStartButtonArgument)
    }
    
    func testStop() {
        // when
        presenter.onStopButtonPressed()
        // then
        XCTAssertTrue(mockSensorTag.stopWasCalled)
        XCTAssertTrue(mockView.enableStopButtonWasCalled)
        XCTAssertFalse(mockView.enableStopButtonArgument)
        XCTAssertTrue(mockView.enableStartButtonWasCalled)
        XCTAssertTrue(mockView.enableStartButtonArgument)
    }
    
    func testOnCreate() {
        // when
        let returned = presenter.onCreate(mockView)
        // then
        XCTAssertTrue(returned === presenter)
        XCTAssertTrue(mockView === presenter.ui)
        XCTAssertTrue(mockView.enableStopButtonWasCalled)
        XCTAssertFalse(mockView.enableStopButtonArgument)
        XCTAssertNotNil(mockSensorTag.delegate)
        XCTAssertTrue(mockSensorTag.delegate as? Presenter === presenter)
    }
    
    func testOnTemperature() {
        // given
        let ambientTemp = 22.23452
        let infraredTemp = 16.76234
        let temperatures = (ambient:ambientTemp ,infrared:infraredTemp)
        // when
        presenter.on(temperature: temperatures)
        // then
        XCTAssertTrue(mockView.displayAmbientTemperatureWasCalled)
        XCTAssertEqual(mockView.displayAmbientTemperatureArgument, ambientTemp)
        XCTAssertTrue(mockView.displayInfraredTemperatureWasCalled)
        XCTAssertEqual(mockView.displayInfraredTemperatureArgument, infraredTemp)
    }
}
