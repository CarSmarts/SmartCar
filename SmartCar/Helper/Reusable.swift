//
//  Reusable.swift
//  SmartCar
//
//  Created by Robert Smith on 6/19/18.
//  Copyright © 2018 Robert Smith. All rights reserved.
//

import UIKit

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
