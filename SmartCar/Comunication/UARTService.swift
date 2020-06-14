//
//  UARTService.swift
//  SmartCar
//
//  Created by Robert Smith on 4/19/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

public class UARTService : ObservableObject, CustomStringConvertible {
    static var serviceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static var rxUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    static var txUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

    var subs: Set<AnyCancellable> = []
    let vehicle: Vehicle
    
    init(vehicle: Vehicle) {
        self.vehicle = vehicle
        
        if let rx = vehicle.rx {
            // we ignore the first one because it just publishes the inital empty value
            $txBuffer.dropFirst()
                .sink { newData in
                    vehicle.peripheral.writeValue(newData, for: rx, type: .withResponse)
                }
                .store(in: &subs)
        } else {
            // We shouldn't get here
        }
    }
    
    public func clear() {
        rxBuffer = Data()
        txBuffer = Data()
    }

    @Published public var rxBuffer = Data()
    @Published public var txBuffer = Data()
        
    public var description: String {
        return """
        Vehicle: \(vehicle.name)
        rxBuffer: \(rxBuffer)
        txBuffer: \(txBuffer)
        """
    }
}

