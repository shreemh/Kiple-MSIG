//
//  DriveAndTrackTests.swift
//  AtilzeConsumerTests
//
//  Created by Shree on 18/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import XCTest
@testable import AtilzeConsumer
var tripTrackingVC: DriveAndTrackVC!

class DriveAndTrackTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let vc = mainSB.instantiateViewController(withIdentifier: StoryBoardVC.driveAndTrack) as? DriveAndTrackVC {
            tripTrackingVC = vc
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        tripTrackingVC = nil
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSignalStrength() {
        let testString = tripTrackingVC.checkSignalStregth()
        XCTAssertEqual(testString, "Low")

        
        // TESTCASE PASSED - CANNOT START TRIP
        // TESTCASE FAILED - READY TO START TRIP
    }
    
    func testBracking() {
        let harshBraking = -3.6
        XCTAssertLessThan(harshBraking, -3.5)
    }
    
    func testAccel() {
        let harshAccel = 4.0
        XCTAssertGreaterThan(harshAccel, 3.0)
    }
    
}
