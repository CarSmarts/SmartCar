//
//  RxHelper.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation
import RxSwift

func dots(initialString: String, range: ClosedRange<Int>, timeInterval: RxTimeInterval) -> Observable<String> {
    let interval = Observable<Int>.interval(timeInterval, scheduler: MainScheduler.instance)
    
    return interval.scan(range.lowerBound) { (current, _) in
        current == range.upperBound ? range.lowerBound : current + 1
    }.map { count in
        return initialString + repeatElement(".", count: count).joined()
    }
}
