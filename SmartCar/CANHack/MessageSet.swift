//
//  MessageSet.swift
//  CANHack
//
//  Created by Robert Smith on 6/19/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

/// A set of messages, collected for the purpose of analysis
public class MessageSet: Codable {
    /// A mapping of messages to the times they occur
    public private(set) var stats: [Message : Set<Timestamp>]
    
    /// The first timestamp in this dataset
    public private(set) var firstTimestamp: Timestamp
    /// The last timestamp in this dataset
    public private(set) var lastTimestamp: Timestamp
    
    public init(messageList: [MessageInstance]) {
        let messages = messageList.lazy.map { ($0.message, Set([$0.timestamp]))}

        stats = Dictionary(messages, uniquingKeysWith: { k1, k2 in k1.union(k2) })
        
        // Find first and last timestamps
        let timestamps = messageList.lazy.map { $0.timestamp }
        lastTimestamp = timestamps.reduce(0, max)
        firstTimestamp = timestamps.reduce(lastTimestamp, min)
    }
}

// MARK: Different accessors
public extension MessageSet {
    /// Returns the frequences of every message
    func frequencies() -> [Message: Int] {
        return stats.mapValues { $0.count }
    }
    
    /// Returns the stats dictionary grouped by the value at `keypath` for every message
    func grouped<T>(by keypath: KeyPath<Message, T>) -> [T: [Message: Set<Timestamp>]] {
        return grouped {message, _ in message[keyPath: keypath]}
    }
    
    /// Returns the stats dictionary grouped by the value returned by `keyForStat`
    func grouped<T>(_ keyForStat: (_ message: Message, _ timestamps: Set<Timestamp>) throws -> T) rethrows -> [T: [Message: Set<Timestamp>]] {
        // perform grouping
        let grouped = try Dictionary(grouping: stats, by: { try keyForStat($0.key, $0.value) })
        
        // map values back into a dictionary, rather than a sequence
        let mapped = grouped.mapValues { elements in
            Dictionary(uniqueKeysWithValues: elements.map { (key: $0.0, value: $0.1)})
        }
        
        return mapped
    }
}

extension MessageSet: Equatable {
    public static func ==(lhs: MessageSet, rhs: MessageSet) -> Bool {
        return lhs.stats == rhs.stats
    }
}

extension MessageSet: CustomStringConvertible {
    public var description: String {
        //                      // Greatest first                          // 120x 0xAF81111: 00, 08
        return stats.sorted(by: { $0.value.count < $1.value.count }).map {"\($0.value.count)x \($0.key)"}.joined(separator: "\n")
    }
}

