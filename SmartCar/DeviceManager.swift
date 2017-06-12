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

public class DeviceManager: NSObject {
    public static let manager = DeviceManager()
    
    public var delegate: DeviceManagerDelegate?
    
    let bluetoothManager = BluetoothManager(queue: .global(qos: .userInitiated), options: [CBCentralManagerOptionRestoreIdentifierKey : "carSmartsSenderRestoreIdent" as AnyObject])
    
    public override init() {
        super.init()
        
        bluetoothManager.listenOnRestoredState().subscribe(onNext: { restoredState in
            
            let restoredDevices = restoredState.peripherals.map(CarSmartsDevice.init(with:))
            
            self.knownDevices.formUnion(restoredDevices)
            self.delegate?.deviceManager(didRestore: restoredDevices)
            
            print("Restored: \(restoredState)")
        }).disposed(by: rx_disposeBag)
    }
    
    //MARK: scan switch
    public var attemptScan: Observable<BluetoothState> {
        
        let rx_state = bluetoothManager.rx_state
                
        let scan = bluetoothManager.scanForPeripherals(withServices: CarSmartsService.services).do(onNext: {
            let device = CarSmartsDevice(with: $0)
            
            DispatchQueue.main.async {
                self.discoveredDevices.insert(device)
                self.delegate?.deviceManger(didDiscover: device)
            }
        })
        
        // kick off scan when subscribed, and dispose when state subscription is disposed
        return rx_state.flatMapLatest { state -> Observable<BluetoothState> in
            
            if state == .poweredOn {
                // if powered on, return state, but also start the scan
                return Observable.using({
                    CompositeDisposable(disposables: [scan.subscribe()])
                }) { _ in Observable.never().startWith(state) } // Observable that never completes but sends out state
            }
            
            // if anything other than .poweredOn, just return the state
            return .just(state)
        }
    }
    
    //MARK: devices
    public var discoveredDevices = Set<CarSmartsDevice>()
    
    public var knownDevices = Set<CarSmartsDevice>()
}

public protocol DeviceManagerDelegate {
    func deviceManger(didDiscover device: CarSmartsDevice)
    
    func deviceManager(didRestore knownDevices: [CarSmartsDevice])
}

