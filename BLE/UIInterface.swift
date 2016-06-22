//
//  UIInterface.swift
//  BLE
//
//  Created by Daniel Wallace on 21/06/16.
//  Copyright © 2016 Daniel Wallace. All rights reserved.
//

import Foundation

protocol UIInterface: class {
    
    func enableStartButton(_ enable: Bool)
    func enableStopButton(_ enable: Bool)
    func displayAmbient(temperature: Double)
    func displayInfrared(temperature: Double)
}
