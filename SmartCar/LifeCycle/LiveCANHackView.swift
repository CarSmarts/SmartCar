//
//  LiveCANHackView.swift
//  SmartCar
//
//  Created by Robert Smith on 6/18/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import SwiftUI
import CANHackUI

struct LiveCANHackView: View {
    var m2SmartService: M2SmartService
    @EnvironmentObject var canHackManager: CANHackManager

    var body: some View {
        MessageSetView(document: self.canHackManager.scratch, decoder: self.canHackManager.decoderBinding)
        // todo.. move this into the model code.. an don't update the ui until all the changes have propigated to the subparts..
        .onReceive(m2SmartService.frames.receive(on: RunLoop.main)) { newInstance in
            self.canHackManager.scratch.signalSet.add(newInstance)
        }
    }
}
