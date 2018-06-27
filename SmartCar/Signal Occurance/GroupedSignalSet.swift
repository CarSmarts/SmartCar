//
//  GroupedSignalSet.swift
//  SmartCar
//
//  Created by Robert Smith on 11/15/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

public typealias Group = Signal

public class GroupedStat<S: Signal, G: Group>: InstanceList {
    public let group: G
    public private(set) var stats: [SignalStat<S>]
    public private(set) var signalList: [SignalInstance<S>]
    
    fileprivate init(_ group: G, stats: [SignalStat<S>] = []) {
        self.group = group
        self.stats = stats
        
        self.signalList = stats.flatMap { $0.signalList }.sorted(by: { first, second in first.timestamp < second.timestamp})
    }
}

/// A set of messages, collected for the purpose of analysis
public class GroupedSignalSet<S: Signal, G: Group>: InstanceList {
    private var _signalSet: SignalSet<S>
    private var _stats: [G: GroupedStat<S, G>]
    private var _groupingFunction: (SignalStat<S>) -> G

    /// Sorted list of groups in this set
    public private(set) var groups: [G]

    /// The original list of signals
    public var signalList: [SignalInstance<S>] {
        return _signalSet.signalList
    }
    
    /// Creates a GroupedSignalSet by grouping an existing SignalSet
    public init(grouping original: SignalSet<S>, by groupingFunction: @escaping (SignalStat<S>) -> G) {
        _signalSet = original
        _groupingFunction = groupingFunction
        
        let grouped = Dictionary(grouping: original.stats, by: groupingFunction)
        
        _stats = Dictionary(uniqueKeysWithValues: grouped.map {
            let (group, stats) = $0
            return (group, GroupedStat(group, stats: stats))
        })
        
        groups = _stats.keys.sorted()
    }
}

/// SignalStat getters
extension GroupedSignalSet {
    /// Access a grouped stat for a specific group
    ///
    /// - traps if `group` is not part of this classes `groups` array
    public subscript (_ group: G) -> GroupedStat<S, G> {
        return _stats[group]!
    }
    
    /// All the stats in a Collection
    public var stats: LazyMapCollection<[G], GroupedStat<S, G>> {
        return groups.lazy.map { self[$0] }
    }
}

// FIXME:
//extension GroupedSignalSet: CustomStringConvertible {
//    public var description: String {
//        return stats.map { $0.description }.joined(separator: "\n")
//    }
//}
