 //
//  Model.swift
//  AtilzeCunsumer
//
//  Created by Shree on 30/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import CoreLocation
import Moscapsule
 
import CoreMotion
import UserNotifications

class Model: NSObject {
    static var shared = Model()
    var isFromForgotPW = Bool()
    var timeZone : String = String()
    var userInfoDict = [String : Any]()
    var profileDict: [String : String] = ["name" : "", "phone" : "", "email" : "", "emergency_name" : "", "emergency_contact" : ""]
    var carModelDict: [[String : String]] = [["key" : "Car Model", "value" : ""], ["key" : "VIN NO.", "value" : ""], ["key" : "Car Plate", "value" : ""], ["key" : "Starting Mileage", "value" : ""], ["key" : "Current Mileage", "value" : ""], ["key" : "Car Manufacture", "value" : ""], ]
    var unreadAlertsCount : Int = 0
    var unreadNotificationsCount : Int = 0
    
    // PHASE 2
    var mqttConfig : MQTTConfig?
    var mqttClient : MQTTClient?
    var trackedGPSDataArray = [[String : Any]]()
    var isOngoingTrip : Bool = false
    class func destroy() {
        shared = Model()
    }
    var isFromManualTracking : Bool = false
    
    var motionManager = CMMotionManager()
    var activityManager = CMMotionActivityManager()
    
    var notiCount : Int = 0
    let center = UNUserNotificationCenter.current()
    
    var userLoc: UserLocation?
    var deviceMotion: DeviceMotion?
    var walkingStateTime: Date?
    var stationaryStateTime: Date?
    var isinBackgroundState: Bool = false
    var stopped: Bool = false
    var incidentTime: Date?
  //  var tripsLogDict : [String : Any] = [String : Any]()
    
    /// AZMAN LOGIC VARIABLES
    var lowPassFilterData: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
    var gravityData: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
    var userAccelerometerData: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
    var overallForwardDir: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
    var currentLocation: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
    var previousLocation: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
    var prevTime : Date?
    var velValues: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
    var isAutoTrackingMode : Bool = false
    var isTrackingModeChanged : Bool = false

    var rollSum : Double = 0.0
    var pitchSum : Double = 0.0
    var magnitude : Double = 0.0
    var magnitudePrevious : Double = 0.0
    var avgBuffer : Double = 0.0
    var avgBufferYaw : Double = 0.0
    var avgCount : Int = 0
    var avgCountYaw : Int = 0
    var xyMagnitudeOffset : Double = 0.0
    var xyMagnitudeOffsetPrevious : Double = 0.0
    
    var gspDictArray: [[String : Any]] = [[String : Any]]()
    var isTempStatusResolved: Bool = false
    var isBatteryStatusResolved: Bool = false
}
