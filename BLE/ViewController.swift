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
        print("")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startButtonPressed(sender: UIButton) {
        mPresenter?.onStartButtonPressed()
    }
    
    func enableStartButton(enable: Bool){
        startButton.enabled = enable
    }

    @IBAction func stopButtonPressed(sender: UIButton) {
         mPresenter?.onStopButtonPressed()
    }

    func enableStopButton(enable: Bool){
        stopButton.enabled = enable
    }
}

