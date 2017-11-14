//
//  HistogramMathTests.swift
//  SmartCarTests
//
//  Created by Robert Smith on 11/11/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import XCTest
@testable import SmartCar

class HistogramMathTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let test1 = [0,1,2,3,4,5,6,7,8,9]
    let test2 = [0,0,1,2,3,4,4,5,6,7,8,9]
    let test3 = [5,7,18,25,30,31,32,41]

    func testBinCalc() {
        
        let bins1 = calculateHistogramBins(test1, binCount: 10)
        XCTAssertEqual(bins1, Array(repeating: 1, count: 10))
        
        let bins2 = calculateHistogramBins(test2, binCount: 10)
        XCTAssertEqual(bins2, [2,1,1,1,2,1,1,1,1,1])
        
        let bins3 = calculateHistogramBins(test3, binCount: 3)
        XCTAssertEqual(bins3, [2,2,4])
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
