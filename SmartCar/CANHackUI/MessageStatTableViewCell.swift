//
//  MessageStatTableViewCell.swift
//  SmartCar
//
//  Created by Robert Smith on 11/11/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

class MessageStatTableViewCell: UITableViewCell {

    public var stats: MessageStat! {
        didSet {
            title.text = stats.message.description
        }
    }
    
    public var histogramBins: [Int] {
        get {
            return histogramView.bins
        }
        set {
            histogramView.bins = newValue
        }
    }
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var histogramView: HistogramView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
