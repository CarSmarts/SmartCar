//
//  Message.swift
//  CANHack
//
//  Created by Robert Smith on 6/18/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

/// A specific instance of a network message.
public struct Message: Codable {
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

// - MARK: Timed Message

public typealias Timestamp = Int

/// A specific instance of `Message`, with a timestamp
public struct MessageInstance: Codable {
    /// Timestamp associated with the message, usually in milliseconds since startup
    var timestamp: Timestamp
    
    /// The message that occured at `timestamp`
    var message: Message
    
    public init(timestamp: Timestamp, message: Message) {
        self.timestamp = timestamp
        self.message   = message
    }
    
    public init(timestamp: Timestamp, id: MessageID, data: [Byte]) {
        self.init(timestamp: timestamp, message: Message(id: id, contents: data))
    }
}

extension Message: Hashable {
    public var hashValue: Int {
        // TODO: better hash algorithm?
        return id.hashValue + contents.hashValue
    }
    
    static public func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id && lhs.contents == rhs.contents
    }
}

extension Message: CustomStringConvertible {
    public var description: String {
        return "\(id.hex): " + contents.map { $0.hex }.joined(separator: " ")
    }
}

extension MessageInstance: CustomStringConvertible {
    public var description: String {
        return "\(timestamp) \(message)"
    }
}

extension Message: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
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

