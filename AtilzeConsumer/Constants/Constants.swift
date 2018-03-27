//
//  Constants.swift
//  AtilzeConsumer
//
//  Created by Shree on 28/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking

/// Global Variables
let networkManager = NetworkManager(timeoutInterval: 60.0)
//let stationaryStateStopDuration = 300
//let walkingStateStopDuration = 120
//let stopTripDuration = 120
let stopTripDuration = 120
let speedLimit: Double = 110.99
var deferredLocationsDistance: Double = 90.0
var deferredLocationsDuration: Double = 80.0
var alpha: Double = 0.35
//let accelerationThreshold: Double = 0.3
//let brakingThreshold: Double = -0.35
//let corneringThreshold: Double = 15000

let accelerationThreshold: Double = 1.8
let brakingThreshold: Double = -3.5
let corneringThreshold: Double = 3.0

//let clientSecret = "XVxorCU82z2wjzF7QAd229d3CqlUYWIvAAwhg01t" // dev
//let clientSecret = "dQzQ6SEbp9D4HjcSmuhzElaZcLzRilUvwVgFziBv" // prod

let clientSecret = "dQzQ6SEbp9D4HjcSmuhzElaZcLzRilUvwVgFziBv" // MSIG


let NetworkReachabilityChanged = NSNotification.Name("NetworkReachabilityChanged")
var previousNetworkReachabilityStatus: AFNetworkReachabilityStatus = .unknown

let internetConnectMsg = "This device seems to be offline, please check the internet and kindly try again"

var carStatusWarningDict : [String : String] = ["icon" : "Car", "mainWarning" : "Car is Inactive now.", "warningLbl" : "Inactive"]

var carStatusDict : [String : String] = ["icon" : "Car", "mainWarning" : "Car is Active now.", "warningLbl" : "Active"]

var batteryWaringDict : [String : String] = ["icon" : "DashboardBattery", "mainWarning" : "Battery is below 11.5v. Battery is weak and car may not start. Please get your car checked immediately.", "warningLbl" : "Warning!", "warning" : "Warning is displayed for 7 days when alert is detected. Tap 'resolved' if problem has been resolved."]

var tempWaringDict : [String : String] = ["icon" : "DashboardTemp", "mainWarning" : "Coolant temperture is running high. Please get your car checked immediately.","warningLbl" : "Warning!", "warning" : "Warning is displayed for 7 days when alert is detected. Tap 'resolved' if problem has been resolved."]

var batteryDict : [String : String] = ["icon" : "DashboardBattery", "mainWarning" : "Battery is equal or greater than 11.5v. Battery is working fine", "warningLbl" : "Normal", "warning" : "" ]
var tempDict : [String : String] = ["icon" : "DashboardTemp", "mainWarning" : "Coolant temperature is normal", "warningLbl" : "Normal", "warning" : "" ]

var csvtext : String = ""
//let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

//let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
//var csvText = "seconds gravity_x gravity_y gravity_z gravity_magnitude longitudinal_x longitudinal_y longitudinal_z longitudinal_magnitude latitudinal_x latitudinal_y latitudinal_z latitudinal_magnitude\n"


let APPNAME = "ConnectedCar"
let mainSB = UIStoryboard(name: "Main", bundle: nil)
let secondSB = UIStoryboard(name: "SecondaryStoryboard", bundle: nil)
var refreshTokenTime: TimeInterval = 1296000  // 15days
var refreshTokenExpiryTime: TimeInterval = 15465600  // 179 days
var timerForRefreshToken: Timer = Timer()
var timerForDashBoardRefresh : Timer = Timer()
var timerForTripsRefresh : Timer = Timer()
var timerForNotificationsRefresh : Timer = Timer()
var timerForAlertsRefresh : Timer = Timer()
var timerForSetingsRefresh : Timer = Timer()
var refreshTime: TimeInterval = 180  // 3 min
var refreshTimeForStaticData : TimeInterval = 86400  // 1 day

let BLUE = UIColor(red:0, green:0.64, blue:0.92, alpha:1)
let GREEN = UIColor(red:0.49, green:0.83, blue:0.13, alpha:1)
let RED = UIColor(red:0.89, green:0.08, blue:0.18, alpha:1)
let GRAY = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1)
let ORANGE = UIColor(red:0.97, green:0.58, blue:0.11, alpha:1)

let errorDict = ["status" : "error"]
let noData = ["status" : "No Data"]

