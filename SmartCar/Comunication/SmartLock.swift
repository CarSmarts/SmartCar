//
//  SmartLock.swift
//  SmartCar
//
//  Created by Robert Smith on 5/1/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol SmartLockDelegate {
    func smartLock(_ smartLock: SmartLock, didSend command: Command, error: Error?)
}

public struct SmartLock {
    static internal var serviceUUID = CBUUID(string: "A1A4C256-3370-4D9A-99AA-70BFA81B906B")
    static internal var commandUUID = CBUUID(string: "6121294F-5171-4F3D-BD46-43ADAADDA75C")
    
    public var delegate: SmartLockDelegate?
    
    internal private(set) var commandCharacteristic: CBCharacteristic
    
    internal init(commandCharacteristic: CBCharacteristic) {
        self.commandCharacteristic = commandCharacteristic
    }
    
    public enum Command: Int {
        case cancel = 0
        case lock, unlock, driver
        
        case windowUp = 6
        case windowDown
    }
    
    public func send(_ command: Command) {
        // TODO: Refactor this into an extension somewhere?
        commandCharacteristic.service.peripheral.writeValue(command.data, for: commandCharacteristic, type: .withResponse)
    }
    
    internal func didWrite(error: Error?) {
        delegate?.smartLock(self, didSend: Command(data: commandCharacteristic.value), error: error)
    }
}

internal extension SmartLock.Command {
    init(data: Data?) {
        guard let data = data , data.count == 1 else
        {
            self = .cancel; return
        }
        
        let value = Int(data[0])
        
        self = SmartLock.Command(rawValue: value) ?? .cancel
    }
    
    var data: Data
    {
        let value = UInt8(rawValue)
        return Data([value])
    }
}
