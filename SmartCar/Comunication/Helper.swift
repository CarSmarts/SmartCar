//
//  Helper.swift
//  SmartCar
//
//  Created by Robert Smith on 5/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import RxSwift
import RxBluetoothKit

extension Characteristic {
    
    /// Function that combines `readValue()` and `setnotificationAndMonitorUpdates()`
    func readValueAndMonitorUpdates() -> Observable<Characteristic> {
        return Observable.merge(
            readValue(),
            setNotificationAndMonitorUpdates()
        )
    }
}
