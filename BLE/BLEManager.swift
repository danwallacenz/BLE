//
//  BLEManager.swift
//  BLE
//
//  Created by Daniel Wallace on 21/06/16.
//  Copyright © 2016 Daniel Wallace. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject, SensorTagInterface {
    
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
    
// MARK: utils
    
    func publish(stateFor peripheral: CBPeripheral){
        var state = ""
        switch peripheral.state {
        case .disconnected:
            state = "Disconnected"
        case .connecting:
            state = "Connecting"
        case .connected:
            state = "Connected"
        case .disconnecting:
            state = "Disconnecting"
        }
        delegate?.on(status: state)
    }
    
    func publish(_ error: NSError){
        delegate?.on(error: error.localizedDescription)
    }

    func temperature(from dataBytes: Data) -> (ambient: Double, infrared: Double) {
        
        let SENSOR_DATA_INDEX_TEMP_INFRARED  = 0
        let SENSOR_DATA_INDEX_TEMP_AMBIENT = 1
        
        let dataLength = dataBytes.count / 2
        var dataArray = [UInt16](repeating: 0, count: dataLength)
        (dataBytes as NSData).getBytes(&dataArray, length: dataLength * sizeof(UInt16));
        
        let rawAmbientTemp = dataArray[SENSOR_DATA_INDEX_TEMP_AMBIENT]
        let ambientTempInCelcius = Double(rawAmbientTemp) / 128
        
        let rawInfraredTemp = dataArray[SENSOR_DATA_INDEX_TEMP_INFRARED]
        let irTempInCelcius = Double(rawInfraredTemp) / 128
        
        let temperatures = (ambient:ambientTempInCelcius ,infrared: irTempInCelcius)
        return temperatures
    }
}

// MARK: CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var state = ""
        switch central.state {
        case .unsupported:
            state = "This device does not support Bluetooth Low Energy"
        case .unauthorized:
            state = "This app is not authorized to use Bluetooth Low Energy"
        case .poweredOff:
            state = "Bluetooth on this device is currently powered off"
        case .resetting:
            state = "The BLE Manager is resetting; a state update is pending"
        case .poweredOn:
            state = "Bluetooth LE is turned on and ready for communication"
        case .unknown:
            state = "The state of the BLE Manager is unknown"
        }
        delegate?.on(status: state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber) {
        
        guard let peripheralName = advertisementData["kCBAdvDataLocalName"] as? String else {return}
        print("discovered: \(peripheralName) : \(peripheral.identifier.uuidString)")
        
        if peripheralName.contains(SENSOR_TAG_NAME) {
            
            publish(stateFor: peripheral)
            
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
        publish(stateFor: peripheral)
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: NSError?) {
        if let error = error {
            publish(error)
        }
        publish(stateFor: peripheral)
        print("didFailToConnectPeripheral")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let error = error {
            publish(error)
        }
        publish(stateFor: peripheral)
        print("didDisconnectPeripheral")
    }
}

// MARK: CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("didDiscoverServices")
        if let error = error {
            publish(error)
        } else {
            if let services = peripheral.services {
                for service in services {
                    print("discovered service: \(service.uuid)")
                    
                    if service.uuid .isEqual(CBUUID(string: UUID_TEMPERATURE_SERVICE)) {
                        peripheral.discoverCharacteristics(nil, for: service)
                    }
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: NSError?) {
        print("didDiscoverCharacteristicsForService")
        if let error = error {
            publish(error)
        } else {
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
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: NSError?) {
        if let error = error {
            publish(error)
        } else {
            // extract the data from the characteristic's value property and display the value based on the characteristic type
            if let data = characteristic.value {
                let temperatures = temperature(from: data)
                delegate?.on(temperature: temperatures)
            }
        }
    }
}
