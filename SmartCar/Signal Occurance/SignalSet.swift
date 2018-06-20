//
//  SignalSet.swift
//  CANHack
//
//  Created by Robert Smith on 6/19/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

/// A set of Signals, collected for the purpose of analysis
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
        
        timestamps = [Timestamp]()
        
        for signalOccurance in signalOccurances {
            let timestamp = signalOccurance.timestamp
            let signal = signalOccurance.signal
            
            messageDict[signal, default: []].append(timestamp)
            
            timestamps.append(timestamp)
        }
        
        stats = messageDict.map { (arg) -> SignalStat<S> in
            let (signal, timestamps) = arg
            return SignalStat(signal: signal, timestamps: Array(timestamps))
        }
        
        stats.sort()
        timestamps.sort()
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
