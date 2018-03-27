//
//  TripHistoryTest.swift
//  AtilzeConsumerTests
//
//  Created by Shree on 07/12/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import XCTest
@testable import AtilzeConsumer

class TripHistoryTest: XCTestCase {
    
    enum PointsToScoreType  : String {
        case speeding = "speeding"
        case durationOfDrive = "durationOfDrive"
        case otherIncidents = "otherIncidents"
    }
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
//
//    func testCheckAccountType() {
//        // OBD OR OBD LESS
//
//        // MANUAL
//        let distance: Double = 22.7
//        let durationInMin: Double = 1.4
//
//        var durationScore : Int = 0
//        var accelScore : Int = 0
//        var brakScore : Int = 0
//        var corneringScore : Int = 0
//        var speedingScore : Int = 0
//
//        let hardAccel = 0.0
//        let hadrBraking = 0.0
//        let sharpCornering = 3.0
//        let speedingCount = 0.0
//
//        if durationInMin > 60 {
//            durationScore = pointsToScore(points: durationInMin, type: .durationOfDrive)
//        }
//        if hardAccel > 0 {
//            let accelPoints = (hardAccel/distance) * 100
//            accelScore = pointsToScore(points: accelPoints, type: .otherIncidents)
//        }
//        if hadrBraking > 0 {
//            let brakPoints = (hadrBraking/distance) * 100
//            brakScore = pointsToScore(points: brakPoints, type: .otherIncidents)
//        }
//        if sharpCornering > 0 {
//            let corneringPoints = (sharpCornering/distance) * 100
//            corneringScore = pointsToScore(points: corneringPoints, type: .otherIncidents)
//        }
//        if speedingCount > 0 {
//            let speedingPoints = (speedingCount/distance) * 100
//            speedingScore = pointsToScore(points: speedingPoints, type: .speeding)
//
//        }
//        let finalScore = 100 - durationScore - accelScore - brakScore - corneringScore - speedingScore
//
//        XCTAssertEqual(100, 100)
//    }
//
//    func pointsToScore(points : Double, type : PointsToScoreType) -> Int {
//        let num1 = points
//        switch type {
//        case .otherIncidents:
//            if num1 > 90 {
//                return 20
//            }
//            let num2 = num1/10
//            let score = num1.truncatingRemainder(dividingBy: num2)
//            return Int(score) + 2
//
//        case .speeding:
//            if points > 0, points <= 5 {
//                return 0
//            } else if points > 0, points <= 5 {
//                return 3
//            } else if points > 6, points <= 10 {
//                return 6
//            } else if points > 10, points <= 15 {
//                return 9
//            } else if points > 15, points <= 20 {
//                return 12
//            } else if points > 20, points <= 25 {
//                return 15
//            } else if points > 26, points <= 30 {
//                return 18
//            } else if points > 30, points <= 35 {
//                return 21
//            } else if points > 35, points <= 40 {
//                return 24
//            } else if points > 40, points <= 45 {
//                return 27
//            } else {
//                return 30
//            }
//        case .durationOfDrive:
//            let strSrore = String(format:"%.f", num1/30)
//            let score : Int = Int(strSrore) ?? 0
//            return score
//        }
//    }

    
    

    
}
