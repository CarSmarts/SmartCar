//
//  SignalStat.swift
//  SmartCar
//
//  Created by Robert Smith on 11/14/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

public struct SignalStat<S: Signal>: Codable {
    public private(set) var signal: S
    public private(set) var timestamps: [Timestamp]
    
    init(signal: S, timestamps: [Timestamp]) {
        self.signal = signal
        self.timestamps = timestamps
    }
}

extension SignalStat: Hashable {
    public var hashValue: Int {
        return signal.hashValue
    }
    
    static public func ==(lhs: SignalStat, rhs: SignalStat) -> Bool {
        return lhs.signal == rhs.signal && lhs.timestamps == rhs.timestamps
    }
}

extension SignalStat: Comparable {
    public static func <(lhs: SignalStat<S>, rhs: SignalStat<S>) -> Bool {
        return lhs.signal < rhs.signal
    }
}

extension SignalStat: CustomStringConvertible {
    public var description: String {
        // 120x [Signal Description]
        return "\(timestamps.count)x \(signal)"
    }
}
