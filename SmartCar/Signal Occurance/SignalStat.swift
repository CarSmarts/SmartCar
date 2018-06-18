//
//  SignalStat.swift
//  SmartCar
//
//  Created by Robert Smith on 11/14/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

/// Combined statisitics for a Signal, basically just a list of timestamps when it happened
public struct SignalStat<S: Signal>: Hashable, Codable {
    public let signal: S
    public let timestamps: [Timestamp]
}

extension SignalStat: Comparable {
    public static func <(lhs: SignalStat<S>, rhs: SignalStat<S>) -> Bool {
        if lhs.signal == rhs.signal {
            return lhs.timestamps < rhs.timestamps
        } else {
            return lhs.signal < rhs.signal
        }
    }
}

extension SignalStat: CustomStringConvertible {
    public var description: String {
        // 120x [Signal Description]
        return "\(timestamps.count)x \(signal)"
    }
}