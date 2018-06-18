//
//  GVRET.swift
//  SmartCar
//
//  Created by Robert Smith on 6/18/18.
//  Copyright © 2018 Robert Smith. All rights reserved.
//

import Foundation

/// Class for Parsing GVRet csv logs
class GVRetParser: Parser {
    typealias S = Message
    
    private func computeLenIndex(for possibleRx: String) -> Int {
        if possibleRx.count > 1 {
            // Rx/Tx present
            return 5
        } else {
            return 4
        }
    }
    
    func parse(line: String) -> SignalOccurance<S>? {
        // 4210,0x12F85150,true,Rx,1,2,40,00
        // timestamp,id,extended?,Rx/Tx(optional),bus,len,data
        let components = line.components(separatedBy: ",")
        let lenIndex = computeLenIndex(for: components[3])

        guard let timestamp = Timestamp(components[0]) else { return nil }
        guard let id = MessageID.from(hex: components[1]) else { return nil }
        guard let len = Int(components[lenIndex]) else { return nil }
        
        let data = components[(lenIndex + 1)...].compactMap { Byte.from(hex: $0) }
        
        guard data.count == len else { return nil}
        
        return SignalOccurance<S>(signal: Message(id: id, contents: data), timestamp: timestamp)
    }
}
