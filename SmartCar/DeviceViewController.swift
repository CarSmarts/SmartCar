//
//  DeviceViewController.swift
//  SmartCar
//
//  Created by Robert Smith on 5/1/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

class DeviceViewController: UIViewController {
    
    @IBOutlet weak var lockStateView: LockStateView!
    
    var device: CarSmartsDevice! {
        didSet {
            device.smartLock.asDriver(onErrorJustReturn: .unknown).drive(lockStateView.lockState).disposed(by: rx_disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // show device list if we have no device
        //TODO: We will always have no device on startup? we should change this
        if device == nil {
            performSegue(withIdentifier: "ShowDeviceList", sender: self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwind(unwindSegue: UIStoryboardSegue) {
        //TODO: Something?
    }
    
}
