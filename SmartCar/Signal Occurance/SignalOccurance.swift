//
//  SignalOccurance.swift
//  SmartCar
//
//  Created by Robert Smith on 11/14/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

public typealias Timestamp = Int

public struct SignalOccurance<S: Signal>: Codable {
    var signal: S
    var timestamp: Timestamp
}

extension SignalOccurance: CustomStringConvertible {
    public var description: String {
        return "\(timestamp) \(signal)"
    }
}
