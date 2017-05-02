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

func ignoreNil<A>(x: A?) -> Observable<A> {
    return x.map { Observable.just($0) } ?? Observable.empty()
}

extension Reactive where Base: UITableView {
    func decodeSegue<T>(sender: Any?) -> T? {
        
        if let element = sender as? T {
            return element
            
        } else if let indexPath = sender as? IndexPath {
            return try! model(at: indexPath)
            
        } else if let tableViewCell = sender as? UITableViewCell {
            return decodeSegue(sender: base.indexPath(for: tableViewCell)!)
        }
        
        return nil
    }
}
