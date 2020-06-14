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

class UARTServiceUI: ObservableObject, CustomStringConvertible {
    private static let hexModeKey = "hexMode"
    let uartService: UARTService
    var subs: Set<AnyCancellable> = []

    internal init(uartService: UARTService) {
        self.uartService = uartService
        self.hexMode = UserDefaults.standard.value(forKey: Self.hexModeKey) as? Bool ?? false
        
        self.$hexMode.sink { hexMode in
            UserDefaults.standard.set(hexMode, forKey: Self.hexModeKey)
        }
        .store(in: &subs)
        
        uartService.$rxBuffer.sink {
            self.append(data: $0, bold: false)
        }
        .store(in: &subs)
        
        uartService.$txBuffer.sink {
            self.append(data: $0, bold: true)
        }
        .store(in: &subs)
    }
    
    @Published var hexMode: Bool
    
    @Published var hexOutput = NSAttributedString()
    @Published var utf8Output = NSAttributedString()

    func clear() {
        uartService.clear()
        
        hexOutput = NSAttributedString()
        utf8Output = NSAttributedString()
    }
    
    private func append(data: Data, bold: Bool) {
       var stringToAppend = data.map {
            String(format: "%02hhX", $0)
        }.joined(separator: " ")
        
        if hexOutput.length > 0 {
            stringToAppend = " " + stringToAppend
        }
        hexOutput = hexOutput.append(string: stringToAppend, bold: bold)
        
        if let utf8StringToAppend = String(data: data, encoding: .utf8) {
             utf8Output = utf8Output.append(string: utf8StringToAppend, bold: bold)
        }
    }

    var description: String {
        return """
        UARTServiceUI: \(hexMode ? "hexMode" : "utf8Mode")
        uartService: \(uartService.description)
        """
    }
}

fileprivate extension NSAttributedString {
    
    private func font(_ bold: Bool) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: .body)
        var descriptor = font.fontDescriptor
                
        if bold {
            descriptor = descriptor.withSymbolicTraits(.traitBold)!
        }
                
        return UIFont(descriptor: descriptor, size: font.pointSize)
    }
    
    func append(string: String, bold: Bool) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: self)
        
        let new = NSAttributedString(string: string, attributes: [NSAttributedString.Key.font : font(bold)])
        
        mutableString.append(new)
        return NSAttributedString(attributedString: mutableString)
    }
}
