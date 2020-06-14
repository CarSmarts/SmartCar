//
//  Vehicle.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

public typealias VehicleState = CBPeripheralState
public typealias Command = SmartLock.Command

public class MockVehicle: Vehicle {
    init() {
        super.init(with: nil)
        
        self.uartService = UARTService(vehicle: self)
    }
}

public class Vehicle: NSObject, Identifiable, ObservableObject {
    let peripheral: CBPeripheral!
    
    public typealias ID = UUID
    
    public var id: UUID {
        return peripheral.identifier
    }
    
    public private(set) var smartLock: SmartLock?
    public fileprivate(set) var uartService: UARTService? {
        didSet {
            guard let uartService = uartService else { return }
            self.m2SmartService = M2SmartService(uartService: uartService)
        }
    }
    public fileprivate(set) var m2SmartService: M2SmartService?
    
    var rx: CBCharacteristic?
    var tx: CBCharacteristic?
        
    internal init(with peripheral: CBPeripheral?) {
        self.peripheral = peripheral
        
        super.init()
        
        peripheral?.delegate = self
    }
    
    /// Method to pass "didConnect" callback from manager delegate to individual Vehicles
    internal func didConnect() {
        peripheral.discoverServices([SmartLock.serviceUUID, UARTService.serviceUUID])
        self.isConnected = true
    }
    
    /// Method to pass "didDisconnect" callback from manager delegate to individual Vehicles
    internal func didDisconnect(error: Error?) {
        self.isConnected = false
        self.uartService?.clear()
    }
    
    /// Public Accessors
    var name: String {
        return peripheral?.name ?? "Vehicle"
    }
    
    var state: VehicleState {
        return peripheral?.state ?? .disconnected
    }

    @Published var isConnected: Bool = false

    static public func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }
}

extension Vehicle: CBPeripheralDelegate {
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        self.objectWillChange.send()
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Failed to discover service: \(error)")
            return
        }
        
        if let smartLockService = peripheral.services?.first(where: { $0.uuid == SmartLock.serviceUUID }) {
        
            peripheral.discoverCharacteristics([SmartLock.commandUUID], for: smartLockService)
        }
        
        if let uartService = peripheral.services?.first(where: { $0.uuid == UARTService.serviceUUID }) {
        
            peripheral.discoverCharacteristics([UARTService.rxUUID, UARTService.txUUID], for: uartService)
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
        
        if let rx = service.characteristics?.first(where: { $0.uuid == UARTService.rxUUID }) {
            self.rx = rx
        }
        if let tx = service.characteristics?.first(where: { $0.uuid == UARTService.txUUID }) {
            self.tx = tx
            peripheral.setNotifyValue(true, for: tx)
        }
        if self.rx != nil, self.tx != nil, self.uartService == nil {
            self.uartService = UARTService(vehicle: self)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let smartLock = smartLock, smartLock.commandCharacteristic == characteristic {
            smartLock.didWrite(error: error)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let uartService = uartService, let tx = tx, let data = characteristic.value, tx == characteristic {
            uartService.rxBuffer = data
        }
    }
}

extension Vehicle {
    public override var description: String {
        return "Vehicle: M2Smart " + (isConnected ? "Connected" : "Not Connected")
    }
}
