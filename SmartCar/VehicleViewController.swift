//
//  VehicleViewController.swift
//  SmartCar
//
//  Created by Robert Smith on 5/1/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit
import SwiftUI

class VehicleViewController: UIViewController {
    
    let vehicleManager = VehicleManager(uniqueID: "manager")
    
    var vehicle: Vehicle? {
        didSet {
            vehicle?.delegate = self
            title = vehicle?.name ?? "Vehicle"
        }
    }
    @IBOutlet weak var commandView: CommandView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        singleTap.require(toFail: doubleTap)
        doubleTap.numberOfTapsRequired = 2
        
        view.addGestureRecognizer(singleTap)
        view.addGestureRecognizer(doubleTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if vehicle == nil {
            vehicle = vehicleManager.vehicles.first
            if vehicle == nil {
                //performSegue(withIdentifier: "ShowVehicleList", sender: self)
                
                //TODO: Remove before flight
                performSegue(withIdentifier: "CANHack", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwind(unwindSegue: UIStoryboardSegue) {
        //TODO: Something?
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vehicleListVC = segue.finalDestination as? VehicleListViewController {
            vehicleListVC.vehicleManager = vehicleManager
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            if sender.numberOfTapsRequired == 2 {
                send(.unlock)
            } else {
                send(.lock)
            }
        }
    }
                
    func send(_ command: Command) {
        vehicle?.smartLock?.send(command)
        commandView.display(sending: command)
    }
}

extension VehicleViewController: VehicleDelegate {
    func vehicle(_ vehicle: Vehicle, smartLockDidBecomeAvalible smartLock: SmartLock) {
        //TODO:
    }
    
    func vehicleDidBecomeAvailible(_ vehicle: Vehicle) {
        //TODO: Display Avalibility
    }
    
    func vehicleDidBecomeUnavailible(_ vehicle: Vehicle, error: Error?) {
        //TODO:
    }
}

extension VehicleViewController: SmartLockDelegate {
    func smartLock(_ smartLock: SmartLock, didSend command: Command, error: Error?) {
        commandView.complete()
        
        if let error = error {
            //TODO: Better error messages?
            commandView.error(message: error.localizedDescription)
        }
    }
}
