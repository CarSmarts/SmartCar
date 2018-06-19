//
//  MessageIDStatTableViewCell.swift
//  SmartCar
//
//  Created by Robert Smith on 11/15/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

class MessageIDStatTableViewCell: UITableViewCell {

    public var id: MessageID! {
        didSet {
            title.text = id.description
        }
    }
    
    public var stats: [SignalStat<Message>]! {
        didSet {
            updateFromStats()
        }
    }
    
    public var scale: OccuranceGraphScale? {
        set {
            occuranceGraphView.scale = newValue
        }
        get {
            return occuranceGraphView.scale
        }
    }

    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descriptions: UITextView!
    @IBOutlet weak var occuranceGraphView: OccuranceGraphView!
    
    private func updateFromStats() {
        let shortList = stats.prefix(10)
        
        descriptions.text = shortList.map { $0.signal.contentDescription }.joined(separator: "\n")
        
        occuranceGraphView.data = shortList.map { $0.timestamps }
        
        let remainder = stats.count - 10
        if remainder > 0 {
            moreLabel.text = "+ \(remainder) more"
            moreLabel.isHidden = false
        } else {
            moreLabel.text = ""
            moreLabel.isHidden = true
        }
    }
}

extension SignalStat where S == Message {
    var partialDescription: String {
        return "\(timestamps.count)" + signal.contentDescription
    }
}
