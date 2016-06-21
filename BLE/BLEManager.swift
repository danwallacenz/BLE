//
//  BLEManager.swift
//  BLE
//
//  Created by Daniel Wallace on 21/06/16.
//  Copyright © 2016 Daniel Wallace. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let SENSOR_TAG_NAME = "SensorTag"
    var centralManager:CBCentralManager!
    var sensorTag: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func start(){
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func stop(){
        centralManager.stopScan()
    }
    
    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("centralManagerDidUpdateState")
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        guard let peripheralName = advertisementData["kCBAdvDataLocalName"] as? String else {return}
        print("discovered: \(peripheralName) : \(peripheral.identifier.UUIDString)")
        
        if peripheralName.containsString(SENSOR_TAG_NAME) {
            // save a reference to the sensor tag
            sensorTag = peripheral
            sensorTag!.delegate = self
            // Request a connection to the peripheral
            print("attempting to connect to Sensor Tag")
            centralManager.connectPeripheral(sensorTag!, options: nil)
            stop()
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("didConnectPeripheral")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didFailToConnectPeripheral")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didDisconnectPeripheral")
    }
    
    // MARK: CBPeripheralDelegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("didDiscoverServices")
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("didDiscoverCharacteristicsForService")
        
        if let chracteristics = service.characteristics {
            for characteristic in chracteristics {
                print("\(characteristic.UUID)")
            }
        }
    }
}
