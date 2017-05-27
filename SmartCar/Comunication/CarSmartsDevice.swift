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
    
    var smartLockCharacteristic: Observable<Characteristic> {
        return peripheral.characteristic(with: SmartLockCharacteristic.lock)
    }
    
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
    
    public var isConnected: Bool {
        return peripheral.isConnected
    }
    
    public var rx_isConnected: Observable<Bool> {
        return peripheral.rx_isConnected
    }
    
    public func toggleLockState() -> Observable<LockState> {
        return smartLockCharacteristic.map { LockState(data: $0.value) }
        .map { $0.toggled() }
        .flatMap { self.setLockState($0) }
    }
    
    public func readLockState() -> Observable<LockState> {
        return smartLockCharacteristic.flatMap { characteristic in
            characteristic.readValueAndMonitorUpdates()
        }
        .map { LockState(data: $0.value) }.debug()
    }
    
    public func setLockState(_ newState: LockState) -> Observable<LockState> {
        return smartLockCharacteristic.flatMap { characterisitic in
            characterisitic.writeValue(newState.data, type: .withResponse)
        }
        .map { LockState(data: $0.value) }
    }
}

extension LockState {
    
    /// Helper function to toggle lock state
    /// changes `lock` to `unlock` and `unlock`/`unknown` to `lock`
    func toggled() -> LockState {
        switch self {
        case .lock:
            return .unlock
        case .unlock, .unknown:
            return .lock
        }
    }
}