enum SignUpError : Error {
    case emptyEmail
    case emptyPassword
    case emptyConfirmPassword
    case invalidEmail
    case matchPasswords
    case activationCode
    case passwordLenght
}
struct SignUpErrorMsgs {
    static let enterEmail = "Please enter an email id"
    static let enterPassword = "Please enter password"
    static let enterConfirmPAssword = "Please enter confirm password"
    static let invalidEmail = "Enter valid email id"
    static let enterRegisteredEmail = "Enter registered email id"
    static let passwordMisMatch = "Passwords do not match"
    static let activationCode = "Enter valid activation code"
    static let serverError = "Server error"
    static let passwordLenght = "The password must be at least 6 characters"
}
struct SignInErrorMsgs {
    static let enterEmail = "Please enter an email id"
    static let enterPassword = "Please enter password"
    static let signInError = "Account does not exist"
    static let serverError = "Server error"
}
struct ChangePassword {
    static let currentPassword = "Please enter current password"
    static let newPassword = "Please enter new password"
    static let confirmPassword = "Please enter confirm password"
    static let passwordMissMatch = "Current password not matching"
    static let passwordsMisMatch = "New passwords do not match"
    static let newPassordSame = "Current password and new password cannot be the same"
    static let passwordLenght = "The password must be at least 6 characters"
}
struct ErrorMsgs {
    static let tryAgain = "Please Try Again!!"
    static let serverError = "Server error"
}
struct Menu {
   // static let menuTitles = ["DashBoard", "Trip History", "Car Status", "Emergency", "In-Car WIFI", "Notifications", "Settings", "Help & Support", "Logout"]
    static let menuTitles = ["Home", "Trips", "Car Status", "Emergency", "Notifications", "Settings"]
}
struct StoryBoardVC {
    static let dashBoard = "DashboardViewController"
    static let trip = "TripHistoryVC"
    static let car = "CarStausVC"
    static let emergency = "EmergencyVC"
    static let inCarWifi = "InCarWifiVC"
   // static let alerts = "AlertsNotificationMainVC"
    static let alerts = "NotificationsVC"
    static let settings = "SettingsVC"
    static let support = "HelpSupportVC"
    static let tabBar = "TabBarController"
    static let login = "SignInVC"
    static let tripTracking = "TripTrackingVC"
    static let CurrentTripDetails = "CurrentTripDetailsVC"
    static let driveAndTrack = "DriveAndTrackVC"
    static let fullScrenVC = "FullScreenMapVC"
    static let addEmergencyContact = "AddEmergencyContacts"
}
struct StoryBoardNC {
    static let dashBoard = "DashboardNC"
    static let trip = "TripHistoryNC"
    static let car = "CarStausNC"
    static let emergency = "EmergencyNC"
    static let inCarWifi = "InCarWifiNC"
  //  static let alerts = "AlertsNotificationMainNC"
    static let alerts = "NotificationsNC"
    static let settings = "SettingsNC"
    static let support = "HelpSupportNC"
    static let driveAndTrack = "DriveAndTrackNC"
    
}

struct GrandTypes {
    static let password = "password"
    static let refreshToken = "refresh_token"
}

enum FileNames : String {
    case dashBoard = "dashBoard.dat"
    case trips = "tripst.dat"
    case notifications = "notifications.dat"
    case carStatus = "carStatus.dat"
    case userInfo = "userInfo.dat"
    case carModel = "carModels.dat"
    case timeZones = "timeZones.dat"
    case vehicleInfo = "vehcleInfo.dat"
    case carModelList = "carModelList.dat"
    case carManufacturerList = "carManufacturerList.dat"
    case alerts = "alerts.dat"
    case selectedTimeZone = "timezone.dat"
}

struct AlertTypes {
    static let lowVoltage = "low_voltage"  //  diff names
    static let overHeat = "over_heat"  //  diff names
    static let fuelControl = "fuel_control"
    static let impact = "impact"
    static let faultCode  = "fault_code"
}

struct AlertTypeCat {
    static let fuelControl = "fuel_control"
    static let ignitionSystem = "ignition_system"
    static let emissionControl = "emission_control"
    static let idleControl = "idle_control"
    static let engineControl = "engine_control"
    static let transmissionSystem = "transmission_system"
    static let propulsionSystem = "propulsion_system" // icon missing
    static let networkCommunications = "network_communications"
}
struct UserAccount {
    static let name = ""
    static let email = ""
    static let contact = ""
    static let timeZone = ""
}
struct DeviceStatus {
    static let batteryStatus = ""
    static let tempStatus = ""
    static let engineStatus = ""
}
struct Profile {
    static let Email = "Invalid Email"
    static let phone = "Invalid Phone Number"
}

struct EditProfile {
    static let name = "Full Name"
    static let phone = "Contact no"
    static let password = "Password"
    static let carModel = "Car Model"
    static let vinNo = "VIN No."
    static let carPlate = "Car Plate"
    static let startingMileage = "Starting Mileage"
    static let currentMileage = "Current Mileage"
}

