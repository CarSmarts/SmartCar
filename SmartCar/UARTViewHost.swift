//
//  UARTViewHost.swift
//  SmartCar
//
//  Created by Robert Smith on 4/19/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import Combine



struct UARTViewHost: View {
    let uartService: UARTServiceUI
    @State var inputText: String = ""
        
    init(uartService: UARTService) {
        self.uartService = UARTServiceUI(uartService: uartService)
    }
    
    fileprivate func parseHexString(_ text: String) -> Data {
        var hexData = Data()
        
        for utf8 in text.utf8 {
            if let hexDigit = UInt8(String(utf8), radix: 16) {
                hexData.append(hexDigit)
            }
        }
        
        return hexData
    }
    
    func sendText() {
        let text = inputText
        let dataToSend: Data
        
        if uartService.hexMode {
            dataToSend = parseHexString(text)
        } else {
            dataToSend = text.data(using: .ascii) ?? Data()
        }
        
        uartService.uartService.txBuffer = dataToSend
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextView()
                TextField(uartService.hexMode ? "Hex" : "Text", text: $inputText, onCommit: sendText)
            }
            .navigationBarTitle("UART", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                // TODO: tell presenting view to dismiss us
            }) {
                Text("Done").bold()
            })
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct UARTViewHost_Previews: PreviewProvider {
    static var previews: some View {
        return UARTViewHost(uartService: MockVehicle().uartService!)
    }
}
