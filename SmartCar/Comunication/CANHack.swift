//
//  CANHack.swift
//  SmartCar
//
//  Created by Robert Smith on 6/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct CANHack {
    static var service = CBUUID(string: "149089BA-3229-40D6-A6E4-D02030CD4C7A")
    static var characteristic = CBUUID(string: "79EFB0FA-484F-4202-8C5F-A90EC8FD6605")
}
