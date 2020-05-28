//
//  ContentView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/20/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import CANHackUI

struct ContentView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    
    var body: some View {
        TabView {
            NavigationView {
                VehicleListView()
                VehicleDetailView(vehicle: vehicleManager.vehicles.first ?? MockVehicle())
            }.tabItem {
                Image(systemName: "car.fill")
                Text("CarSmarts")
            }
            CanHackUIView()
            .tabItem {
                Image(systemName: "list.dash")
                Text("CanHack")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(VehicleManager())
    }
}
