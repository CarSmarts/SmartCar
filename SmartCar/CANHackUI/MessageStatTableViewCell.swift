//
//  MessageStatTableViewCell.swift
//  SmartCar
//
//  Created by Robert Smith on 11/11/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

class MessageStatTableViewCell: UITableViewCell {

    public var stats: SignalStat<Message>! {
        didSet {
            title.text = stats.description
            occuranceGraphView.data = [stats.timestamps]
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
    
    @IBOutlet weak var title: UILabel!
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
