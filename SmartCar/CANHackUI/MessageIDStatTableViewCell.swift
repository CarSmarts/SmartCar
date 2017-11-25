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
            descriptions.text = stats.map { $0.partialDescription }.joined(separator: "\n")
            
            occuranceGraphView.data = stats.map { $0.timestamps }
        }
    }

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descriptions: UILabel!
    @IBOutlet weak var occuranceGraphView: OccuranceGraphView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

extension SignalStat where S == Message {
    var partialDescription: String {
        return "\(timestamps.count): " + signal.contentDescription
    }
}
