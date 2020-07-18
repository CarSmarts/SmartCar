//
//  M2SmartParser.swift
//  SmartCar
//
//  Created by Robert Smith on 7/18/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import Foundation

public enum Bus: UInt8 {
    case CAN0 = 0
    case CAN1 = 1
    case SWCAN = 2
}

public enum M2SmartCommand: UInt8 {
    case SendFrame = 0x0
    case TimeSync = 0x1
    case GetDigitalIn = 0x2
    case GetAnalogIn = 0x3
    case SetDigitalIn = 0x4
    case SetCanConfig = 0x5
    case GetCanConfig = 0x6
    case GetDevInfo = 0x7
    case SetSWMode = 0x8
    case KeepAlive = 0x9
    case SetSysType = 0xA
    case EchoCanFrame = 0xB
}

fileprivate extension Data.Index {
    static postfix func ++(value: inout Self) -> Self {
        defer { value += 1 }
        return value
    }
}

fileprivate struct OffsetData {
    typealias Index = Data.Index
    var data: Data
    var offset: Index
    
    init(data: Data) {
        self.data = data
        self.offset = data.startIndex
    }
    
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
    
    mutating func advance(to byte: UInt8) {
        offset = data.firstIndex(of: 0xF1) ?? data.endIndex
    }
}

public class M2SmartParser {
    public init() { }
    
    private var dataBuffer = Data()

    private func serialize(id: MessageID) -> UInt32 {
        var value = id.rawValue
        if id.extended {
            value |= 1 << 31
        }
        return value
    }
    
    private func deserialize(id: Data) -> MessageID? {
        guard let idBytes = UInt32.from(bytes: id) else { return nil }
        guard var id = MessageID(rawValue: idBytes) else { return nil }
        
        if (id.rawValue & 1 << 31) > 0 {
            //            id.extended = true
            id.rawValue &= 0x7FFFFFFF // largest posible 11 bit extended id
        }
        return id
    }
    
    private func calcChecksum(of data: Data) -> UInt8 {
        //Get the value of XOR'ing all the bytes together. This creates a reasonable checksum that can be used
        //to make sure nothing too stupid has happened on the comm.
        return data.reduce(into: 0, { $0 ^= $1 })
    }
    
    public func buildSendCommand(message: Message, on bus: Bus) -> Data {
        var data = Data()
        data[0] = 0xF1
        data[1] = 0x00
        
        // copy 4 bytes of id
        for idByte in message.id.bytes.enumerated() {
            data[2+idByte.offset] = idByte.element
        }
        
        data[4] = bus.rawValue
        data[5] = UInt8(message.contents.count)
        
        for dataByte in message.contents.enumerated() {
            data[6+dataByte.offset] = dataByte.element
        }
        
        data.append(calcChecksum(of: data))

        return data
    }
        
    public func parseCommand(_ data: Data, callback: (SignalInstance<Message>) -> Void) {
        var data = OffsetData(data: dataBuffer + data)
        
        while (true) {
            // scan through the data until we find the start of a command
            data.advance(to: 0xF1)
            
            guard data.count >= 2 else {
                break
            }

            guard let command = M2SmartCommand(rawValue: data[1]) else {
                continue // invalid command bit
            }
            
            switch command {
            case .SendFrame:
                // frame
                // todoChecksum
                guard data.count >= 10 else { break }
                guard let micros = UInt32.from(bytes: data[2...5]) else { continue }
                guard let id = deserialize(id: data[6...9]) else { continue }
                let len = Int(data[10] & 0x0F)
    //            let bus = data[10] & 0xF0
                guard data.count >= 11 + len + 1 else { break }
                
                let recivedMessage = Message(id: id, contents: Array(data[11 ..< 11 + len]))
                
                callback(SignalInstance(signal: recivedMessage, timestamp: Timestamp(micros/1000)))
            
            default:
                // do nothing
                continue
            }
        }
        
        // save remaing data and prepend it to next message
        dataBuffer = data.remainder
    }
}

fileprivate extension UInt32 {
    static func from(bytes: Data) -> UInt32? {
        guard bytes.count == 4 else { return nil }
        let newBytes = bytes.map { UInt32($0) }
        
        var value = UInt32()
        
        value |= newBytes[0]
        value |= newBytes[1] << 8
        value |= newBytes[2] << 16
        value |= newBytes[3] << 24
                
        return value
    }
}
