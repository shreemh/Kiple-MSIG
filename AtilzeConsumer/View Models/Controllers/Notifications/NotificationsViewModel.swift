//
//  NotificationsViewModel.swift
//  AtilzeConsumer
//
//  Created by Shree on 09/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import Foundation
struct Notification {
    var dateSent: String = String()
    var message: String = String()
    var status: String = String()
    init(data : [String: Any]) {
        if let message:String = data["message"] as? String {
            self.message  = message
        }
        if let dateSent:String = data["date_sent"] as? String {
            self.dateSent = dateSent
        }
        if let status:String = data["status"] as? String {
            self.status = status
        }
    }
}
struct NotificationModelView {
    private var notificationObj: Notification
    var message: String {
        return notificationObj.message
    }
    var dateSent: String {
        return timeAgo(dateSent: notificationObj.dateSent)
    }
    init(notification: Notification) {
        notificationObj = notification
    }
    var status: String {
        return notificationObj.status
    }
    func timeAgo(dateSent: String) -> String {
        guard dateSent.characters.count > 0 else {
            return ""
        }
        let formatterTest = DateFormatter()
        formatterTest.dateStyle = .long
        formatterTest.timeStyle = .long
        formatterTest.dateFormat =  "ZZZ"
        let myDate = Date()
        formatterTest.timeZone = TimeZone(identifier: Model.shared.timeZone)
        let timeZoneString  = formatterTest.string(from: myDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone(identifier: Model.shared.timeZone)
        let formattedDate:Date = formatter.date(from: dateSent + " " + timeZoneString) ?? Date()
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        let now : Date! = Calendar.current.date(from: components)
        var timeDiff = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: formattedDate, to: now)
        let year = timeDiff.year ?? 0
        let month = timeDiff.month ?? 0
        let day = timeDiff.day ?? 0
        let hour = timeDiff.hour ?? 0
        let minute = timeDiff.minute ?? 0
        let seconds = timeDiff.second ?? 0
        let timeAgo: String
        if year > 0 {
            timeAgo = year > 1 ? "\(year)years ago" : "\(year)year ago"
        } else if month > 0 {
            timeAgo = month > 1 ? "\(month)months ago" : "\(month)month ago"
        } else if day > 0 {
            timeAgo = day > 1 ? "\(day)days ago" : "\(day)day ago"
        } else if hour > 0 {
            timeAgo = hour > 1 ? "\(hour)hours ago" : "\(hour)hour ago"
            return "\(hour)hours ago"
        } else if minute > 0 {
            timeAgo = "\(minute)min ago"
        } else if seconds > 0 {
            timeAgo = "\(Int(seconds))sec ago"
        } else {
            return "Just now"
        }
        return timeAgo
    }
}
