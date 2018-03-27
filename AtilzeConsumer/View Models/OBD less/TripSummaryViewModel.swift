//
//  TripSummaryViewModel.swift
//  AtilzeConsumer
//
//  Created by Shree on 02/11/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import Foundation
import MapKit

class TripSummary {
    var ignitionOnTime:String?
    var ignitionOffTime: String?
    var distance: Double = 0
    var sharpCornering: Int = 0
    var hardBreaking: Int = 0
    var overSpeed: Int = 0
    var hardAccel: Int = 0
    var duration: Double = 0
    var maxSpeed: Int = 0
    var incidents : [[String : Any]] = [[:]]
    var locations : [[String : Any]] = [[:]]
    var startAddr : String = ""
    var endAddr : String = ""
    var startLoc : String = ""
    var endLoc : String = ""
    var tripScore : Double = 0.0
    var isManualTracking : Bool = false
    var reviewed : Bool = false
    init(rawData: [String : Any], totalDuration: Double, isFromTripList : Bool) {
        
        isManualTracking = !isFromTripList
        if isFromTripList {
            // BE data
            if let totalDistance = rawData["distance"] as? Double {
                distance = totalDistance
            }
            if let _duration = rawData["duration"] as? Double {
                duration = _duration
            }
            if let accel = rawData["harsh_accel"] as? Int {
                hardAccel = accel
            }
            if let braking = rawData["harsh_break"] as? Int {
                hardBreaking = braking
            }
            if let cornering = rawData["cornering"] as? Int {
                sharpCornering = cornering
            }
            if let speeding = rawData["speeding_count"] as? Int {
                overSpeed = speeding
            }
            if let _maxSpeed = rawData["speed_max"] as? Double {
                maxSpeed = Int(_maxSpeed)
            }
            
            if let _tripScore = rawData["trip_score"] as? Double {
                tripScore = _tripScore
            }
            
            if let _startAddr = rawData["start_address"] as? String{
                if _startAddr.isEmpty {
                    startAddr = "Not Available"
                } else {
                    startAddr = _startAddr
                }
            }
            if let _endAddr = rawData["end_address"] as? String {
                if _endAddr.isEmpty {
                    endAddr = "Not Available"
                } else {
                    endAddr = _endAddr
                }
            }
            
            if let _startLoc = rawData["start_location"] as? String {
                if _startLoc.isEmpty {
                    startLoc = "0.0,0.0"
                } else {
                    startLoc = _startLoc
                }
            }
            
            if let _endLoc = rawData["end_location"] as? String {
                if _endLoc.isEmpty {
                    endLoc = "0.0,0.0"
                } else {
                    endLoc = _endLoc
                }
            }
            
            if let _startAddrTime = rawData["start_datetime"] as? String {
                ignitionOnTime = _startAddrTime
            }
            
            if let _reviewed = rawData["reviewed"] as? Bool{
                reviewed = _reviewed
            }
            
            if let _startAddrTime = rawData["end_datetime"] as? String {
                ignitionOffTime = _startAddrTime
            }
            guard let _incidents = rawData["alerts"] as? [[String : Any]], let _locations = rawData["routes"] as? [[String : Any]] else {
                return
            }
            
            incidents = _incidents
            locations = _locations
            
        } else {
            // Manual
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
            duration = totalDuration
            ignitionOnTime = rawData["ignitionOnTime"] as? String
            ignitionOffTime = rawData["ignitionOffTime"] as? String
            
            incidents = [[:]]
            locations = [[:]]
        }
    }
}

struct TripSummaryModelView {
    var tripSummaryObj: TripSummary
    
    enum PointsToScoreType  : String {
        case speeding = "speeding"
        case durationOfDrive = "durationOfDrive"
        case otherIncidents = "otherIncidents"
    }
    
    init(tripSummary : TripSummary) {
        tripSummaryObj = tripSummary
    }
    var reviewed: Bool {
        return tripSummaryObj.reviewed
    }
    var distance: String {
        // DISTANCE
        let distanceinKM = tripSummaryObj.distance / 1000
        return String(format:"%.1f", distanceinKM)
    }
    var startAddr: String {
        return tripSummaryObj.startAddr
    }
    
