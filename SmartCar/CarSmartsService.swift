//
//  CarSmartsService.swift
//  SmartCar
//
//  Created by Robert Smith on 4/30/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import RxBluetoothKit
import CoreBluetooth

enum CarSmartsService: String, ServiceIdentifier {
    case smartLock = "A1A4C256-3370-4D9A-99AA-70BFA81B906B"
    
    var uuid: CBUUID {
        return CBUUID(string: self.rawValue)
    }
    
}

enum SmartLockCharacteristic: String, CharacteristicIdentifier {
    case lock = "6121294F-5171-4F3D-BD46-43ADAADDA75C"
    case window = "79EFB0FA-484F-4202-8C5F-A90EC8FD6605"
    
    var uuid: CBUUID {
        return CBUUID(string: self.rawValue)
    }
    
    var service: ServiceIdentifier {
        return CarSmartsService.smartLock
    }
}
