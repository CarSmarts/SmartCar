//
//  HistogramView.swift
//  SmartCar
//
//  Created by Robert Smith on 11/11/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

class HistogramView: UIView {
    
    public var bins: [Int] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        guard bins.count > 0 else {
            return
        }
        
        let binWidth = bounds.width / CGFloat(bins.count)
        let max = CGFloat(bins.max()!)
        
        // TODO: one Path, translated
        // TODO: consider drawing lines instead of Rects?
        for (index, frequency) in bins.enumerated() {
            let x = binWidth * CGFloat(index)
            let percentFull = CGFloat(frequency) / max
            let height = bounds.height * percentFull
            UIColor.blue.setFill()
            
            let path = UIBezierPath(rect: CGRect(x: x, y: bounds.height - height, width: binWidth, height: height))
            path.fill()
        }
    }
}
