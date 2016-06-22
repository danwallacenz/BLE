//
//  BLEManager.swift
//  BLE
//
//  Created by Daniel Wallace on 21/06/16.
//  Copyright © 2016 Daniel Wallace. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, SensorTag {
    
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
    
    var delegate: SensorTagDelegate?
    
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
                    let enableBytes = Data(bytes: &enableValue, count: sizeof(UInt8))

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
            if let data = characteristic.value {
                let temperatures = temperature(from: data)
                delegate?.on(temperature: temperatures)
//                print("ambient temp is \(round(10 * temperatures.ambient) / 10))º C") // 1 decimal place
//                print("infrared temp is \(round(10 * temperatures.infrared) / 10)º C")
            }
        }
    }
    
    func temperature(from dataBytes: Data) -> (ambient: Double, infrared: Double) {
        let SENSOR_DATA_INDEX_TEMP_INFRARED  = 0
        let SENSOR_DATA_INDEX_TEMP_AMBIENT = 1
        let dataLength = dataBytes.count / 2
        var dataArray = [UInt16](repeating: 0, count: dataLength)
        (dataBytes as NSData).getBytes(&dataArray, length: dataLength * sizeof(UInt16));
        let rawAmbientTemp = dataArray[SENSOR_DATA_INDEX_TEMP_AMBIENT]
        let ambientTempInCelcius = Double(rawAmbientTemp) / 128
        let rawIRTemp = dataArray[SENSOR_DATA_INDEX_TEMP_INFRARED]
        let irTempInCelcius = Double(rawIRTemp) / 128
        let temperatures = (ambient:ambientTempInCelcius ,infrared: irTempInCelcius)
        return temperatures
    }
}
