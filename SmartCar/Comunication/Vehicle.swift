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
    
    public private(set) var smartLock: SmartLock? {
        didSet {
            if let smartLock = smartLock {
                delegate?.vehicle(self, smartLockDidBecomeAvalible: smartLock)
            }
        }
    }
    
    init(with peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        super.init()
        
        peripheral.delegate = self
    }
    
    /// Method to pass "didConnect" callback from manager delegate to individual Vehicles
    internal func didConnect() {
        peripheral.discoverServices([SmartLock.serviceUUID])
    }
    
    /// Method to pass "didDisconnect" callback from manager delegate to individual Vehicles
    internal func didDisconnect(error: Error?) {
        delegate?.vehicleDidBecomeUnavailible(self, error: error)
    }
}

/// Public Accessors
public extension Vehicle {
    
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
            print("Failed to discover service: \(error)")
            return
        }
        
        if let smartLockService = peripheral.services?.first(where: { $0.uuid == SmartLock.serviceUUID }) {
        
            peripheral.discoverCharacteristics([SmartLock.commandUUID], for: smartLockService)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Failed to discover service: \(error)")
            return
        }
        
        if let characteristic = service.characteristics?.first(where: { $0.uuid == SmartLock.commandUUID }) {
            smartLock = SmartLock(commandCharacteristic: characteristic)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let smartLock = smartLock, smartLock.commandCharacteristic == characteristic {
            smartLock.didWrite(error: error)
        }
        
    }
}

/// Hashable Conformance
extension Vehicle {
    
    static public func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }
    
    public override var hash: Int {
        return peripheral.hashValue
    }
    
}

public protocol VehicleDelegate {
    func vehicleDidBecomeAvailible(_ vehicle: Vehicle)
    func vehicleDidBecomeUnavailible(_ vehicle: Vehicle, error: Error?)
    
    func vehicle(_ vehicle: Vehicle, smartLockDidBecomeAvalible smartLock: SmartLock)
}

