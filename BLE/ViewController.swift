//
//  ViewController.swift
//  BLE
//
//  Created by Daniel Wallace on 21/06/16.
//  Copyright © 2016 Daniel Wallace. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIInterface {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var infraredTemperatureLabel: UILabel!
    @IBOutlet weak var ambientTemperatureLabel: UILabel!
    
    @IBOutlet weak var bluetoothStatusLabel: UILabel!
    @IBOutlet weak var bluetoothErrorLabel: UILabel!
    
    var mPresenter:Presenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let presenter = Presenter()
        mPresenter = presenter.onCreate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        mPresenter?.onStartButtonPressed()
    }
    
    func enableStartButton(_ enable: Bool){
        startButton.isEnabled = enable
    }

    @IBAction func stopButtonPressed(_ sender: UIButton) {
         mPresenter?.onStopButtonPressed()
    }

    func enableStopButton(_ enable: Bool){
        stopButton.isEnabled = enable
    }
    
    func displayAmbient(temperature: Double) {
        let roundedTemp = round(10 * temperature) / 10 // 1 decimal place
        ambientTemperatureLabel.text = "\(roundedTemp)ºC"
    }
    
    func displayInfrared(temperature: Double) {
        let roundedTemp = round(10 * temperature) / 10
        infraredTemperatureLabel.text = "\(roundedTemp)ºC"
    }
    
    func display(error: String) {
        bluetoothStatusLabel.text = error
        bluetoothStatusLabel.textColor = #colorLiteral(red: 1, green: 0.1307601253, blue: 0.1944364065, alpha: 1)
    }
    
    func display(status: String) {
        bluetoothStatusLabel.text = status
        bluetoothStatusLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}
