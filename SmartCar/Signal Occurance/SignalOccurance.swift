//
//  SignalOccurance.swift
//  SmartCar
//
//  Created by Robert Smith on 11/14/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

/// Super vague, but a `Signal` is anything that could be associated with "happening" at a certain time
public protocol Signal: Hashable, CustomStringConvertible, Comparable, Codable { }

/// When a `Signal` "happened"
public typealias Timestamp = Int

/// Ties a Signal to a specific Timestamp
public struct SignalOccurance<S: Signal>: Codable {
    var signal: S
    var timestamp: Timestamp
}

extension SignalOccurance: CustomStringConvertible {
    public var description: String {
        return "\(timestamp) \(signal)"
    }
}
