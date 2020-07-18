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

public class M2SmartService {
    var uartService: UARTService
    var m2SmartParser = M2SmartParser()
    
    var subs = [AnyCancellable]()
    
    init(uartService: UARTService) {
        self.uartService = uartService
        self.messageSet = SignalSet()
        
        uartService.$rxBuffer.sink(receiveValue: { data in
            self.m2SmartParser.parseCommand(data) { frame in
                self.frames.send(frame)
            }
        })
        .store(in: &subs)
    }
    
    var messageSet: SignalSet<Message>
    
    var frames = PassthroughSubject<SignalInstance<Message>, Never>()
    
    func send(message: Message, on bus: Bus) {
        uartService.txBuffer = m2SmartParser.buildSendCommand(message: message, on: bus)
    }
}
