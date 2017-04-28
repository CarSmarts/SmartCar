//
//  DeviceManager.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import RxSwift
import RxBluetoothKit
import CoreBluetooth
import NSObject_Rx

let smartCarServices = [CBUUID(string: "A1A4C256-3370-4D9A-99AA-70BFA81B906B")]

public class DeviceManager: NSObject {
    public static let manager = DeviceManager()
    
    let bluetoothManager = BluetoothManager()
 
    //MARK: scan switch
    public var scan: Observable<CarSmartsDevice> {
        return bluetoothManager.rx_state.filter { $0 == .poweredOn }.flatMapLatest { _ -> Observable<ScannedPeripheral> in
            print("Scanning.. ")
            
            return self.bluetoothManager.scanForPeripherals(withServices: smartCarServices)
        }.flatMap { scannedPeripheral -> Observable<Peripheral> in
            print("Connecting to: \(scannedPeripheral.advertisementData.localName ?? "Unnamed")")
            
            return scannedPeripheral.peripheral.connect()
        }.map { CarSmartsDevice(from: $0) }
        .do(onNext: { (device: CarSmartsDevice) in
            self.knownDevices.value.append(device)
        })
    }
    
    //MARK: devices
    public var knownDevices = Variable<[CarSmartsDevice]>([])
    
}
