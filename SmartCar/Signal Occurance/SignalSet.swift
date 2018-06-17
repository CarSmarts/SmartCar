//
//  SignalSet.swift
//  CANHack
//
//  Created by Robert Smith on 6/19/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

/// A set of messages, collected for the purpose of analysis
public class SignalSet<S: Signal>: Codable {
    /// A mapping of messages to the times they occur
    public private(set) var stats: [SignalStat<S>]
    
    /// The first timestamp in this dataset
    public var firstTimestamp: Timestamp {
        return timestamps.first ?? 0
    }
    
    /// The last timestamp in this dataset
    public var lastTimestamp: Timestamp {
        return timestamps.last ?? 0
    }
    
    public private(set) var timestamps: [Timestamp]
    
    public init(signalOccurances: [SignalOccurance<S>]) {
        
        var messageDict = [S : [Timestamp]]()
        
        for signalOccurance in signalOccurances {
            if messageDict[signalOccurance.signal] != nil {
                messageDict[signalOccurance.signal]?.append(signalOccurance.timestamp)
            } else {
                messageDict[signalOccurance.signal] = [signalOccurance.timestamp]
            }
        }
        
        stats = messageDict.map { (arg) -> SignalStat<S> in
            let (signal, timestamps) = arg
            return SignalStat(signal: signal, timestamps: Array(timestamps))
        }

        stats.sort()

        let allTimestamps = messageDict.values.reduce(Set(), { (t1, t2) in t1.union(t2) })
        timestamps = allTimestamps.sorted()
    }
}

extension SignalSet {
    public var scale: OccuranceGraphScale {
        return OccuranceGraphScale(min: firstTimestamp, max: lastTimestamp)
    }
}

extension SignalSet: Equatable {
    public static func ==(lhs: SignalSet, rhs: SignalSet) -> Bool {
        return lhs.stats == rhs.stats
    }
}

extension SignalSet: CustomStringConvertible {
    public var description: String {
        return stats.map { $0.description }.joined(separator: "\n")
    }
}

