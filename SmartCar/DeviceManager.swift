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
    
    let bluetoothManager = BluetoothManager(queue: .global(qos: .userInitiated), options: [CBCentralManagerOptionRestoreIdentifierKey : "carSmartsSenderRestoreIdent" as AnyObject])
    
    public override init() {
        super.init()
        
        bluetoothManager.listenOnRestoredState().subscribe(onNext: { restoredState in
            print("Restored: \(restoredState)")
        }).disposed(by: rx_disposeBag)
    }
    
    //MARK: scan switch
    public var attemptScan: Observable<BluetoothState> {
        
        let rx_state = bluetoothManager.rx_state
            .debug("rx_state")
        
        let scan = bluetoothManager.scanForPeripherals(withServices: smartCarServices).do(onNext: {
            let device = CarSmartsDevice(from: $0)
            
            self.knownDevices.value.append(device)
        })
            .debug("scan")
        
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
    public var knownDevices = Variable<[CarSmartsDevice]>([])
    
}
