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
    
    convenience init(with scannedPeripheral: ScannedPeripheral) {
        self.init(with: scannedPeripheral.peripheral)
    }
    
    init(with peripheral: Peripheral) {
        self.peripheral = peripheral

        // always try to connect
        peripheral.connect().retry().subscribe(onNext: { peripheral in
            // connected, yay
        }).disposed(by: disposeBag)

    }
    
    var name: String {
        return peripheral.name ?? "Unnamed"
    }
}
