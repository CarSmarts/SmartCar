//
//  MessageParseTests.swift
//  SmartCarTests
//
//  Created by Robert Smith on 11/4/17.
//  Copyright © 2017 Robert Smith. All rights reserved.
//

import XCTest
@testable import SmartCar

class MessageParseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMessageCreation() {
        let message = try? Message(from: "0x1E12FF10,0")
        
        XCTAssertNotNil(message, "Unable to create Message");
        
        XCTAssertEqual(message!.id.rawValue, 0x1E12FF10)
        XCTAssertEqual(message!.contents, [])

        let messageOccurance = try! SignalOccurance<Message>(from: "17548,0x12F85250,4,75,04,AD,D2")

        XCTAssertEqual(messageOccurance.timestamp, 17548)
        XCTAssertEqual(messageOccurance.signal.id.rawValue, 0x12F85250)
        XCTAssertEqual(messageOccurance.signal.contents, [0x75,0x04,0xAD,0xD2])
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
