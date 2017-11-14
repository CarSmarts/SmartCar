//
//  HistogramController.swift
//  SmartCar
//
//  Created by Robert Smith on 11/13/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import Foundation

func calculateHistogramBins(_ data: [Int], binCount: Int) -> [Int] {
    guard data.count > 0 else {
        return []
    }

    return calculateHistogramBins(data, binCount: binCount, min: data.min()!, max: data.max()!)
}

// TODO: figure out how to implement this algorithim/math function using only integers
func calculateHistogramBins(_ data: [Int], binCount: Int, min: Int, max: Int) -> [Int] {
    guard data.count > 0 && binCount > 2 else {
        return []
    }
    
    var bins = Array(repeating: 0, count: binCount)
    
    let stride = Double(max - min + 1) / Double(binCount)
    
    for dataPoint in data {
        let bin = Int(Double(dataPoint - min) / stride)
        bins[bin] += 1
    }
    
    return bins
}

struct HistogramScale: Codable {
    var min: Int
    var max: Int
    
    var binCount: Int
}

extension HistogramScale {
    init(using list: [Int]) {
        // TODO: binCount math
        let binCount = list.count // < 1000 ? (list.count / 2) : 500
        self.init(min: list.min() ?? 0, max: list.max() ?? 0, binCount: binCount)
    }
}

/// Helper for contolling multiple coordinated histograms
public struct HistogramController: Codable {
    
    init(data: [[Int]], scale: HistogramScale) {
        self.data = data
        self.scale = scale
        
        bins = data.map { dataPoint in
            calculateHistogramBins(dataPoint, binCount: scale.binCount,
                                   min: scale.min, max: scale.max)
        }
    }
    
    var data: [[Int]] {
        didSet {
            recalculateBins()
        }
    }
    var scale: HistogramScale {
        didSet {
            recalculateBins()
        }
    }

    public subscript(index: Int) -> [Int] {
        get{
            return bins[index]
        }
    }
    
    public private(set) var bins: [[Int]]
    
    mutating private func recalculateBins() {
        bins = data.map { dataPoint in
            calculateHistogramBins(dataPoint, binCount: scale.binCount,
                                   min: scale.min, max: scale.max)
        }
    }
}

