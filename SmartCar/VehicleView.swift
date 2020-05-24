//
//  VehicleView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/20/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI

struct Unwrap<Value, Content: View>: View {
    private let value: Value?
    private let contentProvider: (Value) -> Content

    init(_ value: Value?,
         @ViewBuilder content: @escaping (Value) -> Content) {
        self.value = value
        self.contentProvider = content
    }

    var body: some View {
        value.map(contentProvider)
    }
}

struct VehicleView: View  {
    @EnvironmentObject var vehicleManager: VehicleManager
    @State var showUART = false
    @State var showCANHACK = false
    
    
    var vehicle: Vehicle? {
        didSet {
            vehicle?.delegate = self
        }
    }
    
    var commandView: CommandView!
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Hello, World!")
                Spacer()
                HStack {
                    EmptyView()
                    Unwrap(vehicle?.uartService) { uartService in
                        NavigationLink("UART", destination: UARTViewHost(uartService: uartService)
                        )
                    }
                    Spacer()
                    Button("CANHack") {
                        self.showCANHACK = true
                    }
                }.padding()
            }
            .onTapGesture {
                self.send(.lock)
            }
            .onTapGesture(count: 2) {
                self.send(.unlock)
            }
            .navigationBarTitle(vehicle?.name ?? "Vehicle")
        }
        .sheet(isPresented: $showUART) {
            UARTViewHost(uartService: (self.vehicle?.uartService)!)
        }
        .sheet(isPresented: $showCANHACK) {
            // FIXME: Show CANHACK
            UARTViewHost(uartService: (self.vehicle?.uartService)!)
        }
    }
    
    func send(_ command: Command) {
        vehicle?.smartLock?.send(command)
//        commandView.display(sending: command)
    }
}

/// Vehicle Delegate Conformace
extension VehicleView: VehicleDelegate {
    func vehicleDidBecomeAvailible(_ vehicle: Vehicle) {
        //TODO:
    }
    
    func vehicleDidBecomeUnavailible(_ vehicle: Vehicle, error: Error?) {
        //TODO: Display Avalibility
    }
    
    func vehicle(_ vehicle: Vehicle, smartLockDidBecomeAvalible smartLock: SmartLock) {
        //TODO:
    }
}

extension VehicleView: SmartLockDelegate {
    func smartLock(_ smartLock: SmartLock, didSend command: Command, error: Error?) {
        commandView.complete()
        
        if let error = error {
            //TODO: Better error messages?
            commandView.error(message: error.localizedDescription)
        }
    }
}


struct VehicleView_Previews: PreviewProvider {
    static var previews: some View {
        var vehicleView = VehicleView()
        
        vehicleView.vehicle = MockVehicle()
        
        
        return vehicleView.environmentObject(VehicleManager(uniqueID: "previewManager"))
    }
}
