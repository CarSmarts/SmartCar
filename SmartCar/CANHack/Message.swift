//
//  Message.swift
//  CANHack
//
//  Created by Robert Smith on 6/18/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

/// A specific instance of a network message.
public struct Message: Signal, Codable {
    /// The id of the message.
    public var id: MessageID
    /// The message contents
    public var contents: [Byte]
    
    /// The length of the message (number of bytes)
    public var length: Int {
        return contents.count
    }
    
    public init(id: MessageID, contents: [Byte]) {
        self.id = id
        self.contents = contents
    }
}

extension Message: Hashable, Comparable {
    public var hashValue: Int {
        // TODO: better hash algorithm?
        return id.hashValue + contents.hashValue
    }
    
    static public func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id && lhs.contents == rhs.contents
    }
    
    public static func <(lhs: Message, rhs: Message) -> Bool {
        if lhs.id == rhs.id {
            for (left, right) in zip(lhs.contents, rhs.contents) {
                if left != right {
                    return left < right
                }
            }
            return false // equal
        }
        else {
            return lhs.id.rawValue < rhs.id.rawValue
        }
    }
}

extension Message: CustomStringConvertible {
    public var description: String {
        return "\(id.hex): " + contentDescription
    }
    
    public var contentDescription: String {
        return contents.map { $0.hex }.joined(separator: " ")
    }
}

// shortcut for getting hash value of array
private extension Collection where Element == Byte {
    var hashValue: Int {
        //TODO: Document this
        return self.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
}

