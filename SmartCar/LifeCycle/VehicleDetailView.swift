//
//  VehicleDetailView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/20/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import SmartCarUI
import CANHackUI
import CANHack

struct VehicleDetailView: View  {
    @EnvironmentObject var vehicleManager: VehicleManager
    @EnvironmentObject var canHackManager: CANHackManager
    @ObservedObject var vehicle: Vehicle
    
    var body: some View {
        VStack {
            Spacer()
            CommandView()
            Spacer()
            HStack {
                Unwrap(vehicle.uartService) { uartService in
                    NavigationLink("UART", destination: UARTView(uartService: uartService)
                    )
                }.padding()
                Spacer()
                Unwrap(vehicle.m2SmartService) { m2SmartService in
                    NavigationLink("CANHack", destination: MessageSetView(document: self.canHackManager.scratch, decoder: self.canHackManager.decoderBinding )
                        .onReceive(m2SmartService.frames) { newInstance in
                            self.canHackManager.scratch.activeSignalSet.add(newInstance)
                        }
                    )
                }.padding()
            }
        }
        .onTapGesture {
            self.send(.lock)
        }
        .onTapGesture(count: 2) {
            self.send(.unlock)
        }
        .onAppear {
            // make sure we connect if not already..
            self.vehicleManager.connect(to: self.vehicle)
        }
        .navigationBarTitle(vehicle.name)
    }
    
    func send(_ command: Command) {
        vehicle.smartLock?.send(command)
    }
}

extension VehicleDetailView: SmartLockDelegate {
    func smartLock(_ smartLock: SmartLock, didSend command: Command, error: Error?) {
//        commandView.complete()
//
//        if let error = error {
//            //TODO: Better error messages?
//            commandView.error(message: error.localizedDescription)
//        }
    }
}


struct VehicleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let vehicleView = VehicleDetailView(vehicle: MockVehicle())
        
        return NavigationView {
            vehicleView
        }.environmentObject(VehicleManager(uniqueID: "previewManager"))
    }
}
