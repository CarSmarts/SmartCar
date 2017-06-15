//
//  VehicleManager.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import CoreBluetooth

public class VehicleManager: NSObject {
    
    public var delegate: VehicleManagerDelegate?
    
    fileprivate var centralManager: CBCentralManager!
    
    public init(uniqueID: String) {
        super.init()
        
        let options = [CBCentralManagerOptionRestoreIdentifierKey : uniqueID as AnyObject]
        
        // TODO: background queue?
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: recordedIdentifiers)
        
        vehicles = peripherals.map { Vehicle(with: $0) }
    }
    
    /// All vehicles paired with this vehicle
    public var vehicles = [Vehicle]()
    
    fileprivate func vehicle(`for` peripheral: CBPeripheral) -> Vehicle {
        //TODO: crashes when we don't have a vehicle for a certain peripheral?
        return vehicles.first(where: { $0.peripheral == peripheral })!
    }
}

public extension VehicleManager {
    /// Search for more vehicles to pair with
    func scanForNewVehicles() {
        centralManager.scanForPeripherals(withServices: [SmartLock.service])
    }
    
    var isScanning: Bool {
        return centralManager.isScanning
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    @discardableResult
    func connect(to discoveredVehicle: DiscoveredVehicle) -> Vehicle {
        let peripheral = discoveredVehicle.peripheral
        
        centralManager.connect(peripheral)
        
        recordedIdentifiers.append(peripheral.identifier)
        
        let vehicle = Vehicle(with: peripheral)
        vehicles.append(vehicle)
        
        return vehicle
    }
    
    func connect(to vehicle: Vehicle) {
        centralManager.connect(vehicle.peripheral)
    }
}

extension VehicleManager : CBCentralManagerDelegate {

    fileprivate var recordedIdentifiers: [UUID] {
        get {
            let value = UserDefaults.standard.value(forKey: "knownVehicles") as? [String] ?? []
            return value.map { UUID(uuidString: $0)! }
        }
        set {
            UserDefaults.standard.set(newValue.map { $0.uuidString }, forKey: "knownVehicles")
        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //TODO:
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        //TODO: State Restoration
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let discoveredVehicle = DiscoveredVehicle(peripheral: peripheral, rssi: RSSI)
        
        delegate?.vehicleManager(didDiscover: discoveredVehicle)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.vehicleManager(didDisconnect: vehicle(for: peripheral), error: error)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegate?.vehicleManager(didConnect: vehicle(for: peripheral))
    }
}

/// Newly discovered Vehicle, not yet paired
public struct DiscoveredVehicle {
    fileprivate var peripheral: CBPeripheral
    
    fileprivate(set) public var rssi: NSNumber
    
    var name: String {
        return peripheral.name ?? "Vehicle"
    }
}

public protocol VehicleManagerDelegate {
    func vehicleManager(didDiscover discoveredVehicle: DiscoveredVehicle)
    
    func vehicleManager(didConnect vehicle: Vehicle)
    func vehicleManager(didDisconnect vehicle: Vehicle, error: Error?)
}
