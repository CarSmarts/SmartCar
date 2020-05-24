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
    @EnvironmentObject var uartService: UARTServiceUI
    @Environment(\.colorScheme) var colorScheme
    
    var text: NSAttributedString {
        return uartService.humanOutput
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
        textView.attributedText = text
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView
        
        init(_ parent: TextView) {
            self.parent = parent
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return false
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView().environmentObject(UARTService(vehicle: MockVehicle()))
    }
}
