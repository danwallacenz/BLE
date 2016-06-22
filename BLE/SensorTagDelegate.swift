//
//  SensorTagDelegate.swift
//  BLE
//
//  Created by Daniel Wallace on 22/06/16.
//  Copyright © 2016 Daniel Wallace. All rights reserved.
//

import Foundation

protocol SensorTagDelegate {
    func on(temperature: (ambient: Double, infrared: Double))
}
