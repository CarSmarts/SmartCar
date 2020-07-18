//
//  M2SmartParser.swift
//  SmartCar
//
//  Created by Robert Smith on 7/18/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import Foundation
import CANHack

fileprivate struct OffsetData {
    typealias Index = Data.Index
    var data: Data
    var offset: Index
    
    subscript(index: Index) -> UInt8 {
        return data[index + offset]
    }
    
    subscript(bounds: ClosedRange<Index>) -> Data {
        return data[offset + bounds.lowerBound ... offset + bounds.upperBound]
    }
    
    subscript(bounds: Range<Index>) -> Data {
        return data[offset + bounds.lowerBound ..< offset + bounds.upperBound]
    }

    var count: Int {
        return data.count - offset
    }
    
    var remainder: Data {
        return data[offset...]
    }
}

class M2SmartParser {
    var dataBuffer = Data()

    func serialize(id: MessageID) -> UInt32 {
        var value = id.rawValue
        if id.extended {
            value |= 1 << 31
        }
        return value
    }
    
    func deserialize(id: Data) -> MessageID? {
        guard let idBytes = UInt32.from(bytes: id) else { return nil }
        guard var id = MessageID(rawValue: idBytes) else { return nil }
        
        if (id.rawValue & 1 << 31) > 0 {
            //            id.extended = true
            id.rawValue &= 0x7FFFFFFF // largest posible 11 bit extended id
        }
        return id
    }
    
    func parseCommand(_ data: Data) {
        // scan through the data until we find the start of a command
        guard let startIndex = (dataBuffer + data).firstIndex(of: 0xF1) else { return }
        let data = OffsetData(data: data, offset: startIndex)
        
        while (data.count >= 2) {
            guard let command = M2SmartCommand(rawValue: data[1]) else {
                break // invalid command bit
            }
            
            switch command {
            case .SendFrame:
                // frame
                // todoChecksum
                guard data.count >= 10 else { break }
                guard let micros = UInt32.from(bytes: data[2...5]) else { break }
                guard let id = deserialize(id: data[6...9]) else { continue }
                let len = Int(data[10] & 0x0F)
    //            let bus = data[10] & 0xF0
                guard data.count >= 11 + len + 1 else { break }
                
                let recivedMessage = Message(id: id, contents: Array(data[11 ..< 11 + len]))
                
                frames.send(SignalInstance(signal: recivedMessage, timestamp: Timestamp(micros/1000)))
                
            default:
                // do nothing
                break
            }
        }
        
        // save remaing data and prepend it to next message
        dataBuffer = data.remainder
    }
}
