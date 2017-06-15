//
//  CommandView.swift
//  SmartCar
//
//  Created by Robert Smith on 5/1/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

class CommandView: UILabel {
    // TODO: add nice animations to CommandView
    override func willMove(toSuperview newSuperview: UIView?) {
        text = ""
    }
    
    public func display(sending command: Command) {
        text = command.description
        textColor = .orange
    }
    
    public func error(message: String) {
        text = message
        textColor = .red
    }
    
    public func complete() {
        textColor = .darkText
    }
}

extension Command {
    public var description: String
    {
        switch self {
        case .cancel:
            return ""
        case .lock:
            return "Lock"
        case .unlock, .driver:
            return "Unlock"
        case .windowUp:
            return "Windows Up"
        case .windowDown:
            return "Windows Down"
        }
    }
}
