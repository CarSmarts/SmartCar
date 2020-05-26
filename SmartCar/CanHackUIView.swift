//
//  CanHackUIView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import Combine
import CANHack
import CANHackUI
import SmartCarUI

struct CanHackUIView: View {
    var vehicle: Vehicle?
    var decoder: CarDecoder = CarDecoder([])
    @EnvironmentObject var pickerObject: PickerObject
    
    var body: some View {
        NavigationView {
            Group {
                Unwrap<SignalSet<Message>, MessageSetView>(pickerObject.chosenSet) { messageSet in
                    MessageSetView(model: CanBusModel(signalSet: messageSet, decoder: self.decoder))
                }
            }
            .navigationBarTitle("CANHack")
            .navigationBarItems(trailing: Button(
                action: {
                    self.pickerObject.isPresented = true
                },
                label: { Text("Choose File") }
            ))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CanHackUIView_Previews: PreviewProvider {
    static var previews: some View {
        CanHackUIView()
    }
}
