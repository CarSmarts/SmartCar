//
//  Helper.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

//func dots(initialString: String, range: ClosedRange<Int>, timeInterval: RxTimeInterval) -> Observable<String> {
//    let interval = Observable<Int>.interval(timeInterval, scheduler: MainScheduler.instance)
//    
//    return interval.scan(range.lowerBound) { (current, _) in
//        current == range.upperBound ? range.lowerBound : current + 1
//    }.map { count in
//        return initialString + repeatElement(".", count: count).joined()
//    }
//}

extension UIStoryboardSegue {
    /// Returns the destination, bypassing any view controller containers
    var finalDestination: UIViewController {
        if let nav = destination as? UINavigationController {
            return nav.topViewController ?? destination
        }
        
        return destination
    }
}

class Logger {
    // TODO: offical logging
    static func log(_ items: Any...) {
        print(items)
    }

    static func warn(_ items: Any...) {
        print("[WARN]", terminator: " ")
        print(items)
    }
    
    static func error(_ items: Any...) {
        print("[ERROR]", terminator: " ")
        print(items)
    }
    
}

protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        // I like to use the class's name as an identifier
        // so this makes a decent default value.
        return String(describing: self)
    }
}

extension UITableView {
//    func registerReusableCell<T: UITableViewCell where T: Reusable>(_: T.Type) {
//        if let nib = T.nib {
//            self.registerNib(nib, forCellReuseIdentifier: T.reuseIdentifier)
//        } else {
//            self.registerClass(T.self, forCellReuseIdentifier: T.reuseIdentifier)
//        }
//    }
    
    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: Reusable {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
