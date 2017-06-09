//
//  SmartLock.swift
//  SmartCar
//
//  Created by Robert Smith on 5/1/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

public enum LockState: Int {
    case unknown = 0
    case lock, unlock
    
    init(data someData:Data?)
    {
        guard let data = someData , data.count == 1 else
        {
            self = .unknown
            return
        }
        
        var value: Int = 0
        
        (data as NSData).getBytes(&value, length:1)
        
        self = LockState(rawValue: value) ?? .unknown
    }
    
    
    var data:Data
    {
        let value = UInt8(rawValue)
        return Data(bytes: [value])
    }
}
