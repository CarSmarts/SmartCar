//
//  M2SmartService.swift
//  SmartCar
//
//  Created by Robert Smith on 4/23/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import Foundation
import Combine
import CANHack

enum M2SmartCommand: UInt8 {
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

enum Bus: UInt8 {
    case CAN0 = 0
    case CAN1 = 1
    case SWCAN = 2
}

public class M2SmartService {
    var uartService: UARTService
    
    var subs = [AnyCancellable]()
    
    init(uartService: UARTService) {
        self.uartService = uartService
        self.messageSet = SignalSet()
        
        uartService.$rxBuffer.sink(receiveValue: { data in
            self.parseM2SmartCommand(data)
        })
        .store(in: &subs)
    }
        
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
        
        if (id.rawValue & 1 << 31) == 0b1 {
//            id.extended = true
            id.rawValue &= 0x7FFFFFFF // largest posible 11 bit extended id
        }
        return id
    }
    
    var messageSet: SignalSet<Message>
    
    var frames = PassthroughSubject<SignalInstance<Message>, Never>()
    
    func parseM2SmartCommand(_ data: Data) {
        // scan through the data until we find the start of a command
        guard let offset = data.firstIndex(of: 0xF1) else { return }
        
        guard data.count - offset >= 2 else {
            return // out of data
        }
                
        let offsetData = data[offset...]
        
        guard let command = M2SmartCommand(rawValue: offsetData[1]) else {
            return // invalid command bit
        }
        
        switch command {
        case .SendFrame:
            // frame
            // todoChecksum
            guard data.count >= 10 else { return }
            guard let micros = UInt32.from(bytes: offsetData[2...5]) else {
                return
            }
            guard let id = deserialize(id: offsetData[6...9]) else {
                return // fail
            }
            let len = offsetData[10] & 0x0F
//            let bus = data[10] & 0xF0
            guard 11 + len + 1 == offsetData.count else { return }
            let recivedMessage = Message(id: id, contents: Array(offsetData[11 ..< 11 + len]))
            
            frames.send(SignalInstance(signal: recivedMessage, timestamp: Timestamp(micros/1000)))
            
        default:
            // do nothing
            break
        }
    }
    
    private func calcChecksum(of data: Data) -> UInt8 {
        //Get the value of XOR'ing all the bytes together. This creates a reasonable checksum that can be used
        //to make sure nothing too stupid has happened on the comm.
        return data.reduce(into: 0, { $0 ^= $1 })
    }
    
    func send(message: Message, on bus: Bus) {
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
        
        uartService.txBuffer = data;
    }
}

extension UInt32 {
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
