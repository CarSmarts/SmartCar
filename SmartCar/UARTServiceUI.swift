//
//  UARTServiceUI.swift
//  SmartCar
//
//  Created by Robert Smith on 4/20/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class UARTServiceUI: ObservableObject {
    let uartService: UARTService
    var subs: Set<AnyCancellable> = []

    internal init(uartService: UARTService) {
        self.uartService = uartService
        
        uartService.$rxBuffer.sink {
            self.append(data: $0, bold: false)
        }
        .store(in: &subs)
        
        uartService.$txBuffer.sink {
            self.append(data: $0, bold: true)
        }
        .store(in: &subs)
    }
    
    @Published var hexMode = false
    @Published var humanOutput = NSAttributedString()
    
    private func append(data: Data, bold: Bool) {
        var stringToAppend = data.map {
            String(format: "%02hhX", $0)
        }.joined(separator: " ")
        
        if humanOutput.length > 0 {
            stringToAppend = " " + stringToAppend
        }
        
        append(string: stringToAppend, bold: bold)
    }
        
    private func append(string: String, bold: Bool) {
        let mutableString = NSMutableAttributedString(attributedString: humanOutput)
        
        let new = NSAttributedString(string: string, attributes: [NSAttributedString.Key.font : font(bold)])
        
        mutableString.append(new)
        humanOutput = NSAttributedString(attributedString: mutableString)
    }
    
    private func font(_ bold: Bool) -> UIFont{
        let font = UIFont.preferredFont(forTextStyle: .body)
        var descriptor = font.fontDescriptor
                
        if bold {
            descriptor = descriptor.withSymbolicTraits(.traitBold)!
        } else {
            
        }
                
        return UIFont(descriptor: descriptor.withSymbolicTraits(.traitBold)!, size: font.pointSize)
    }

}

