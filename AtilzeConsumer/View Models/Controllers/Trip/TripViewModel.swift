//
//  Trip.swift
//  AtilzeConsumer
//
//  Created by Shree on 01/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import Foundation

class Trip {
    var startDate: String = String()
    var endDate : String = String()
    var startAddress: String = String()
    var endAddress: String = String()
    var distance: Double = 0
    var duration: Double = 0
    var safetyScore: Double = 0
    var fuel: Double = 0
    var cornering: Int = 0
    var hardBreaking: Int = 0
    var speeding: Int = 0
    var hardAccel: Int = 0
    var fuelEfficiencyBE : Double = 0
    var maxSpeed: Double = 0
    var tripID : String = ""
    var reviewed: Bool = false
    var trackingMode: String = ""
    
    init(data : [String : Any]) {

        if let _tripID = data["trip_id"] as? String {
            tripID = _tripID
        }
        
        if let _startDate = data["start_datetime"] as? String {
            startDate = _startDate
        }
        if let _endDate = data["end_datetime"] as? String {
            endDate = _endDate
        }
        if let _startAddress = data["start_address"] as? String {
            startAddress = _startAddress
        }
        if let _endAddress = data["end_address"] as? String {
            endAddress = _endAddress
        }
        if let _distance = data["distance"] as? Double {
            distance = _distance
        }
        if let _duration = data["duration"] as? Double {
            duration = _duration
        }
        if let _safetyScore = data["trip_score"] as? Double {
            safetyScore = _safetyScore
        }
        if let _cornering = data["cornering"] as? Double {
            cornering = Int(_cornering)
        }
        if let _hardBreaking = data["harsh_break"] as? Double {
            hardBreaking = Int(_hardBreaking)
        }
        if let _speeding = data["speeding_count"] as? Double {
            speeding = Int(_speeding)
        }
        if let _hardAccel = data["harsh_accel"] as? Double {
            hardAccel = Int(_hardAccel)
        }
        if let _fuel = data["driving_fuel_consumption"] as? Double {
            fuel = _fuel
        }
        if let idelFuelConsumption = data["idle_fuel_consumption"] as? Double {
            fuel = fuel + idelFuelConsumption
        }
        if let _fuelEfficiencyBE = data["fuel_efficiency"] as? Double {
            fuelEfficiencyBE = _fuelEfficiencyBE
        }
        if let _maxSpeed = data["speed_max"] as? Double {
            maxSpeed = _maxSpeed
        }
        
        if let _reviewed = data["reviewed"] as? Bool{
            reviewed = _reviewed
        }
        
        if let _trackingMode = data["tracking_mode"] as? String {
            trackingMode = _trackingMode
        }
    }
}

