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
        print("ambient temp is \(round(10 * temperature) / 10)º C") // 1 decimal place
    }
    
    func displayInfrared(temperature: Double) {
         print("infrared temp is \(round(10 * temperature) / 10)º C")
    }
}

