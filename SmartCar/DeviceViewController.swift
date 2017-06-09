//
//  DeviceViewController.swift
//  SmartCar
//
//  Created by Robert Smith on 5/1/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit
import RxSwift

class DeviceViewController: UIViewController {
    
    @IBOutlet weak var lockStateView: LockStateView! {
        didSet {
            lockStateView.rx.tap.map {
                // Toggle current state
                let newState = self.lockStateView.lockState.toggled()
                
                self.lockStateView.displaySending(newState)
                
                return newState
                
            }.flatMapLatest { newState in
                self.device.setLockState(newState).catchError { error in
                    //TODO: do something with error
                    self.lockStateView.error()
                    
                    return Observable.never()
                }
            }.debug().subscribe().disposed(by: rx_disposeBag)
        }
    }

    var device: CarSmartsDevice! {
        didSet {
            device.readLockState().debug().asDriver(onErrorJustReturn: .unknown).drive(onNext: { newState in
                self.lockStateView.display(newState)
            }).disposed(by: rx_disposeBag)
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
