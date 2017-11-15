//
//  Parsing.swift
//  CANHack
//
//  Created by Robert Smith on 6/20/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

public enum ParseError: Error {
    case timestampNotFound
    case idNotFound
    case invalidHex(String)
}

extension String {
    mutating func dropPrefix(matching expression: String, options: NSString.CompareOptions = [.caseInsensitive]) -> String? {
        guard let range = range(of: expression, options: options.union(.regularExpression)) else { return nil }
        let sub = self[range]
        removeSubrange(..<range.upperBound)
        return String(sub)
    }
}

private func parse(data: String) throws -> Byte {
    if let parsedData = Byte.from(hex: data) {
        return parsedData
    } else {
        throw ParseError.invalidHex(data)
    }
}

private func parse(id: String) throws -> MessageID {
    if let parsedID = MessageID.from(hex: id) {
        return parsedID
    } else {
        throw ParseError.invalidHex(id)
    }
}

public extension SignalSet where S == Message {
    /// Create a SignalSet by parsing multiple lines of text
    convenience init (from file: String) {
        let lines = file.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        // map every line into a parsed message
        let parsed = lines.flatMap { line -> SignalOccurance<S>? in
            do {
                return try SignalOccurance<S>(from: line)
            } catch {
                // TODO: Better way to report bad lines when parsing
                // if the message doesn't work, print it and remove it from the list of messages
                print(line, error)
                return nil
            }
        }
        
        self.init(signalOccurances: parsed)
    }
}

// TODO: Make this generic
public extension SignalOccurance where S == Message {
    /// Create a MessageInstance by parsing text
    init(from text: String) throws {
        var text = text
        guard let timeString = text.dropPrefix(matching: "[0-9]+") else {throw ParseError.timestampNotFound }
        
        // Assume that a string of numbers is always convertable to an int
        timestamp = Timestamp(timeString)!
        
        signal = try Message.init(from: text)
    }
}

public extension Message {
    /// Create a Message by parsing text
    init(from text: String) throws {
        var text = text
        
        guard let idString = text.dropPrefix(matching: "0x([A-F0-9]{7,8})(?![A-F0-9])") else { throw ParseError.idNotFound }
        id = try parse(id: idString)
        
        if let dataString = text.dropPrefix(matching: "([A-F0-9]{2})(, ?[A-F0-9]{2})*$") {
            contents = try dataString.components(separatedBy: ",").map { component in
                try parse(data: component.trimmingCharacters(in: .whitespaces))
            }
        } else {
            contents = []
        }
    }
}
