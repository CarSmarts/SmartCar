//
//  CarSmartsDevice.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import RxBluetoothKit

public class CarSmartsDevice {
    var peripheral: Peripheral?
    
    init(from peripheral: Peripheral) {
        self.peripheral = peripheral
    }
    
    var name: String {
        return peripheral?.name ?? "Unnamed Device"
    }
}
