//
//  LockStateView.swift
//  SmartCar
//
//  Created by Robert Smith on 5/1/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit
import RxSwift

class LockStateView: UIButton {
    
    var lockState = Variable(LockState.unknown)
    
    var sending = Variable(false)
    
    override func awakeFromNib() {
        
        _ = lockState.asDriver().drive(onNext: { state in
            switch state {
            case .lock:
                self.setTitle("Locked", for: .normal)
            case .unlock:
                self.setTitle("Unlocked", for: .normal)
            case .unknown:
                self.setTitle("...", for: .normal)
            }
        })

        _ = sending.asDriver().drive(onNext: { sending in
            if sending {
                self.setTitleColor(.orange, for: .normal)
            } else {
                self.setTitleColor(.black, for: .normal)
            }

        })
    }
    
    
}
