//
//  LockStateView.swift
//  SmartCar
//
//  Created by Robert Smith on 5/1/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

class LockStateView: UIButton {
    
    /// The `LockState` shown by the `LockStateView`
    private(set) var lockState = LockState.unknown {
        didSet {
            setTitle(lockState.description, for: .normal)
        }
    }
    
    /// The color of the `LockStateView`
    private(set) var color = UIColor.black {
        didSet {
            setTitleColor(color, for: .normal)
        }
    }
    
    /// Presents `newLockState` in normal format
    ///
    /// - Parameter newLockState: State to present
    public func display(_ newLockState: LockState) {
        lockState = newLockState
        color = .darkText
    }
    
    /// Presents `newLockState` in "sending" format
    ///
    /// - Parameter newLockState: State to present
    public func displaySending(_ newLockState: LockState) {
        lockState = newLockState
        color = .orange
    }
    
    /// Indicates Error
    public func error() {
        color = .red
    }
    
}

extension LockState: CustomStringConvertible {
    public var description:String
    {
        switch self {
        case .unknown:
            return "..."
        case .lock:
            return "Locked"
        case .unlock:
            return "Unlocked"
        }
    }
}
