//
//  CarSmartsDevice.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import RxSwift
import RxBluetoothKit

public class CarSmartsDevice {
    var disposeBag = DisposeBag()
    
    var peripheral: Peripheral
    
    public convenience init(with scannedPeripheral: ScannedPeripheral) {
        self.init(with: scannedPeripheral.peripheral)
    }
    
    public init(with peripheral: Peripheral) {
        self.peripheral = peripheral

        // always try to connect
        peripheral.connect().retry().subscribe(onNext: { peripheral in
            // connected, yay
        }).disposed(by: disposeBag)

    }
    
    public var name: String {
        return peripheral.name ?? "Unnamed"
    }
    
    public var smartLock: Observable<LockState> {
        return peripheral.characteristic(with: SmartLockCharacteristic.lock).flatMap { characteristic in
            characteristic.setNotificationAndMonitorUpdates()
        }.map { $0.value }
        .map(LockState.init(data:)).flatMap(ignoreNil).debug()
    }
}
