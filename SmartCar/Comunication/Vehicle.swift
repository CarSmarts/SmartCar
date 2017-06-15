//
//  Vehicle.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import CoreBluetooth

public typealias VehicleState = CBPeripheralState
public typealias Command = SmartLock.Command

public class Vehicle: NSObject {
    
    public var delegate: VehicleDelegate?
    
    let peripheral: CBPeripheral
    fileprivate var smartLockCharacteristc: CBCharacteristic?
    
    fileprivate var onDiscoveryFinish: (() -> Void)?
    
    init(with peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        super.init()
        
        peripheral.delegate = self
    }
    
    /// Method to pass "didConnect" callback from manager delegate to individual Vehicles
    internal func didConnect() {
        if let _ = smartLockCharacteristc {
            delegate?.vehicleDidBecomeAvailible(self)
        } else {
            peripheral.discoverServices([SmartLock.service])
        }
    }
    
    /// Method to pass "didDisconnect" callback from manager delegate to individual Vehicles
    internal func didDisconnect(error: Error?) {
        delegate?.vehicleDidBecomeUnavailible(self, error: error)
    }
}

/// Public Accessors
public extension Vehicle {
    
    func send(_ command: Command) {
        guard let characteristic = smartLockCharacteristc else {
            onDiscoveryFinish = { [weak self] in
                self?.send(command)
            }
            return
        }
        
        peripheral.writeValue(command.data, for: characteristic, type: .withResponse)
    }
    
    // MARK: Forwarding Accessors
    
    var name: String {
        return peripheral.name ?? "Vehicle"
    }
    
    var state: VehicleState {
        return peripheral.state
    }

    var isConnected: Bool {
        return state == .connected
    }
}

extension Vehicle: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            assertionFailure("Failed to discover service: \(error)")
            return
        }
        
        guard let service = peripheral.services?.first(where: { $0.uuid == SmartLock.service }) else {
            // Discovered junk service.. should never happen
            assertionFailure("Failed to discover service")
            return
        }
        
        peripheral.discoverCharacteristics([SmartLock.characteristic], for: service)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            assertionFailure("Failed to discover service: \(error)")
            return
        }
        
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == SmartLock.characteristic }) else {
            assertionFailure("Failed to discover characterisitc")
            return
        }
        
        self.smartLockCharacteristc = characteristic
        // Do any waiting work
        onDiscoveryFinish?()
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let commandCharacteristic = smartLockCharacteristc, commandCharacteristic == characteristic {
            delegate?.vehicle(self, didSend: Command(data: commandCharacteristic.value), error: error)
        }
    }
}

/// Hashable Conformance
extension Vehicle {
    
    static public func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }
    
    public override var hashValue: Int {
        return peripheral.hashValue
    }
    
}

public protocol VehicleDelegate {
    func vehicle(_ vehicle: Vehicle, didSend command: Command, error: Error?)
    
    func vehicleDidBecomeAvailible(_ vehicle: Vehicle)
    func vehicleDidBecomeUnavailible(_ vehicle: Vehicle, error: Error?)
}