    var endAddr: String {
        return tripSummaryObj.endAddr
    }
    var duration: String {
        // DURATION
//        // hh:mm FORMAT
//        if  tripSummaryObj.duration > 60 {
//            let hours = Int(tripSummaryObj.duration / 3600)
//            let mins =  Int((tripSummaryObj.duration.truncatingRemainder(dividingBy: 3600)) / 60)
//            let formattedHours = hours > 9 ? "\(hours)" : "0\(hours)"
//            let formattedMins = mins > 9 ? "\(mins)" : "0\(mins)"
//            return "\(formattedHours):\(formattedMins)"
//        } else {
//            return "00:01"
//        }
        
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
    //    var avgSpeed: String {
    //        // AVG SPEED
    //        return String(Int(tripSummaryObj.speedArray.reduce(0, +)) / tripSummaryObj.speedArray.count)
    //    }
    var tripScore: Double {
        // shreeeee hard coded value
        guard tripSummaryObj.isManualTracking else {
            return tripSummaryObj.tripScore
        }
        // MANUAL
        let distance: Double = Double(tripSummaryObj.distance/1000)
        let durationInMin = Int((tripSummaryObj.duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        var durationScore : Int = 0
        var accelScore : Int = 0
        var brakScore : Int = 0
        var corneringScore : Int = 0
        var speedingScore : Int = 0
        
        if durationInMin > 60 {
            durationScore = pointsToScore(points: Double(durationInMin), type: .durationOfDrive)
        }
        if hardAccel > 0 {
            let accelPoints = (Double(hardAccel)/distance) * 100.0
            accelScore = pointsToScore(points: accelPoints, type: .otherIncidents)
        }
        if hadrBraking > 0 {
            let brakPoints = (Double(hadrBraking)/distance) * 100.0
            brakScore = pointsToScore(points: brakPoints, type: .otherIncidents)
        }
        if sharpCornering > 0 {
            let corneringPoints = (Double(sharpCornering)/distance) * 100.0
            corneringScore = pointsToScore(points: corneringPoints, type: .otherIncidents)
        }
        if speedingCount > 0 {
            let speedingPoints = (Double(speedingCount)/distance) * 100.0
            speedingScore = pointsToScore(points: speedingPoints, type: .speeding)
            
        }
        
        let total = durationScore + accelScore - brakScore - corneringScore - speedingScore
        
        let finalScore = 100 - durationScore - accelScore - brakScore - corneringScore - speedingScore
        return Double(finalScore)
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
    var incidentsArray: [Incidents] {
        let incidents = tripSummaryObj.incidents.map {Incidents.init(incidentDict: $0)}
        return incidents
    }
    var locationsArray: [Locations] {
        let locations = tripSummaryObj.locations.map {Locations.init(locationDict: $0)}
        return locations
    }
    var startTime : String {
        return Utility.getOnlyTime(dateString: tripSummaryObj.ignitionOnTime!)
    }
    var startEndTime : String {
        return startEndTime(startDate: tripSummaryObj.ignitionOnTime!, endDate: tripSummaryObj.ignitionOffTime!)
    }

    var endTime : String {
        return Utility.getOnlyTime(dateString: tripSummaryObj.ignitionOffTime!)
    }
    
    var startLocation : CLLocationCoordinate2D {
        let strArr =  tripSummaryObj.startLoc.components(separatedBy: ",")
        if strArr.count < 2 {
            return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        } else {
            let lat = Double(strArr[0])
            let long = Double(strArr[1])
            return CLLocationCoordinate2D(latitude:lat ?? 0.0, longitude: long ?? 0.0)
        }
    }
    
    var endLocation : CLLocationCoordinate2D {
        let endArr =  tripSummaryObj.endLoc.components(separatedBy: ",")
        let lat = Double(endArr[0])
        let long = Double(endArr[1])
        return CLLocationCoordinate2D(latitude:lat ?? 0.0, longitude: long ?? 0.0)
    }
    
    func startEndTime(startDate : String, endDate : String) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
//        var _startDate: String = startDate
//        var _endDate: String = endDate
//
//        if startDate.contains("+00") {
//            _startDate = startDate.replacingOccurrences(of: "+0000", with: "")
//            _endDate = endDate.replacingOccurrences(of: "+0000", with: "")
//        }
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone(identifier: Model.shared.timeZone)
        
        var formattedDate:Date = Date()
        var formattedEndDate:Date = Date()
        
        if startDate.contains("+00") {
            formattedDate = formatter.date(from: startDate) ?? Date()
            formattedEndDate = formatter.date(from: endDate) ?? Date()
        } else {
            let timeZoneFormatter = DateFormatter()
            timeZoneFormatter.dateStyle = .long
            timeZoneFormatter.timeStyle = .long
            timeZoneFormatter.dateFormat = "ZZZ"
            let myDate = Date()
            timeZoneFormatter.timeZone = TimeZone(identifier: Model.shared.timeZone)
            let timeZoneString  = timeZoneFormatter.string(from: myDate)
            
            formattedDate = formatter.date(from: startDate + " " + timeZoneString) ?? Date()  // APPEND ZZZZ TO startDate
            formattedEndDate = formatter.date(from: endDate + " " + timeZoneString) ?? Date()  // APPEND ZZZZ TO endDate
        }
        
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
    
    func pointsToScore(points : Double, type : PointsToScoreType) -> Int {
        switch type {
        case .otherIncidents:
            if points == 0 {
                return 0
            } else if points > 0, points <= 10 {
                return 2
            } else if points > 11, points <= 20 {
                return 4
            } else if points > 21, points <= 30 {
                return 6
            } else if points > 31, points <= 40 {
                return 8
            } else if points > 41, points <= 50 {
                return 10
            } else if points > 51, points <= 60 {
                return 12
            } else if points > 61, points <= 70 {
                return 14
            } else if points > 71, points <= 80 {
                return 16
            } else if points > 81, points <= 90 {
                return 18
            } else {
                return 20
            }
        case .speeding:
            if points == 0 {
                return 0
            } else if points > 0, points <= 5 {
                return 3
            } else if points > 6, points <= 10 {
                return 6
            } else if points > 10, points <= 15 {
                return 9
            } else if points > 15, points <= 20 {
                return 12
            } else if points > 20, points <= 25 {
                return 15
            } else if points > 26, points <= 30 {
                return 18
            } else if points > 30, points <= 35 {
                return 21
            } else if points > 35, points <= 40 {
                return 24
            } else if points > 40, points <= 45 {
                return 27
            } else {
                return 30
            }
        case .durationOfDrive:
            if points < 60 {
                return 0
            } else if points > 60, points <= 90  {
                return 2
            } else if points > 90, points <= 120 {
                return 3
            } else if points > 120, points <= 150 {
                return 4
            } else if points > 150, points <= 180 {
                return 5
            } else if points > 180, points <= 210 {
                return 6
            } else if points > 211, points <= 240 {
                return 7
            } else if points > 240, points <= 270 {
                return 8
            } else {
                return 10
            }
        }
    }
    
}
    struct Incidents {
        var incident : [String : Any]
        
        init(incidentDict : [String : Any]) {
            print("incidentDict === \(incidentDict)")
            incident = incidentDict
        }
        var incidentTitle : String {
            return self.incident["title"] as? String ?? "Not Available"
        }
        var incidentType : String {
            return self.incident["type"] as? String ?? ""
        }
        var time : String {
            return Utility.getOnlyTime(dateString: self.incident["date"] as? String ?? "")
        }
        var addres : String {
            guard let _address = self.incident["address"] as? String, !_address.isEmpty else {
                return "Not Available"
            }
            return self.incident["address"] as? String ?? "Not Available"
        }
        var location : CLLocationCoordinate2D {
            let lat = self.incident["lat"] as? CLLocationDegrees
            let long = self.incident["lng"] as? CLLocationDegrees
            return CLLocationCoordinate2D(latitude:lat ?? 0.0, longitude: long ?? 0.0)
        }
    }
    
    struct Locations {
        var location : [String : Any]
        init(locationDict : [String : Any]) {
            print("locationDict === \(locationDict)")
            location = locationDict
        }
        var location2D : CLLocationCoordinate2D {
            let lat = self.location["latitude"] as? CLLocationDegrees
            let long = self.location["longitude"] as? CLLocationDegrees
            return CLLocationCoordinate2D(latitude:lat ?? 0.0, longitude: long ?? 0.0)
        }
    }
