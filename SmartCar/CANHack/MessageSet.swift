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
    public private(set) var stats: [MessageStat]
    
    /// The first timestamp in this dataset
    public var firstTimestamp: Timestamp {
        return timestamps.first ?? 0
    }
    
    /// The last timestamp in this dataset
    public var lastTimestamp: Timestamp {
        return timestamps.last ?? 0
    }
    
    public private(set) var timestamps: [Timestamp]
    
    public private(set) var histogramController: HistogramController
    
    public init(messageList: [MessageInstance]) {
        
        // TODO: all this trash is supposed to make this faster.. did it?
        let messages = messageList.lazy.map { ($0.message, Set([$0.timestamp]))}

        let messageDict = Dictionary(messages, uniquingKeysWith: { k1, k2 in k1.union(k2) })
        
        stats = messageDict.map { (arg) -> MessageStat in
            let (message, timestamps) = arg
            return MessageStat(message: message, timestamps: Array(timestamps))
        }
        
        stats.sort(by: { $0.message < $1.message })
        
        let allTimestamps = messageDict.values.reduce(Set(), { (t1, t2) in t1.union(t2) })
        timestamps = allTimestamps.sorted()
        
        let scale = HistogramScale(using: timestamps)
        histogramController = HistogramController(data: stats.map { $0.timestamps }, scale: scale)
    }
    
}

extension MessageSet: Equatable {
    public static func ==(lhs: MessageSet, rhs: MessageSet) -> Bool {
        return lhs.stats == rhs.stats
    }
}

extension MessageSet: CustomStringConvertible {
    public var description: String {
        return stats.map { $0.description }.joined(separator: "\n")
    }
}

