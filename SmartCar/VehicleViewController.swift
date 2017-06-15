//
//  VehicleViewController.swift
//  SmartCar
//
//  Created by Robert Smith on 5/1/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit
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
        
        doubleTap.numberOfTapsRequired = 2
        
        view.addGestureRecognizer(singleTap)
        view.addGestureRecognizer(doubleTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if vehicle == nil {
            vehicle = vehicleManager.vehicles.first
            if vehicle == nil {
                performSegue(withIdentifier: "ShowVehicleList", sender: self)
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
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        
        if sender.state == .ended {
            if sender.numberOfTapsRequired == 2 {
                send(.unlock)
            } else {
                send(.lock)
            }
        }
    }
            
    func send(_ command: Command) {
        vehicle?.send(command)
        commandView.display(sending: command)
    }
}

extension VehicleViewController: VehicleDelegate {
    func vehicle(_ vehicle: Vehicle, didSend command: Command, error: Error?) {
        commandView.complete()
    }
}
