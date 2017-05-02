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
    
    var device: CarSmartsDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        device.smartLock.asDriver(onErrorJustReturn: .unknown).drive(lockStateView.lockState).disposed(by: rx_disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
