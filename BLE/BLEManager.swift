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
    
    // Light UUIDs
    let UIID_OPTICAL_SENSOR_SERVICE = "F000AA70-0451-4000-B000-000000000000"
    let UIID_OPTICAL_SENSOR_DATA    = "F000AA71-0451-4000-B000-000000000000"
    let UIID_OPTICAL_SENSOR_CONFIG  = "F000AA72-0451-4000-B000-000000000000"
    
    // Temp UUIDs
    let UUID_TEMPERATURE_SERVICE = "F000AA00-0451-4000-B000-000000000000"
    let UUID_TEMPERATURE_DATA    = "F000AA01-0451-4000-B000-000000000000"
    let UUID_TEMPERATURE_CONFIG  = "F000AA02-0451-4000-B000-000000000000"
    
    // Humidity
    let UUID_HUMIDITY_SERVICE = "F000AA20-0451-4000-B000-000000000000"
    let UUID_HUMIDITY_DATA    = "F000AA21-0451-4000-B000-000000000000"
    let UUID_HUMIDITY_CONFIG  = "F000AA22-0451-4000-B000-000000000000"
    
    
    var centralManager:CBCentralManager!
    var sensorTag: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func start(){
        print("starting scanning")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stop(){
        centralManager.stopScan()
        print("stopped scanning")
    }
    
    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber) {
        
        guard let peripheralName = advertisementData["kCBAdvDataLocalName"] as? String else {return}
        print("discovered: \(peripheralName) : \(peripheral.identifier.uuidString)")
        
        if peripheralName.contains(SENSOR_TAG_NAME) {
            // save a reference to the sensor tag
            sensorTag = peripheral
            sensorTag!.delegate = self
            // Request a connection to the peripheral
            print("attempting to connect to Sensor Tag")
            centralManager.connect(sensorTag!, options: nil)
            stop()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnectPeripheral")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: NSError?) {
        print("didFailToConnectPeripheral")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didDisconnectPeripheral")
    }
    
    // MARK: CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("didDiscoverServices")
        if let services = peripheral.services {
            for service in services {
                print("discovered service: \(service.uuid)")
                
                if service.uuid .isEqual(CBUUID(string: UUID_TEMPERATURE_SERVICE)) {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: NSError?) {
        print("didDiscoverCharacteristicsForService")
        
        if let chracteristics = service.characteristics {
            for characteristic in chracteristics {
                print("discovered characteristic: \(characteristic.uuid) for service: \(service.uuid)")
                // Temperature
                if characteristic.uuid .isEqual(CBUUID(string: UUID_TEMPERATURE_DATA)) {
                    // Enable Temperature Sensor notification
                    self.sensorTag?.setNotifyValue(true, for: characteristic)
                    print("discovered temperature data characteristic")
                }
                if characteristic.uuid .isEqual(CBUUID(string: UUID_TEMPERATURE_CONFIG)) {
                    // Enable Temperature Sensor
                    var enableValue:UInt8 = 1
                    let enableBytes = Data(bytes: UnsafePointer<UInt8>(&enableValue), count: sizeof(UInt8))

                    sensorTag?.writeValue(enableBytes, for: characteristic, type: CBCharacteristicWriteType.withResponse)

                    print("discovered temperature config characteristic")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: NSError?) {
        print("didUpdateValueForCharacteristic")
        if let error = error {
            print("error:\(error.localizedDescription)")
        } else{
        
            // extract the data from the characteristic's value property and display the value based on the characteristic type
            let data = characteristic.value
            var rawData : UInt16 = 0
            (data as NSData?)?.getBytes(&rawData, length: sizeof(UInt16));
            let lower = 0x00FF & rawData;
            let upper = rawData>>8
            print("temperature data: \(data) for characteristic: \(characteristic.uuid)")
            print("temperature lower: \(lower) upper: \(upper)")
        }
        
    }
}
