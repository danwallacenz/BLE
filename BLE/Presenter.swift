//
//  Presenter.swift
//  BLE
//
//  Created by Daniel Wallace on 21/06/16.
//  Copyright © 2016 Daniel Wallace. All rights reserved.
//

import Foundation

class Presenter {
    
    weak var ui: UIInterface? = nil
    let  bluetoothManager = BLEManager()
    
    func onCreate(ui:UIInterface) -> Presenter {
        self.ui = ui
        ui.enableStopButton(false)
        return self
    }
    
    func onStartButtonPressed() {
        ui?.enableStartButton(false)
        ui?.enableStopButton(true)
        bluetoothManager.start()
    }
    
    func onStopButtonPressed() {
        ui?.enableStartButton(true)
        ui?.enableStopButton(false)
        bluetoothManager.stop()
    }
}
