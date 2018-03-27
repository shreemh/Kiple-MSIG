//
//  AlertsViewModel.swift
//  AtilzeCunsumer
//
//  Created by Shree on 18/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import Foundation

class Alert {
    
    var type : String?
    var typeCat : String?
    var typeNameFromBE  : String?
    var status : String?
    var reportTime : String = ""
    var alertId:String = ""
    init(data : [String : Any]) {
        
        type = data["alert_type"] as? String ?? ""
        typeNameFromBE = data["alert_type_name"] as? String
        status = data["alert_status"] as? String
        reportTime = data["report_time"] as? String ?? ""
        alertId = data["alert_id"] as? String ?? ""
        if type == AlertTypes.faultCode {
            type = data["alert_type_cat"] as? String
        } else if type == AlertTypes.lowVoltage {
            type = "weak_battery"
        } else if type == AlertTypes.overHeat {
            type = "high_temperature"
        }
    
//        "alert_id": "59b72ba16701c8755eb2856d",
//        "alert_type": "over_heat",
//        "alert_type_cat": "",
//        "alert_type_name": "",
//        "alert_value": {
//            "engineCoolantTemperature": 88,
//            "heatLimit": 80
//        },
//        "alert_status": "Unread",
//        "latitude": 0,
//        "longitude": 0,
//        "mileage": 0,
//        "report_time": "2017-09-12 08:32:59"
    }
}

struct AlertsViewModel {
    private var alertObj: Alert
    init(alert : Alert) {
        alertObj = alert
    }
    var date: String {
        return Utility.getFormattedDate(date: alertObj.reportTime)
    }
    var reportTime: Date {
        return dateForCompare(reportTime: alertObj.reportTime)
    }
    var alertId:String {
        return alertObj.alertId
    }
    var message: String {
        if (alertObj.type?.characters.count)! > 0 {
        return alertObj.type!.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil).capitalized + " Warning"
        } else {
            return "Other Warning"
        }
    }
    var image : String {
        if (alertObj.type?.characters.count)! > 0 {
            return alertObj.type!
        } else {
            return "other_warning"
        }
    }
    var status : String {
        get {
            return alertObj.status!
        }
        set {
            alertObj.status = newValue
        }
    }
    func dateForCompare(reportTime : String) -> Date {
        let timeZoneFormatter = DateFormatter()
        timeZoneFormatter.dateStyle = .long
        timeZoneFormatter.timeStyle = .long
        timeZoneFormatter.dateFormat =  "ZZZ"
        let myDate = Date()
        timeZoneFormatter.timeZone = TimeZone(identifier: Model.shared.timeZone)
        let timeZoneString  = timeZoneFormatter.string(from: myDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let formattedDate:Date = formatter.date(from: reportTime + " " + timeZoneString) ?? Date() // APPEND ZZZZ TO startDate
        return formattedDate
    }
}
