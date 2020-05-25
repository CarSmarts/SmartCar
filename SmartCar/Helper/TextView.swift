//
//  TextView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/19/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import Combine

struct TextView: UIViewRepresentable {
    @ObservedObject var uartService: UARTServiceUI
    @Environment(\.colorScheme) var colorScheme
    
    func correctColor(_ string: NSAttributedString) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: string)
        
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: mutableString.length))
        
        return NSAttributedString(attributedString: mutableString)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView(frame: .zero)
        view.delegate = context.coordinator
        view.textColor = .label
        view.font = .preferredFont(forTextStyle: .body)

        return view
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.attributedText = uartService.hexMode ? correctColor(uartService.hexOutput) : correctColor(uartService.utf8Output)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView
        
        init(_ parent: TextView) {
            self.parent = parent
        }
        
        func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            return false
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return false
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        let service = UARTServiceUI(uartService: UARTService(vehicle: MockVehicle()))
            
        return TextView(uartService: service)
    }
}