enum ErrorsFromAPI : String {
    case tokenError = "invalid_token"
    case invalidCredentials = "invalid_credentials"
}

/// holds constant values
struct Constants {
    
    /// all defaults values
    struct Defaults {
        static let stringValue = ""
        static let intValue = 0
        static let doubleValue = 0.0
        static let boolValue = false
    }
    
    //base URL
    struct ServerAddress {
        // static let baseURL          = "http://vw.antk.co"                 //development
        // static let baseURL          = "http://myvwdrive.atilze.com"          //UAT annd Production 1
        // static let baseURL = "http://myvwdrive.atilze.co"                  //UAT annd Production 2
       
        // KIPLECAR BASE URL --- NEW
      //  static let baseURL = "http://zte.atilze.com/"    // dev
      //  static let baseURL = "http://allianz.atilze.com/"    // prod
         static let baseURL = "http://msig.atilze.com/" // MSIG
    }
    
    // url END points
    struct APIEndPoints {
        
        // NEW KIPLECAR APIs
        static let getNotifications = "/api/notifications"  // BE WORK PENDING
        static let markNotificationsAsRead = "/api/notification/markread"
        
        //TRIPS
        static let getTripSummary = "/api/trips/summary"   // NOT USING
        static let getTrips = "/api/trips/list" // DONE
        static let getTripDetail = "/api/trip/"  // Pending
        static let reviewTrip = "/api/trip/reviewed/"
        
        // CAR STATUS 
        static let getDeviceStatus = "/api/device/status"   // DONE
        static let getAlerts = "/api/alerts" // BE WORK PENDING
        static let markAlertsAsRead = "/api/alert/markread"
        static let maskAsResolved = "api/device/markresolved/"
        
        // SETTINGS
        static let getVehicleInfo = "/api/vehicle" // DONE
        static let postVehicleInfo = "/api/vehicle" // DONE
        static let getAccountInfo = "/api/account" // DONE
        static let postAccountInfo = "/api/account/update" // DONE
        static let changePassword = "/api/account/password/change" // DONE
        static let getCarModelList = "/api/vehicle/model/list/"  // DONE
        static let getManufacturerList = "/api/vehicle/manufacturer/list" //DONE
        
        // SIGN IN
        static let login = "/oauth/token"  // DONE
        static let checkSubscription = "/api/account/subscription/check/"

        // ACCOUNT ACTIVATION
        static let getActivationCode = "/api/account/activate/resend/"   // DONE
        static let validatActivationCode = "/api/account/validate/activation/" // DONE
        static let setPassword = "/api/account/activate/" // DONE
        static let resetPassword = "/api/account/password/reset/"   // DONE
        
        // PUSH NOTIFICATIONS
        static let registerDeviceToken = "/api/account/register/token"  // DONE -- need to test more
        static let deleteDeviceToken = "/api/account/remove/token"  // DONE  // shreeee response check
    
        // WIFI
        static let getWifiDetail = "/api/setting/wifi"
        // EMERGENCY 
        static let regEmergency = "/api/service/emergency/register"
        static let cancelRequest = "/api/service/emergency/cancel/"
        // PENDING FROM OUR END
        static let getTimeZones = "/api/timezone/list"
        static let getCurrentLocationOfCar = "/api/vehicle/location/current"
        
        // SETTINGS
        static let getMqqtSeverInfo = "/api/setting/mqtt" // GET
        static let switchAccountType = "/api/setting/tracking/"  // PUT
        static let getLoginMode =  "/api/setting/tracking" // GET
    
    }
    
    // Request keys
    struct RequestKey {
        static let userId           = "user_id"
        static let token            = "token"
        static let activationCode   = "activation_code"
        
        // GET TOKEN - OAuth
        static let grantType = "grant_type"
        static let clientID = "client_id"
        static let clientSecret = "client_secret"
        static let refreshToken = "refresh_token"
        static let username = "username"
        static let password = "username"
        static let scope = "scope"
    }
    
    //for Response keys
    struct ResponseKey {
        static let oKString         = "OK"
        static let status           = "status"
        static let data             = "data"
        static let title            = "title"
        static let message          = "message"
        static let date             = "date_sent"
        
        // GET TOKEN - OAuth
        static let tokenType = "token_type"
        static let expiresin = "expires_in"
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        
    }
    //button titles
    struct ButtonTitle {
        static let okButton         = "OK"
        static let cancelButton     = "Cancel"
    }
    
    //error messages
    struct ErrorMessage {
        static let errorTitle       = "Error"
        static let loginFail        = "Those credentials don't look right. Please try again"
    }
}
