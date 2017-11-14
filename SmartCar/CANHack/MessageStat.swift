//
//  MessageStat.swift
//  SmartCar
//
//  Created by Robert Smith on 11/11/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

public struct MessageStat: Codable {
    public private(set) var message: Message
    public var timestamps: [Timestamp]
}

extension MessageStat: Hashable {
    public var hashValue: Int {
        return message.hashValue
    }
    
    static public func ==(lhs: MessageStat, rhs: MessageStat) -> Bool {
        return lhs.message == rhs.message && lhs.timestamps == rhs.timestamps
    }
}

extension MessageStat: CustomStringConvertible {
    public var description: String {
        // 120x 0xAF81111: 00, 08
        return "\(timestamps.count)x \(message)"
    }
}
