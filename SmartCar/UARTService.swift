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

class UARTService : ObservableObject {
    static var serviceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static var rxUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    static var txUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

    var subs: Set<AnyCancellable> = []
    let vehicle: Vehicle
    
    init(vehicle: Vehicle) {
        self.vehicle = vehicle
                                    
        vehicle.recivedData
            .assign(to: \.rxBuffer, on: self)
            .store(in: &subs)
        
        if let rx = vehicle.rx {
//            let buffered = $txBuffer
//                .collect(.byTimeOrCount(DispatchQueue.global(), 100, 20))
//
//            let filtered = $txBuffer.map { data in
//                guard data.count > 0, else { return false }
//                let byte = data[data.count - 1]
//
//                return byte == 0x0A ? true : false
//            }
            
            $txBuffer
                .sink { newData in
                    vehicle.peripheral.writeValue(newData, for: rx, type: .withResponse)
                }
                .store(in: &subs)
        }
    }

    @Published var rxBuffer = Data()
    @Published var txBuffer = Data()
}

