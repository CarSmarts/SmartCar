//
//  GroupedSignalSet.swift
//  SmartCar
//
//  Created by Robert Smith on 11/15/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

public typealias Grouping = Signal

public struct GroupedStat<S: Signal, G: Grouping>: Hashable, Codable {
    public let group: G
    public let stats: [SignalStat<S>]
}

/// A set of messages, collected for the purpose of analysis
public class GroupedSignalSet<S: Signal, G: Grouping>: Codable {
    
    private var originalSignalSet: SignalSet<S>
    private var groupedStats: [G: [SignalStat<S>]]
    
    /// Sorted list of groups contained by this class
    public private(set) var groups: [G]
    
    /// Access a grouped stat for a specific group
    ///
    /// - traps if `group` is not part of this classes `groups` array
    public subscript (_ group: G) -> GroupedStat<S, G> {
        return GroupedStat<S, G>(group: group, stats: groupedStats[group]!)
    }
    
    /// A mapping of messages to the times they occur
    public var stats: [SignalStat<S>] {
        return originalSignalSet.stats
    }
    
    public var timestamps: [Timestamp] {
        return originalSignalSet.timestamps
    }
    
    /// The first timestamp in this dataset
    public var firstTimestamp: Timestamp {
        return timestamps.first ?? 0
    }
    
    /// The last timestamp in this dataset
    public var lastTimestamp: Timestamp {
        return timestamps.last ?? 0
    }
    
    public init(grouping original: SignalSet<S>, by groupingFunction: (SignalStat<S>) -> G) {
        originalSignalSet = original
        
        groupedStats = Dictionary(grouping: original.stats, by: groupingFunction)
        
        groups = groupedStats.keys.sorted()
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
