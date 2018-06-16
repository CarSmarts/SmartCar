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
    
    public var data: [Int] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var scale: OccuranceGraphScale? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private func draw(occurances: [Int], scale: OccuranceGraphScale, color: UIColor, ypos: CGFloat, height: CGFloat) {
        let context = UIGraphicsGetCurrentContext()!
        color.setStroke()
        
        for occurance in occurances {
            let position = CGFloat(occurance - scale.min) / CGFloat(scale.max - scale.min) * bounds.width
            
            context.move(to: CGPoint(x: position, y: ypos))
            context.addLine(to: CGPoint(x: position, y: ypos + height))
        }
        context.strokePath()
    }
    
    private  let colors = [
        UIColor.cyan,
        UIColor.magenta,
        UIColor.green,
        UIColor.purple,
        UIColor.red,
        UIColor.orange,
        UIColor.brown,
    ]
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        guard let scale = self.scale else {
            return
        }
        
        let height = bounds.height / CGFloat(data.count)
        
        let color = scale.color ?? UIColor.blue
            
        draw(occurances: data, scale: scale, color: color, ypos: 0, height: bounds.height)
    }
}