struct TripModelView {
    var tripObj: Trip
    init(trip : Trip) {
        tripObj = trip
    }
    var reviewed: Bool {
        return tripObj.reviewed
    }
    var trackingMode: String {
        return tripObj.trackingMode
    }
    var startDate: String {
        let formattedDate =  getStartDateTime(startDate: tripObj.startDate, endDate: tripObj.endDate)
        return formattedDate
    }
    var endDate: String {
        let formattedDate =  getStartDateTime(startDate: tripObj.startDate, endDate: tripObj.endDate)
        return formattedDate
    }
    var startDateForCompare : Date {
        let formattedDate = startDateForCompare(startDate: tripObj.startDate)
        return formattedDate
    }
    var endDateForCompare : Date {
        let formattedDate = startDateForCompare(startDate: tripObj.endDate)
        return formattedDate
    }
    var startAddress: String {
        return  tripObj.startAddress.capitalized
    }
    var endAddress: String {
        return tripObj.endAddress.capitalized
    }
    var maxSpeed: String {
        let maxSpeed: Int = Int(tripObj.maxSpeed)
        return String(maxSpeed)
    }
    var distance: String {
        let _distance = tripObj.distance / 1000
        return "\(String(format:"%.1f", _distance)) KM"
    }
    var duration: String {
        let seconds = Float(tripObj.duration)
//        // hh:mm FORMAT
//        guard seconds > 60 else {
//            return "00:01"
//        }
//        let hours = Int(seconds / 3600)
//        let mins =  Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
//        let formattedHours = hours > 9 ? "\(hours)" : "0\(hours)"
//        let formattedMins = mins > 9 ? "\(mins)" : "0\(mins)"
//        return "\(formattedHours):\(formattedMins)"
        
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
    //    var fuelEfficiency: String {
    //        //        Distance -> fuel_consumption
    //        //        100      ->    ??
    //        let fuelConsumption: Double! = Double(tripObj.fuel)
    //        let distance: Double! = Double(tripObj.distance)
    //        let efficiency = fuelConsumption > 0 ? (100 / distance) * fuelConsumption : 0
    //        return "\(String(efficiency.rounded()))/100KM"
    //    }
    
    var fuelEfficiency: String {
        let efficiency = tripObj.fuelEfficiencyBE
        return "\(String(format:"%.1f", efficiency)) L/100KM"
    }
    var safetyScore: CGFloat {
        let score = tripObj.safetyScore
        return CGFloat(score)
    }
//    var otherScores: [CGFloat] {
//        var scoreArray: [CGFloat] = [CGFloat]()
//        scoreArray = [tripObj.cornering, tripObj.hardBreaking, tripObj.speeding, tripObj.hardAccel].map {CGFloat($0)}
//        return scoreArray
//    }
    var otherScores: [Int] {
        var scoreArray: [Int] = [Int]()
        scoreArray = [tripObj.cornering, tripObj.hardBreaking, tripObj.speeding, tripObj.hardAccel]
        return scoreArray
    }
    var fuel: String {
        let _fuel = tripObj.fuel/1000  // ml to Liters
        // return "\(String(_fuel.rounded())) L/100KM"
        return "\(String(format:"%.1f", _fuel)) L"
    }
    var tripID : String {
        return tripObj.tripID
    }
    // GET TRIP START DATE
    func getStartDateTime(startDate : String, endDate : String) -> String {
        let timeZoneFormatter = DateFormatter()
        timeZoneFormatter.dateStyle = .long
        timeZoneFormatter.timeStyle = .long
        timeZoneFormatter.dateFormat = "ZZZ"
        let myDate = Date()
        timeZoneFormatter.timeZone = TimeZone(identifier: Model.shared.timeZone)
        let timeZoneString  = timeZoneFormatter.string(from: myDate)
        
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone(identifier: Model.shared.timeZone)
        let formattedDate:Date = formatter.date(from: startDate + " " + timeZoneString) ?? Date()  // APPEND ZZZZ TO startDate
        let formattedEndDate:Date = formatter.date(from: endDate + " " + timeZoneString) ?? Date()  // APPEND ZZZZ TO endDate
        
        var formattedDateInString: String
        var formattedEndDateInString: String
        
        if calendar.isDateInToday(formattedDate) {
            formatter.dateFormat = "hh:mma"
            formattedDateInString = formatter.string(from: formattedDate)
            formattedEndDateInString = formatter.string(from: formattedEndDate)
            return "Today, \(formattedDateInString)" + " - " + formattedEndDateInString
        } else if Calendar.current.isDateInYesterday(formattedDate) {
            formatter.dateFormat = "hh:mma"
            formattedDateInString = formatter.string(from: formattedDate)
            formattedEndDateInString = formatter.string(from: formattedEndDate)
            return "Yesterday, \(formattedDateInString)" + " - " + formattedEndDateInString
        } else {
            formatter.dateFormat = "dd MMM, hh:mma"
            formattedDateInString = formatter.string(from: formattedDate)
            formatter.dateFormat = "hh:mma"
            formattedEndDateInString = formatter.string(from: formattedEndDate)
            return formattedDateInString + " - " + formattedEndDateInString
        }
    }
    
    func startDateForCompare(startDate : String) -> Date {
        let timeZoneFormatter = DateFormatter()
        timeZoneFormatter.dateStyle = .long
        timeZoneFormatter.timeStyle = .long
        timeZoneFormatter.dateFormat =  "ZZZ"
        let myDate = Date()
        timeZoneFormatter.timeZone = TimeZone(identifier: Model.shared.timeZone)
        let timeZoneString  = timeZoneFormatter.string(from: myDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let formattedDate:Date = formatter.date(from: startDate + " " + timeZoneString) ?? Date() // APPEND ZZZZ TO startDate
        return formattedDate
    }
}
