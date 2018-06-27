//
//  MessageStatViewController.swift
//  SmartCar
//
//  Created by Robert Smith on 6/19/18.
//  Copyright © 2018 Robert Smith. All rights reserved.
//

import UIKit

class MessageStatViewController: UIViewController {

    public var groupStats: GroupedStat<Message, MessageID>!

    @IBOutlet weak var scrubSlider: UISlider! {
        didSet {
            scrubSlider.addTarget(self, action: #selector(MessageStatViewController.updateShownFrame), for: .valueChanged)
        }
    }
    @IBOutlet weak var binaryDataView: BinaryDataView!
    
    override func viewWillAppear(_ animated: Bool) {
        title = groupStats.group.description
        
        scrubSlider.minimumValue = 0
        scrubSlider.maximumValue = Float(groupStats.signalList.count - 1) // last index is one less than count
        scrubSlider.value = 0
        
        updateShownFrame()
    }
    
    @objc private func updateShownFrame() {
        let index = Int(round(scrubSlider.value))
        
        binaryDataView.data = groupStats.signalList[index].signal.contents
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
