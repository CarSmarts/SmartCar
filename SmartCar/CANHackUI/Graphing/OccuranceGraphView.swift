//
//  HistogramView.swift
//  SmartCar
//
//  Created by Robert Smith on 11/11/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import UIKit

public struct OccuranceGraphScale {
    public var min: Int
    public var max: Int
    
    public var color: UIColor? = nil
    
    init(min: Int, max: Int, color: UIColor? = nil) {
        self.min = min
        self.max = max
        self.color = color
    }
}

class OccuranceGraphView: UIView {
    
    public var data: [[Int]] = [] {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    public var scale: OccuranceGraphScale? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var minDifference: CGFloat = 0.75
    @IBInspectable public var overlapFactor: CGFloat = 0.9
    @IBInspectable public var barHeight: CGFloat = 5.0;
    
    override var intrinsicContentSize: CGSize {
        // calculating target height from overlapFactor and target bar height
        let targetHeight = barHeight + CGFloat(data.count - 1) * barHeight * overlapFactor
        
        return CGSize(width: UIView.noIntrinsicMetric, height: targetHeight)
    }
    
    private func draw(occurances: [Int], scale: OccuranceGraphScale, color: UIColor, ypos: CGFloat, height: CGFloat) {
        let context = UIGraphicsGetCurrentContext()!
        color.setStroke()
        
        var lastPosition: CGFloat = 0.0
        
        for occurance in occurances {
            let position = CGFloat(occurance - scale.min) / CGFloat(scale.max - scale.min) * bounds.width
            
            if (position - lastPosition) > minDifference {
                context.move(to: CGPoint(x: position, y: ypos))
                context.addLine(to: CGPoint(x: position, y: ypos + height))
                
                lastPosition = position
            }
        }
        context.strokePath()
    }
    
    private let colors = [
        UIColor.blue,
        UIColor.magenta,
        UIColor.green,
        UIColor.purple,
        UIColor.red,
        UIColor.orange,
        UIColor.brown,
    ]
    
    var colorAlpha: CGFloat = 0.80
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        guard let scale = self.scale else {
            return
        }
        
        // Inverse of calculation in intrinsicContentSize
        let height = bounds.height / (1.0 + CGFloat(data.count - 1) * overlapFactor)
        
        for (index, occurances) in data.enumerated() {
            let pos = height * CGFloat(index) * overlapFactor
            let color = scale.color ?? colors[index % colors.count]
            .withAlphaComponent(colorAlpha)
            
            draw(occurances: occurances, scale: scale, color: color, ypos: pos, height: height)
        }
    }
}
