//
//  VehicleManager.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import CoreBluetooth

public class VehicleManager: NSObject, ObservableObject {
    
    public enum State: Equatable {
        case availible
        case unknown
        case unavailible(String)
        
        fileprivate init(cbState: CBManagerState) {
            switch cbState {
            case .poweredOn:
                self = .availible
            case .poweredOff:
                self = .unavailible("Bluetooth Off")
            case .unauthorized:
                self = .unavailible("Authorize in settings")
            case .unsupported:
                self = .unavailible("Device Not supported")
            case .unknown, .resetting:
                self = .unknown
            @unknown default:
                fatalError()
            }
        }
    }
    
    @Published public var state: State = .unknown {
        didSet {
            if case .availible = state {
                if shouldScan {
                    self.shouldScan = true // force start scan
                }
                for vehicle in vehicles {
                    // Try to connect to all the vehicles we know
                    centralManager.connect(vehicle.peripheral)
                }
            }
        }
    }
    
    fileprivate var centralManager: CBCentralManager!
    
    /// Search for more vehicles to pair with
    @Published var shouldScan: Bool = false {
        didSet {
            if shouldScan {
                centralManager.scanForPeripherals(withServices: [SmartLock.serviceUUID, UARTService.serviceUUID])
            } else {
                centralManager.stopScan()
            }
        }
    }
    
    var isScanning: Bool {
        return centralManager.isScanning
    }
        
    public init(uniqueID: String = "manager") {
        super.init()
        
        let options = [CBCentralManagerOptionRestoreIdentifierKey : uniqueID as AnyObject]
        
        // TODO: background queue?
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: recordedIdentifiers)
        
        self.recordedIdentifiers.removeAll { uuid in
            // remove every recorded identifier that we are no longer paired with..
            // TODO: maybe we sould come up with some "Disconnected vehicle.. that stays in the list until
            // the bluetooth stack discoveres it again
            !peripherals.contains(where: { $0.identifier == uuid })
        }
        
        vehicles = peripherals.map { Vehicle(with: $0) }
    }
    
    /// All vehicles paired with this device
    @Published public var vehicles = [Vehicle]()
    
    fileprivate func vehicle(for peripheral: CBPeripheral) -> Vehicle? {
        return vehicles.first(where: { $0.peripheral == peripheral })
    }
    
    public func removeVehicle(at index: Int) {
        let vehicle = vehicles[index]
        
        recordedIdentifiers.removeAll { uuid in
            uuid == vehicle.id
        }
        
        vehicles.remove(at: index)
    }
    
    func connect(to vehicle: Vehicle) {
        guard let peripheral = vehicle.peripheral else {
            return
        }
        if !vehicle.isConnected {
            centralManager.connect(peripheral)
        }
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
        state = State(cbState: central.state)
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        //TODO: State Restoration
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if vehicles.contains(where: { $0.id == peripheral.identifier }) {
            // this is a "known device", ignore it
            return
        }
        centralManager.connect(peripheral)

        recordedIdentifiers.append(peripheral.identifier)
        vehicles.append(Vehicle(with: peripheral))
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // Try to reconnect
        centralManager.connect(peripheral)
        
        guard let vehicle = self.vehicle(for: peripheral) else {
            //FIXME: How did we get here
            return
        }

        vehicle.didDisconnect(error: error)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let vehicle = self.vehicle(for: peripheral) else {
            //FIXME: How did we get here
            return
        }

        vehicle.didConnect()
    }
}
