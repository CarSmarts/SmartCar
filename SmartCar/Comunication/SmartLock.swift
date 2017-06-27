//
//  SmartLock.swift
//  SmartCar
//
//  Created by Robert Smith on 5/1/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct SmartLock {
    static var service = CBUUID(string: "A1A4C256-3370-4D9A-99AA-70BFA81B906B")
    static var characteristic = CBUUID(string: "6121294F-5171-4F3D-BD46-43ADAADDA75C")

    public enum Command: Int {
        case cancel = 0
        case lock, unlock, driver
        
        case windowUp = 6
        case windowDown
    }
}

internal extension SmartLock.Command {
    init(data: Data?) {
        guard let data = data , data.count == 1 else
        {
            self = .cancel; return
        }
        
        let value: Int = data.withUnsafeBytes { $0.pointee }
        
        self = SmartLock.Command(rawValue: value) ?? .cancel
    }
    
    var data: Data
    {
        let value = UInt8(rawValue)
        return Data(bytes: [value])
    }
}
