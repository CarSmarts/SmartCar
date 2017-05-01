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
    
    var peripheral: Peripheral?
    
    init(from scannedPeripheral: ScannedPeripheral) {
        peripheral = scannedPeripheral.peripheral
        
        print("Connecting to: \(scannedPeripheral.advertisementData.localName ?? "Unnamed")")

        peripheral?.connect().subscribe(onNext: { peripheral in
            // connected, yay
        }).disposed(by: disposeBag)
    }
    
    var name: String {
        return peripheral?.name ?? "Unnamed"
    }
}
