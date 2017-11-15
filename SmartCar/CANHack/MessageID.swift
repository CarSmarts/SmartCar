//
//  MessageID.swift
//  SmartCar
//
//  Created by Robert Smith on 6/27/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

public struct MessageID : RawRepresentable, Signal, Codable {
    public typealias RawValue = UInt32
    
    public var rawValue: UInt32
    
    public init?(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

public extension MessageID {
    /// A list of the bytes that make up `self`
    var bytes: [Byte] {
        return [
            Byte(rawValue >> 24),
            Byte(rawValue >> 16 & 0xFF),
            Byte(rawValue >> 8 & 0xFF),
            Byte(rawValue & 0xFF),
        ]
    }
    
    /// Accesses the byte at `index`
    ///
    /// Identical to `bytes[index]`
    subscript(index: Int) -> Byte {
        return bytes[index]
    }
    
    /// A human readable hex representation of `self`
    var hex: String {
        return String(format: "%X", rawValue)
    }
    
    /// Creates am instance of `self` from a hex string
    static func from(hex: String) -> MessageID? {
        guard let value = RawValue(hex.dropping(prefix: "0x"), radix: 16) else { return nil }
        
        return MessageID(rawValue: value)
    }
}

extension MessageID: Hashable {
    public var hashValue: Int {
        return rawValue.hashValue
    }
}

extension MessageID: Comparable {
    public static func <(lhs: MessageID, rhs: MessageID) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension MessageID: CustomStringConvertible {
    public var description: String {
        return hex
    }
}
