//
//  UARTView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/19/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import Combine

extension Sequence {
    func clump(by clumpsize:Int) -> [[Element]] {
        let slices : [[Element]] = self.reduce(into:[]) {
            memo, cur in
            if memo.count == 0 {
                return memo.append([cur])
            }
            if memo.last!.count < clumpsize {
                memo.append(memo.removeLast() + [cur])
            } else {
                memo.append([cur])
            }
        }
        return slices
    }
}

struct UARTView: View {
    @ObservedObject var uartService: UARTServiceUI
    @State var inputText: String = ""
        
    init(uartService: UARTService) {
        self.uartService = UARTServiceUI(uartService: uartService)
    }
    
    fileprivate func parseHexString(_ text: String) -> Data {
        var hexData = Data()
        
        let byteStrings = text
            .filter { character in
                !character.isWhitespace
            }.clump(by: 2)
        
        for chars in byteStrings {
            if let hexDigit = UInt8(String(chars), radix: 16) {
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
            dataToSend = (text + "\n").data(using: .ascii) ?? Data()
        }
        
        uartService.uartService.txBuffer = dataToSend
    }
    
    var body: some View {
        VStack {
            TextView(uartService: uartService).padding()
            
            TextField(uartService.hexMode ? "Hex" : "Text", text: $inputText, onCommit: sendText).padding()
            .modifier(AdaptsToKeyboard())
        }
        .navigationBarTitle("UART", displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            ClearButton(uartService: uartService)
            HexModeButton(uartService: uartService)
        })
    }
}

struct ClearButton: View {
    @ObservedObject var uartService: UARTServiceUI
    
    var body: some View {
        Button(action: { self.uartService.clear() }) { Text("Clear") }
    }
}

struct HexModeButton: View {
    @ObservedObject var uartService: UARTServiceUI
    
    var body: some View {
        Button(action: {
                self.uartService.hexMode = !self.uartService.hexMode
                }) {
                    if self.uartService.hexMode {
                        Text("Hex")
                    } else {
                        Text("UTF-8")
                    }
                }
    }
}

struct AdaptsToKeyboard: ViewModifier {
    @State var currentHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, self.currentHeight)
            .animation(.easeOut(duration: 0.16))
            .onAppear(perform: {
                NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillShowNotification)
                    .merge(with: NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillChangeFrameNotification))
                    .compactMap { notification in
                        notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
                }
                .map { rect in
                    rect.height// - geometry.safeAreaInsets.bottom
                }
                .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))

                NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillHideNotification)
                    .compactMap { notification in
                        CGFloat.zero
                }
                .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
            })
    }
}

struct UARTViewHost_Previews: PreviewProvider {
    static var previews: some View {
        return UARTView(uartService: MockVehicle().uartService!)
    }
}
