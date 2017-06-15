//
//  VehicleListViewController.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

class VehicleListViewController: UITableViewController {
    
    var vehicleManager: VehicleManager! {
        didSet {
            vehicleManager?.delegate = self
        }
    }
    
    fileprivate var discoveredVehicles = [DiscoveredVehicle]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: Button to turn on scan + auto when there are no vehicles
        vehicleManager.scanForNewVehicles()

        
        // TODO: Display state
//        .flatMapLatest { state -> Observable<String> in
//            switch state {
//            case .poweredOn:
//                return dots(initialString: "Scanning", range: 1...3, timeInterval: 1)
//            case .poweredOff:
//                return .just("Bluetooth Off")
//            case .unauthorized:
//                return .just("Authorize in settings")
//            case .unknown, .resetting:
//                return .just("Unknown")
//            case .unsupported:
//                return .just("Bluetooth Not supported")
//            }
//        }
//        .subscribe(onNext: { self.title = $0 })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        vehicleManager.stopScan()
    }
    
    // MARK: - Navigation
    
    func decodeSegue(sender: Any?) -> Vehicle? {
        
        let indexPath: IndexPath
        
        if let path = sender as? IndexPath {
            indexPath = path
            
        } else if let cell = sender as? UITableViewCell {
            indexPath = tableView.indexPath(for: cell)!
        } else {
            return nil
        }
        
        switch indexPath.section {
        case 0:
            return vehicleManager.vehicles[indexPath.row]
        case 1:
            let connectedVehicle = vehicleManager.connect(to: discoveredVehicles[indexPath.row])
            let newIndexPath = IndexPath(row: vehicleManager.vehicles.index(of: connectedVehicle)!, section: 0)
            
            tableView.moveRow(at: indexPath, to: newIndexPath)
            
            return connectedVehicle
        default:
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let vehicle = decodeSegue(sender: sender) else { return }
        
        if let destination = segue.destination as? VehicleViewController {
            destination.vehicle = vehicle
        }
    }
}

extension VehicleListViewController: VehicleManagerDelegate {
    
    func vehicleManager(didDiscover discoveredVehicle: DiscoveredVehicle) {
        let newIndexPath = IndexPath(row: discoveredVehicles.count, section: 1)
        
        discoveredVehicles.append(discoveredVehicle)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    private func reload(for vehicle: Vehicle) {
        let indexPath = IndexPath(row: vehicleManager.vehicles.index(of: vehicle)!, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func vehicleManager(didConnect vehicle: Vehicle) {
        reload(for: vehicle)
    }
    
    func vehicleManager(didDisconnect vehicle: Vehicle, error: Error?) {
        reload(for: vehicle)
    }
}

/// UITableViewDelegate / DataSource
extension VehicleListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return vehicleManager.vehicles.count
        } else if section == 1 {
            return discoveredVehicles.count
        } else {
            fatalError("Section \(section) Out of Range")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vehicle", for: indexPath)
        
        if indexPath.section == 0 {
            let vehicle = vehicleManager.vehicles[indexPath.row]
            
            cell.textLabel?.text = vehicle.name
            cell.textLabel?.textColor = vehicle.isConnected ? .orange : .darkText
            cell.textLabel?.isEnabled = true

        } else {
            let discoveredVehicle = discoveredVehicles[indexPath.row]
            
            cell.textLabel?.text = discoveredVehicle.name
            cell.textLabel?.textColor = .darkText
            cell.textLabel?.isEnabled = false
        }

        return cell
    }

}
