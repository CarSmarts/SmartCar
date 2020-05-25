//
//  VehicleListView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/20/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import Combine

struct ScanButton: View {
    @ObservedObject var vehicleManager: VehicleManager

    var body: some View {
        Button(action: {
            self.vehicleManager.shouldScan = !self.vehicleManager.shouldScan
        }) {
            if !self.vehicleManager.shouldScan {
                Text("Scan")
            } else {
                Text("Stop").bold()
            }
        }
    }
}

struct VehicleRow: View {
    @ObservedObject var vehicle: Vehicle
    
    var body: some View {
        HStack {
            if vehicle.isConnected {
                Text(vehicle.name)
            } else {
                Text(vehicle.name).foregroundColor(.secondary)
            }
        }
    }
}

struct VehicleListView: View {
    @EnvironmentObject var vehicleManager: VehicleManager
    private var subs: Set<AnyCancellable> = []
    
    var body: some View {
        List {
            ForEach(vehicleManager.vehicles) { vehicle in
                NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                    VehicleRow(vehicle: vehicle)
                }
            }
            .onDelete { (indexSet) in
                for idx in indexSet {
                    self.vehicleManager.vehicles.remove(at: idx)
                }
            }
        }
        .onAppear {
            self.vehicleManager.shouldScan = true
        }
        .onDisappear {
            self.vehicleManager.shouldScan = false
        }
        .navigationBarTitle("Vehicles")
        .navigationBarItems(trailing: ScanButton(vehicleManager: vehicleManager))
    }
}

struct VehicleListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VehicleListView().environmentObject(VehicleManager())

            ContentView().environmentObject(VehicleManager())
        }
    }
}
