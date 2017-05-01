//
//  SmartLock.swift
//  SmartCar
//
//  Created by Robert Smith on 5/1/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

enum LockState: Int {
    case unknown = 0
    case lock, unlock
    
    init?(data someData:Data?)
    {
        guard let data = someData , data.count == 1 else
        {
            return nil
        }
        
        var value: Int = 0
        
        (data as NSData).getBytes(&value, length:1)
        
        self.init(rawValue: value)
    }
    
    
    var data:Data
    {
        let value = UInt8(rawValue)
        return Data(bytes: [value])
    }
}

extension LockState: CustomStringConvertible {
    public var description:String
    {
        switch self {
        case .unknown:
            return "Unknown"
        case .lock:
            return "Locked"
        case .unlock:
            return "Unlocked"
        }
    }
}
