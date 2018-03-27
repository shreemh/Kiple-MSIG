//
//  TripDetailViewModel.swift
//  AtilzeConsumer
//
//  Created by Shree on 27/11/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import Foundation

class TripDetail {
    var ignitionOnTime:String?
    var ignitionOffTime: String?
    var distance: Double = 0
    var speedArray: [Double] = []
    var sharpCornering: Int = 0
    var hardBreaking: Int = 0
    var overSpeed: Int = 0
    var hardAccel: Int = 0
    var duration: Double = 0
    var maxSpeed: Int = 0
    
    init(rawData: [String : Any], speedArr: [Double], totalDuration: Double) {
        if let totalDistance = rawData["drivingDistance"] as? Double {
            distance = totalDistance
        }
        if let accel = rawData["numberRapidAcce"] as? Int {
            hardAccel = accel
        }
        if let braking = rawData["numberRapidDece"] as? Int {
            hardBreaking = braking
        }
        if let cornering = rawData["numberRapidSharpTurn"] as? Int {
            sharpCornering = cornering
        }
        if let speeding = rawData["numberOverSpeed"] as? Int {
            overSpeed = speeding
        }
        if let _maxSpeed = rawData["maxSpeed"] as? Double {
            maxSpeed = Int(_maxSpeed)
        }
        speedArray = speedArr
        duration = totalDuration
        ignitionOnTime = rawData["ignitionOnTime"] as? String
        ignitionOffTime = rawData["ignitionOffTime"] as? String
    }
}

struct TripDetailModelView {
    var tripSummaryObj: TripSummary
    init(tripSummary : TripSummary) {
        tripSummaryObj = tripSummary
    }
    var distance: String {
        // DISTANCE
        let distanceinKM = tripSummaryObj.distance / 1000
        return String(format:"%.1f", distanceinKM)
    }
    var duration: String {
        // DURATION
        // hh:mm FORMAT
//        if  tripSummaryObj.duration > 60 {
//            let hours = Int(tripSummaryObj.duration / 3600)
//            let mins =  Int((tripSummaryObj.duration.truncatingRemainder(dividingBy: 3600)) / 60)
//            let formattedHours = hours > 9 ? "\(hours)" : "0\(hours)"
//            let formattedMins = mins > 9 ? "\(mins)" : "0\(mins)"
//            return "\(formattedHours):\(formattedMins)"
//        } else {
//            return "00:01"
//        }
//
        let seconds = tripSummaryObj.duration
        // OLD CODE
        guard seconds > 60 else {
            return "\(Int(seconds)) secs"
        }
        guard seconds > 3600 else {
            let mins: Int = Int(seconds / 60)
            let secs: Int = Int(seconds.truncatingRemainder(dividingBy: 60))
            return "\(mins) MINS"
        }
        let hours = Int(seconds / 3600)
        let mins =  Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours) hr \(mins) MINS"
        
    }
    var maxSpeed: String {
        return String(tripSummaryObj.maxSpeed)
    }
    var tripScore: Int {
        // shreeeee hard coded value
        return 50
    }
    var speedingCount: Int {
        return tripSummaryObj.overSpeed
    }
    var hardAccel: Int {
        return tripSummaryObj.hardAccel
    }
    var hadrBraking: Int {
        return tripSummaryObj.hardBreaking
    }
    var sharpCornering: Int {
        return tripSummaryObj.sharpCornering
    }
}
