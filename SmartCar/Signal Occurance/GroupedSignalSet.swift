//
//  GroupedSignalSet.swift
//  SmartCar
//
//  Created by Robert Smith on 11/15/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

public protocol Grouping: Hashable, Comparable, Codable { }

/// A set of messages, collected for the purpose of analysis
public class GroupedSignalSet<S: Signal, G: Grouping>: Codable {
    
    private var originalSignalSet: SignalSet<S>
    
    public let groupings: [G]
    
    public let statsForGrouping: [G: [SignalStat<S>]]
    
    /// A mapping of messages to the times they occur
    public var stats: [SignalStat<S>] {
        return originalSignalSet.stats
    }
    
    /// The first timestamp in this dataset
    public var firstTimestamp: Timestamp {
        return timestamps.first ?? 0
    }
    
    /// The last timestamp in this dataset
    public var lastTimestamp: Timestamp {
        return timestamps.last ?? 0
    }
    
    public var timestamps: [Timestamp] {
        return originalSignalSet.timestamps
    }
    
    public init(grouping original: SignalSet<S>, by groupingFunction: (SignalStat<S>) -> G) {
        originalSignalSet = original
        
        statsForGrouping = Dictionary(grouping: original.stats, by: groupingFunction)
        
        groupings = Array(statsForGrouping.keys).sorted()
    }
}

extension GroupedSignalSet: Equatable {
    public static func ==(lhs: GroupedSignalSet, rhs: GroupedSignalSet) -> Bool {
        return lhs.originalSignalSet == rhs.originalSignalSet
    }
}

extension GroupedSignalSet: CustomStringConvertible {
    // FIXME:
    public var description: String {
        return stats.map { $0.description }.joined(separator: "\n")
    }
}
