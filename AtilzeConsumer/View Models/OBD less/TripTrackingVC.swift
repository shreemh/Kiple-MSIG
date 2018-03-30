//
//  TripTrackingVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 17/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import CoreMotion
import Moscapsule
import UserNotifications

class TripTrackingVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, LocationServiceDelegate, CoreMotionDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var harshIncidentsView: UIView!
    @IBOutlet weak var speedView: UIView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var speedLbl: UILabel!
    @IBOutlet weak var hardAccelCountLbl: UILabel!
    @IBOutlet weak var hardCorneringCountLbl: UILabel!
    @IBOutlet weak var hardBrakingCountLbl: UILabel!
    
    @IBOutlet weak var GPSSignalLbl: UILabel!
    @IBOutlet weak var startButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var trackingModeBtn: UIButton!
    
    @IBOutlet weak var startStopBtn: UIButton!
    // MQTT
    // var Model.shared.mqttClient : Model.shared.mqttClient?
    var isTripStarted : Bool?
    var mqttFlag: Bool = false
    var tripSummaryDict : [String : Any] = [:]
    
    var notiCount : Int = 0
    let center = UNUserNotificationCenter.current()
    
    var lastAccelTime : Date = Date()
    var lastBrakingTime : Date = Date()
    var lastCorneringTime : Date = Date()
    var accelHalfSecTime: Date?
    var brakingHalfSecTime: Date?
    var corneringHalfSecTime: Date?
    
    var motionstatus: String = "_"
    
    /// shreeee TEST
    
    //    @IBOutlet weak var orientationLbl: UILabel!
    //    @IBOutlet weak var ax: UILabel!
    //    @IBOutlet weak var ay: UILabel!
    //    @IBOutlet weak var az: UILabel!
    //
    //
    //    @IBOutlet weak var bx: UILabel!
    //    @IBOutlet weak var by: UILabel!
    //    @IBOutlet weak var bz: UILabel!
    //
    //    @IBOutlet weak var cx: UILabel!
    //    @IBOutlet weak var cy: UILabel!
    //    @IBOutlet weak var cz: UILabel!
    //
    /// shreeee TEST
    
    var warningViews: [UIView] = [UIView]()
    enum AlertTypes : String {
        case tripStart = "trip_start"
        case tripEnd = "trip_end"
        case suspectedCollision = "suspected_collision"
        case suddenAcceleration = "sudden_acceleration"
        case suddenDeceleration  = "sudden_deceleration"
        case sharpTurn = "sharp_turn"
        case overSpeed = "over_speed"
    }
    struct AlertParams {
        var deviceId: String
        var reportTime: String
        var reportGPS: [String : Any]
        var alertType: AlertTypes
        var alertData: [String : Any]
    }
    struct TypeAndUnit {
        var type: Double
        var unit: String
    }
    struct GPSData {
        var reportTime: String
        var positionSource: String
        var height: Int
        var longitude: Double
        var latitude: Double
        var gpsSpeed: Int
        var heading: Int
        var PDOP: Double
        var HDOP: Double
        var VDOP: Double
    }
    
    //    enum Topics : String {
    //        case gpsData = "api/ztewelink/OBDless/Data/GPS"
    //        case tripSummary = "api/ztewelink/OBDless/Data/TripSummary"
    //        case alert = "api/ztewelink/OBDless/Data/Alert"
    //    }
    
    struct Topics {
        var gpsData : String
        var tripSummary : String
        var alert : String
    }
    enum GPSSignalStatus: String {
        case low = "Low"
        case weak = "Weak"
        case accurate = "Accurate"
    }
    enum GPSSignalMsgs: String {
        case low = "No GPS Signal\n GPS signal is required to start the tracking. Try moving to a location with better reception."
        case weak = "Weak GPS Signal\n Weak signal might affect accuracy of the tracking. Try moving to a location with better reception."
        case accurate = "GPS Signal Acquired"
    }
    
    var topics : Topics = Topics(gpsData: "", tripSummary: "", alert: "")
    
    var durationTimer : Timer?
    var stopTripTimer : Timer?
    var startTime: Date = Date()
    // LOCATION
    //  var prevLoc: CLLocation = CLLocation(latitude: 12.9716, longitude: 77.5946)   // SHREEEEEE ----- BALGALORE HARD CODED VALUE
    var prevLoc: CLLocation!
    
    var trackedLocations: [CLLocationCoordinate2D] = []
    var distance: Double = 0.0  // IN METERS
    
    var currentSpeed: Double = 0.0
    var previousSpeed: Double = 0.0
    
    var maxSpeed: Double = 0.0
    var previousTimestamp: Date?
    var isOverspeed : Bool = false
    
    // CORE MOTION
    var hardAccelCount: Int = 0
    var hardBrakingCount: Int = 0
    var hardCorneringCount: Int = 0
    var speedingCount: Int = 0
    
    let gspCount: Int = 20
    // var gspDictArray : [[String : Any]] = [[String : Any]]()
    
    var lastSignalStrength: String = ""
    
    
    var logFilePreviousTime : Date?
    
    // NEW LOGIC
    
    //    var gravityData: CMAcceleration?
    //    var userAccelerometerData: CMAcceleration?
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.image = UIImage(named: "emergency")
        isTripStarted = false
        setup()
        deviceMotionSetup()
        locationSetUp()
        guard let mqttDict = UserDefaults.standard.object(forKey: "VW.Consumer.MQTTInfo") as? [String : Any], let userName = mqttDict["username"] as? String else {
            return
        }
        topics = Topics(gpsData: "api/\(userName)/OBDless/Data/GPS", tripSummary: "api/\(userName)/OBDless/Data/TripSummary", alert: "api/\(userName)/OBDless/Data/Alert")
        Model.shared.isOngoingTrip = false
        
        self.speedLbl.text = "0"
        self.distanceLbl.text = "0.0"
        self.durationLbl.text = "00:00:00"
        self.hardAccelCountLbl.text = "0"
        self.hardBrakingCountLbl.text = "0"
        self.hardCorneringCountLbl.text = "0"
        
        Model.shared.isTrackingModeChanged = false
        if Utility.getLoginType().lowercased() == "auto" {
            // AUTO TRACKING
            if Model.shared.isOngoingTrip {
                startButtonHeight.constant = 50
            } else {
                startButtonHeight.constant = 0
            }
            
            trackingModeBtn.setTitle("Auto tracking", for: .normal)
            
        } else {
            // MANUAL
            startButtonHeight.constant = 50
            trackingModeBtn.setTitle("Manual", for: .normal)
        }
        if Model.shared.isOngoingTrip {
            // STOP action
            startStopBtn.setTitle("Stop", for: .normal)
        } else {
            startStopBtn.setTitle("Start", for: .normal)
        }
    }
    
    override func viewWillLayoutSubviews() {
        // navigationController?.navigationItem.hidesBackButton = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // self.Model.shared.mqttClient?.disconnect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Model.shared.isTrackingModeChanged {
            Model.shared.isTrackingModeChanged = false
            if Utility.getLoginType().lowercased() == "auto" {
                // AUTO TRACKING
                
                if Model.shared.isOngoingTrip {
                    startButtonHeight.constant = 50
                } else {
                    startButtonHeight.constant = 0
                }
                trackingModeBtn.setTitle("Auto tracking", for: .normal)

            } else {
                // MANUAL
                startButtonHeight.constant = 50
                trackingModeBtn.setTitle("Manual", for: .normal)
            }
            if Model.shared.isOngoingTrip {
                // STOP action
                startStopBtn.setTitle("Stop", for: .normal)
            } else {
                startStopBtn.setTitle("Start", for: .normal)
            }
        }
    }
    
    func resetValues() {
        distance = 0.0
        hardAccelCount = 0
        hardBrakingCount = 0
        hardCorneringCount = 0
        speedingCount = 0
        
        currentSpeed = 0.0
        previousSpeed = 0.0
        maxSpeed = 0.0
        isOverspeed = false
        
        prevLoc = nil
        previousTimestamp = nil
        
        isTripStarted = false
        mqttFlag = false
        
        DispatchQueue.main.async {
            if Utility.getLoginType().lowercased() == "auto" {
                self.startButtonHeight.constant = 0
            }
            self.speedLbl.text = "0"
            self.distanceLbl.text = "0.0"
            self.durationLbl.text = "00:00:00"
            self.hardAccelCountLbl.text = "0"
            self.hardBrakingCountLbl.text = "0"
            self.hardCorneringCountLbl.text = "0"
            Model.shared.isFromManualTracking = true
            if !Model.shared.isAutoTrackingMode {
                if Model.shared.trackedGPSDataArray.count > 0 {
                    self.navigateToReviewScreen()
                }
            } else {
                Model.shared.trackedGPSDataArray.removeAll()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        for index in 0...3 {
            if index == 3 {
                if let speedWarningView = Bundle.main.loadNibNamed("SpeedWarningView", owner: self, options: nil)?[0] as? UIView {
                    speedWarningView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: speedView.frame.height + 10)
                    speedWarningView.alpha = 0.0
                    speedView.addSubview(speedWarningView)
                    warningViews.append(speedWarningView)
                }
            }
            if let warningView = Bundle.main.loadNibNamed("WarningView", owner: self, options: nil)?[0] as? UIView {
                var xaxis: CGFloat = 0
                let label = warningView.viewWithTag(1) as? UILabel
                if index == 0 {
                    xaxis = 0
                    label?.text = "Hard Braking Detected"
                } else if index == 1 {
                    label?.text = "Hard Accel Detected"
                    xaxis = harshIncidentsView.frame.width/3
                } else {
                    label?.text = "Hard Cornering Detected"
                    xaxis = 2 * harshIncidentsView.frame.width/3
                }
                warningView.frame = CGRect(x: xaxis, y: -5, width: harshIncidentsView.frame.width/3, height: harshIncidentsView.frame.height + 5)
                warningView.alpha = 0.0
                harshIncidentsView.addSubview(warningView)
                warningViews.append(warningView)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        GPSSignalLbl.alpha = 0.0
        super.viewDidAppear(animated)
        
    }
    func deviceMotionSetup() {
        if Model.shared.deviceMotion == nil {
            Model.shared.deviceMotion = DeviceMotion.init()
        }
        Model.shared.deviceMotion?.delegate = self
    }
    func setup() {
    }
    
    func locationSetUp() {
        //        stopBtn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        //        stopBtn.isEnabled = false
        //
        if Model.shared.userLoc == nil {
            Model.shared.userLoc = UserLocation.init()
        }
        Model.shared.userLoc?.delegate = self
        mapView.showsUserLocation = true
        
        //ALTERNATIVE
        //        if motionManager.isAccelerometerAvailable {
        //            motionManager.accelerometerUpdateInterval = 2.0
        //            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (accelelerometerData: CMAccelerometerData!, error: Error!) in
        //                self.updateAccelerometerData(acceleration: accelelerometerData.acceleration)
        //            })
        //        }
        //
        //        if motionManager.isGyroAvailable {
        //            motionManager.gyroUpdateInterval = 2.0
        //            motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: { (gyroData: CMGyroData!, error: Error!) in
        //                self.updateGyroData(rotationRate: gyroData.rotationRate)
        //            })
        //        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateHeading newHeading: CLHeading) {
        
        // orientationLbl.text = String(manager.headingOrientation.rawValue)
        
    }
    
    func updateDuration() {
        // TIME
        let timeInterval: TimeInterval = Date().timeIntervalSince(startTime)
        let hours = Int(timeInterval / 3600)
        let mins = Int(timeInterval.truncatingRemainder(dividingBy: 3600) / 60)
        let secs = Int(timeInterval.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))
        
        let hoursString = hours > 9 ? String(hours) : "0" + String(hours)
        let minsString = mins > 9 ? String(mins) : "0" + String(mins)
        let secsString = secs > 9 ? String(secs) : "0" + String(secs)
        
        let lblText = hoursString + ":" + minsString + ":" + secsString
        durationLbl.text = lblText
        
    }
    
    func updateAccelerometerData(acceleration: CMAcceleration) {
        // shreeeee NOT USING
        //        let accelerationThreshold: Double = 0.3
        //        let brakingThreshold: Double = -3.5
        //        //   if fabs(acceleration.x) > accelerationThreshold || fabs(acceleration.y) > accelerationThreshold || fabs(acceleration.z) > accelerationThreshold {
        //        if acceleration.x > accelerationThreshold || acceleration.y > accelerationThreshold || acceleration.z > accelerationThreshold {
        //            // COUNT + 1 // Accel
        //            hardAccelCount =  hardAccelCount + 1
        //        } else if acceleration.x < brakingThreshold || acceleration.y < brakingThreshold || acceleration.z < -10 {
        //            // COUNT + 1 // Braking
        //            hardBrakingCount = hardBrakingCount + 1
        //        }
    }
    
    func updateGyroData(rotationRate: CMRotationRate) {
        //        print("Gyro  == \(rotationRate)")
        //        // radians --- 0.261799
        //
        //        let corneringThreshold: Double = 15000
        //        if radiansToMilliDegres(radians: rotationRate.x) > corneringThreshold || radiansToMilliDegres(radians: rotationRate.y) > corneringThreshold || radiansToMilliDegres(radians: rotationRate.z) > corneringThreshold {
        //            // COUNT + 1
        //
        //            hardCorneringCount = hardCorneringCount + 1
        //            hardCorneringCountLbl.text = String(hardCorneringCount)
        //            showWarning(warningType: 2)
        //            let turn = TypeAndUnit.init(type: 0.0, unit: "mdps")   // shreeee check UNIT
        //
        //            let alertDataDict = ["turn": ["type": turn.type, "unit": turn.unit]]
        //            let deviceID = UserDefaults.standard.object(forKey: "VW.Consumer.deviceID") as? String
        //            let alert = AlertParams.init(deviceId: deviceID ?? "", reportTime: Utility.getcurrentDate(date: Date()), reportGPS: getGPSData(), alertType: .suddenAcceleration, alertData: alertDataDict)
        //            let alertDict: [String: Any] = ["deviceId" : alert.deviceId, "reportTime" : alert.reportTime, "reportGPS" : alert.reportGPS, "alertType" : alert.alertType.rawValue, "alertData" : alert.alertData]
        //
        //            print("Dict to be passed CORNERING=== \(alertDict)")
        //
        //
        //        }
    }
    
    func notificationSetUp(msg : String, identifierName : String) {
        
//                let content = UNMutableNotificationContent()
//
//                content.title = "Hello"
//                content.body = msg
//                content.sound = UNNotificationSound.default()
//
//                // Deliver the notification in five seconds.
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//                let request = UNNotificationRequest(identifier: identifierName, content: content, trigger: trigger)
//
//                // Schedule the notification.
//                center.add(request) { (error) in
//                    print("error")
//                }
    }
    
    func showWarning(warningType : Int) {
        warningViews[warningType].alpha = 1.0
        if warningType != 3 {
            UIView.animate(withDuration: 2.0, animations: {
                self.warningViews[warningType].alpha = 0.0
            })
        } else {
            let overSpeedLbl = warningViews[3].viewWithTag(1) as? UILabel
            overSpeedLbl?.text = String(Int(currentSpeed))
        }
    }
    
    func radiansToMilliDegres(radians: Double) -> Double {
        let oneDegree: Double = (180 / .pi) //radians to degree
        let degree =  oneDegree * fabs(radians)
        let milliDegrees = degree * 1000
        return milliDegrees
    }
    
    func radiansToDegres(radians: Double) -> Double {
        let oneDegree: Double = (180 / .pi) //radians to degree
        let degree =  oneDegree * fabs(radians)
        return degree
    }
    
    func getGPSData() -> [String : Any] {
        let heightTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.location?.altitude ?? 0, unit: "m")
        let longitudeTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.location?.coordinate.longitude ?? 0, unit: "")
        let latitudeTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.location?.coordinate.latitude ?? 0, unit: "")
        let gpsSpeedTypeNUnit = TypeAndUnit.init(type: currentSpeed, unit: "km/h")
        let headingTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.heading?.trueHeading ?? 0, unit: "")
        let PDOPTypeNUnit = TypeAndUnit.init(type: 0.0, unit: "")
        let HDOPTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.location?.horizontalAccuracy ?? 0, unit: "")
        let VDOPTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.location?.verticalAccuracy ?? 0, unit: "")
        
        let gpsData = GPSData.init(reportTime: Utility.getcurrentDate(date: Date()), positionSource: "GPS", height: Int(heightTypeNUnit.type), longitude: longitudeTypeNUnit.type, latitude:  latitudeTypeNUnit.type, gpsSpeed: Int(gpsSpeedTypeNUnit.type), heading: Int(headingTypeNUnit.type), PDOP: PDOPTypeNUnit.type, HDOP: HDOPTypeNUnit.type, VDOP: VDOPTypeNUnit.type)
        
        let gpsDataDict:[String : Any] = ["reportTime": gpsData.reportTime, "positionSource": gpsData.positionSource, "height": gpsData.height, "longitude": gpsData.longitude, "latitude": gpsData.latitude, "gpsSpeed": gpsData.gpsSpeed, "heading": gpsData.heading, "PDOP": gpsData.PDOP, "HDOP": gpsData.HDOP, "VDOP": gpsData.VDOP]
        
        return gpsDataDict
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func manualStartBtnCall(_ sender: Any) {
        if Model.shared.isOngoingTrip {
            // STOP action
            startStopBtn.setTitle("Start", for: .normal)
            stopTrip()
        } else {
            startStopBtn.setTitle("Stop", for: .normal)
            startTimer()
        }
    }
    
    @IBAction func trackingModeBtnCall(_ sender: Any) {
//        stopTrip()
//        if Model.shared.isAutoTrackingMode {
//            // MANUAL
//            Model.shared.isAutoTrackingMode = false
//            startButtonHeight.constant = 50
//            trackingModeBtn.setTitle("Manual", for: .normal)
//        } else {
//            // AUTO TRACKING
//            Model.shared.isAutoTrackingMode = true
//            startButtonHeight.constant = 0
//            trackingModeBtn.setTitle("Auto tracking", for: .normal)
//        }
    }
    
    func startTimer() {
        // flushPendingData()
        csvtext = "seconds beforeFilter_x beforeFilter_y beforeFilter_z afterFilter_x afterFilter_y afterFilter_z gravity_x gravity_y gravity_z gravity_magnitude longitudinal_x longitudinal_y longitudinal_z longitudinal_magnitude latitudinal_x latitudinal_y latitudinal_z latitudinal_magnitude Speed Events UserMotion\n"
        Model.shared.isOngoingTrip = true
        Model.shared.userLoc?.startUpdatingLocation()
        GPSSignalLbl.alpha = 1.0
        startTime = Date()
        tripSummaryDict = [:]
        durationTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)
        startButtonHeight.constant = 50
        startStopBtn.setTitle("Stop", for: .normal)
    }
    
    func stopTrip() {
        //   Model.shared.userLoc?.stopUpdatingLocation()
        durationTimer?.invalidate()
        Model.shared.isOngoingTrip = false
        isTripStarted = false
        Model.shared.lowPassFilterData = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
        guard Model.shared.trackedGPSDataArray.count > 0 else {
            resetValues()
            return
        }
        if !Model.shared.isinBackgroundState {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateDrivingStatus"), object: nil)
        }
        
        // shreeeee maxSpeed is speeding count or max speed during trip???
        let deviceID = UserDefaults.standard.object(forKey: "VW.Consumer.deviceID") as? String
        
        let alert = AlertParams.init(deviceId: deviceID ?? "", reportTime: Utility.getcurrentDate(date: Date()), reportGPS: getGPSData(), alertType: .tripEnd, alertData: [:])
        let alertDict: [String: Any] = ["deviceId" : alert.deviceId, "reportTime" : alert.reportTime, "reportGPS" : alert.reportGPS, "alertType" : alert.alertType.rawValue, "alertData" : alert.alertData]
        
//        // SHREEEEEE LOG TRIPS
//        Model.shared.tripsLogDict["STOP"] = alertDict
//        store(dictionary: Model.shared.tripsLogDict, in: "Trip_" + Utility.getcurrentDate(date: Date()), at: "Trips")
//        Model.shared.tripsLogDict.removeAll()
        
        let startLoc: [String : Any] = Model.shared.trackedGPSDataArray[0]
        let endLoc:  [String : Any] = Model.shared.trackedGPSDataArray[Model.shared.trackedGPSDataArray.count - 1]
        guard let startLocGPSArray = startLoc["gpsData"] as? [[String : Any]], let endLocGPSArray = endLoc["gpsData"] as? [[String : Any]] else {
            return
        }
        
        let ignitionOnTime = startLocGPSArray[0]["reportTime"] ?? Date()
        let ignitionOffTime = endLocGPSArray[0]["reportTime"] ?? Date()
        tripSummaryDict = ["deviceId" : deviceID ?? "", "reportTime" : Utility.getcurrentDate(date: Date()), "ignitionOnTime" : ignitionOnTime, "gpsWhenIgnitionOn" : startLocGPSArray[0], "ignitionOffTime" : ignitionOffTime, "gpsWhenIgnitionOff" : endLocGPSArray[0], "drivingDistance" : distance, "maxSpeed" : maxSpeed, "numberRapidAcce" : hardAccelCount, "numberRapidDece" : hardBrakingCount, "numberRapidSharpTurn" : hardCorneringCount, "numberOverSpeed": speedingCount]
        
        if Utility.isConnectedToNetwork() {
            DispatchQueue.main.async {
                let previousGPSData : [String : Any] = UserDefaults.standard.object(forKey: "VW.Consumer.GPSData") as? [String : Any] ?? [String : Any]()
                var previousDataArray = previousGPSData["gpsData"] as? [[String : Any]] ?? [[String : Any]]()
                previousDataArray.append(contentsOf: Model.shared.gspDictArray)
                if previousDataArray.count > 0 {
                    let trackGPSDict: [String : Any] = ["deviceId": deviceID ?? "", "gpsData": previousDataArray, "deviceStatus" : ["drivingDistance" : self.distance, "maxSpeed" : self.maxSpeed]]
                    
                    print("trackGPSDict == \(trackGPSDict)")
                    MQTTObject.sharedInstance.mqttGPSData(dict: trackGPSDict)
                }
                
                
                print("alertDict Stop ==\(alertDict)")
                print("self.tripSummaryDict summary == \(self.tripSummaryDict)")
                
                
                MQTTObject.sharedInstance.mqttStopAlert(dict: alertDict, topic : self.topics.alert)
                MQTTObject.sharedInstance.mqttTripSummary(dict: self.tripSummaryDict, topic : self.topics.tripSummary)
                self.resetValues()
            }
        } else {
            UserDefaults.standard.set(alertDict, forKey: "VW.Consumer.Stop")
            UserDefaults.standard.set(self.tripSummaryDict, forKey: "VW.Consumer.Summary")
            resetValues()
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    func navigateToReviewScreen() {
        // Navigate
        DispatchQueue.main.async {
            if let tripDetailsVC = mainSB.instantiateViewController(withIdentifier: StoryBoardVC.CurrentTripDetails) as? TripSummaryVC {
                // CLEAR ARRAY ELEMENTS
                Model.shared.trackedGPSDataArray.removeAll()
                let backItem = UIBarButtonItem()
                backItem.title = ""
                self.navigationItem.backBarButtonItem = backItem
                tripDetailsVC.locations2DArray = self.trackedLocations
                self.trackedLocations.removeAll()
                let timeInterval: TimeInterval = Date().timeIntervalSince(self.startTime)
                tripDetailsVC.tripSummary = self.tripSummaryDict
                tripDetailsVC.totalDuration = Double(timeInterval)
                self.navigationController?.pushViewController(tripDetailsVC, animated: true)
            }
        }
    }
    
    //    PLAN ZZZ
    //
    //    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    //    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    //
    //    func getBearingBetweenTwoPoints1(point1 : CLLocation, point2 : CLLocation) -> Double {
    //
    //        let lat1 = degreesToRadians(degrees: point1.coordinate.latitude)
    //        let lon1 = degreesToRadians(degrees: point1.coordinate.longitude)
    //
    //        let lat2 = degreesToRadians(degrees: point2.coordinate.latitude)
    //        let lon2 = degreesToRadians(degrees: point2.coordinate.longitude)
    //
    //        let dLon = lon2 - lon1
    //
    //        let y = sin(dLon) * cos(lat2)
    //        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    //        let radiansBearing = atan2(y, x)
    //
    //        return radiansToDegrees(radians: radiansBearing)
    //    }
    //
    // MARK: - LocationServiceDelegate
    
    func tracingLocation(currentLocation: CLLocation, GPSSignal : String) {
        //        print("currentLocation TRIP TRACKING ==== \(currentLocation)")
        //        print("currentLocation.speed == \(currentLocation.speed)")
        
        mapView.setUserTrackingMode(.follow, animated:true)
        
        if Model.shared.isAutoTrackingMode {
            let speedminsec: Double = Model.shared.userLoc?.locationManager?.location?.speed ?? 0.0
            let speed = speedminsec > 0.0 ? speedminsec * 3.6 : 0
            if speed < 5 {
                // speedLbl.text = "stationary"
                if speed == 0 {
                    // print("stationary")
                    currentSpeed = 0.0
                    // speedLbl.text = "0"
                    // speedLbl.text = "stationary"
                } else {
                   // print("walking")
                    currentSpeed = 0.0
                }
                if Model.shared.isOngoingTrip, !Model.shared.stopped {
                    Model.shared.stopped = true
                    stopTripTimer?.invalidate()
                    stopTripTimer = Timer.scheduledTimer(timeInterval: TimeInterval(stopTripDuration), target: self, selector: #selector(stopTripUpdate), userInfo: nil, repeats: false)
                }
                
            } else if speed > 5 {
                stopTripTimer?.invalidate()
                Model.shared.stopped = false
                if !Model.shared.isOngoingTrip{
                    if speed > 10 {
                        startTimer()
                    }
                }
            }
        }
        
        if Model.shared.isOngoingTrip {
            if lastSignalStrength != Model.shared.userLoc?.signalStrength {
                GPSSignalLbl.alpha = 1.0
                lastSignalStrength = (Model.shared.userLoc?.signalStrength)!
                switch Model.shared.userLoc?.signalStrength {
                case GPSSignalStatus.low.rawValue?:
                    // startBtn.isEnabled = false
                    // startBtn.backgroundColor = GRAY
                    GPSSignalLbl.text = GPSSignalMsgs.low.rawValue
                    GPSSignalLbl.backgroundColor = BLUE
                    UIView.animate(withDuration: 3.0, animations: {
                        self.GPSSignalLbl.text = "No GPS Signal"
                    })
                    break
                case GPSSignalStatus.weak.rawValue?:
                    // startBtn.isEnabled = true
                    // startBtn.backgroundColor = BLUE
                    GPSSignalLbl.text = GPSSignalMsgs.weak.rawValue
                    GPSSignalLbl.backgroundColor = ORANGE
                    UIView.animate(withDuration: 3.0, animations: {
                        self.GPSSignalLbl.text = "Weak GPS Signal"
                    })
                    break
                default:
                    // startBtn.isEnabled = true
                    // startBtn.backgroundColor = BLUE
                    GPSSignalLbl.text = GPSSignalMsgs.accurate.rawValue
                    GPSSignalLbl.backgroundColor = GREEN
                    UIView.animate(withDuration: 2.0, animations: {
                        self.GPSSignalLbl.alpha = 0.0
                    })
                    break
                }
            } else {
                if lastSignalStrength.isEmpty {
                    lastSignalStrength = (Model.shared.userLoc?.signalStrength)!
                }
                if Model.shared.userLoc?.signalStrength.lowercased() == "accurate" {
                    UIView.animate(withDuration: 2.0, animations: {
                        self.GPSSignalLbl.alpha = 0.0
                    })
                } else {
                    self.GPSSignalLbl.alpha = 1.0
                }
            }
            
            if Model.shared.userLoc?.locationManager?.location?.speed == -1 {
                // CALCULATE SPEED MANUALLY
                // Distance / time
                
            } else {
                let speed: Double = Model.shared.userLoc?.locationManager?.location?.speed ?? 0.0
                currentSpeed = speed > 0.0 ? speed * 3.6 : 0
                speedLbl.text = currentSpeed > 0 ? String(Int(currentSpeed)) : "0"
                maxSpeed = currentSpeed > maxSpeed ? currentSpeed : maxSpeed
            }
            let overSpeedLbl = warningViews[3].viewWithTag(1) as? UILabel
            overSpeedLbl?.text = String(Int(currentSpeed))
            
            if currentSpeed > speedLimit, !isOverspeed, Model.shared.userLoc?.signalStrength != GPSSignalStatus.low.rawValue, isTripStarted! {
                isOverspeed = true
                showWarning(warningType: 3)
                speedingCount = speedingCount + 1
                let alertDataDict = ["maxSpeed": currentSpeed, "speedLimit": speedLimit]
                let deviceID = UserDefaults.standard.object(forKey: "VW.Consumer.deviceID") as? String
                let alert = AlertParams.init(deviceId: deviceID ?? "", reportTime: Utility.getcurrentDate(date: Date()), reportGPS: getGPSData(), alertType: .overSpeed, alertData: alertDataDict)
                
                let alertDict: [String: Any] = ["deviceId" : alert.deviceId, "reportTime" : alert.reportTime, "reportGPS" : alert.reportGPS, "alertType" : alert.alertType.rawValue, "alertData" : alert.alertData]
                print("Dict to be passed OVERSPEED === \(alertDict)")
                if Utility.isConnectedToNetwork() {
                    MQTTObject.sharedInstance.mqttAlert(dict: alertDict, topic: topics.alert)
//                    var tempArray : [[String : Any]] = Model.shared.tripsLogDict["INCIDENTS"] as? [[String : Any]] ?? [[String : Any]]()
//                    tempArray.append(alertDict)
//                    Model.shared.tripsLogDict["INCIDENTS"] = tempArray
                } else {
                    var previousIncidentsData : [[String : Any]] = UserDefaults.standard.object(forKey: "VW.Consumer.Incidents") as? [[String : Any]] ?? [[String : Any]]()
                    previousIncidentsData.append(alertDict)
                    UserDefaults.standard.set(previousIncidentsData, forKey: "VW.Consumer.Incidents")
                }
            }
            
            if currentSpeed < speedLimit, isOverspeed {
                isOverspeed = false
                self.warningViews[3].alpha = 0.0
            }
            
            let deviceID = UserDefaults.standard.object(forKey: "VW.Consumer.deviceID") as? String
            
            if !(isTripStarted!) {
                // Clear Trips related UserDefaults
                Utility.clearTripData()
            }
            
            if !(isTripStarted!), (Model.shared.userLoc?.signalStrength != GPSSignalStatus.low.rawValue), distance >= 200.0 {
                
                isTripStarted = true
                // START TRIP
                let alert = AlertParams.init(deviceId: deviceID ?? "", reportTime: Utility.getcurrentDate(date: Date()), reportGPS: getGPSData(), alertType: .tripStart, alertData: [:])
                let alertDict: [String: Any] = ["deviceId" : alert.deviceId, "reportTime" : alert.reportTime, "reportGPS" : alert.reportGPS, "alertType" : alert.alertType.rawValue]
                if Utility.isConnectedToNetwork() {
                   // Model.shared.tripsLogDict["Start"] = alertDict
                   // UserDefaults.standard.set(alertDict, forKey: "VW.Consumer.Start")
                    MQTTObject.sharedInstance.mqttAlert(dict: alertDict, topic: topics.alert)
                } else {
                    UserDefaults.standard.set(alertDict, forKey: "VW.Consumer.Start")
                }
            }
            
            let lastLocation = Model.shared.userLoc?.locationManager?.location
            var timeDiffInSec: TimeInterval = 5
            if previousTimestamp != nil {
                timeDiffInSec = Date().timeIntervalSince(previousTimestamp ?? Date())
            }
            
            if Int(timeDiffInSec) >= 5 {
                if prevLoc == nil {
                    prevLoc = lastLocation
                }
                // STORE ALL LOCATIONS TO trackedLocations ARRAY
                if Model.shared.userLoc?.locationManager?.location?.coordinate != nil, prevLoc != nil {
                    previousSpeed = currentSpeed
                    trackedLocations.append((Model.shared.userLoc?.locationManager?.location?.coordinate)!)
                    previousTimestamp = prevLoc?.timestamp
                    let currentDistanceInMeters = lastLocation?.distance(from: prevLoc)
                    distance =  distance + currentDistanceInMeters!
                    if currentDistanceInMeters != 0 {
                        distanceLbl.attributedText = Utility.attributedText(completeText: (String(format:"%.1f", distance/1000)) + " km", primaryText: String(format:"%.1f", distance/1000), secondaryText: " km")
                    }
                }
                prevLoc = lastLocation
                if isTripStarted! {
                    let heightTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.location?.altitude ?? 0, unit: "m")
                    let longitudeTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.location?.coordinate.longitude ?? 0, unit: "")
                    let latitudeTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.location?.coordinate.latitude ?? 0, unit: "")
                    let gpsSpeedTypeNUnit = TypeAndUnit.init(type: currentSpeed, unit: "km/h")
                    let headingTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.heading?.trueHeading ?? 0, unit: "")
                    let PDOPTypeNUnit = TypeAndUnit.init(type: 0.0, unit: "")
                    let HDOPTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.location?.horizontalAccuracy ?? 0, unit: "")
                    let VDOPTypeNUnit = TypeAndUnit.init(type: Model.shared.userLoc?.locationManager?.location?.verticalAccuracy ?? 0, unit: "")
                    
                    let gpsData = GPSData.init(reportTime: Utility.getcurrentDate(date: Date()), positionSource: "GPS", height: Int(heightTypeNUnit.type), longitude: longitudeTypeNUnit.type, latitude:  latitudeTypeNUnit.type, gpsSpeed: Int(gpsSpeedTypeNUnit.type), heading: Int(headingTypeNUnit.type), PDOP: PDOPTypeNUnit.type, HDOP: HDOPTypeNUnit.type, VDOP: VDOPTypeNUnit.type)
                    
                    let gpsDataDict:[String : Any] = ["reportTime": gpsData.reportTime, "positionSource": gpsData.positionSource, "height": gpsData.height, "longitude": gpsData.longitude, "latitude": gpsData.latitude, "gpsSpeed": gpsData.gpsSpeed, "heading": gpsData.heading, "PDOP": gpsData.PDOP, "HDOP": gpsData.HDOP, "VDOP": gpsData.VDOP]
                    let deviceID = UserDefaults.standard.object(forKey: "VW.Consumer.deviceID") as? String
                    
                    let trackGPSDict: [String : Any] = ["deviceId": deviceID ?? "", "gpsData": [gpsDataDict]]
                    
                    Model.shared.trackedGPSDataArray.append(trackGPSDict)
                    //  stopBtn.isEnabled = true
                    
                    Model.shared.gspDictArray.append(gpsDataDict)
                    if !Model.shared.isinBackgroundState, Model.shared.gspDictArray.count > self.gspCount {
                        let previousGPSData : [String : Any] = UserDefaults.standard.object(forKey: "VW.Consumer.GPSData") as? [String : Any] ?? [String : Any]()
                        var previousDataArray = previousGPSData["gpsData"] as? [[String : Any]] ?? [[String : Any]]()
                        previousDataArray.append(contentsOf: Model.shared.gspDictArray)
                        let trackGPSDict: [String : Any] = ["deviceId": deviceID ?? "", "gpsData": previousDataArray, "deviceStatus" : ["drivingDistance" : distance, "maxSpeed" : maxSpeed]]
                        Model.shared.gspDictArray.removeAll()
                        if Utility.isConnectedToNetwork() {
                            MQTTObject.sharedInstance.mqttGPSData(dict: trackGPSDict)
                        } else {
                            UserDefaults.standard.set(trackGPSDict, forKey: "VW.Consumer.GPSData")
                        }
                    } else if Model.shared.isinBackgroundState, Model.shared.gspDictArray.count > 1 {
                        let previousGPSData : [String : Any] = UserDefaults.standard.object(forKey: "VW.Consumer.GPSData") as? [String : Any] ?? [String : Any]()
                        var previousDataArray = previousGPSData["gpsData"] as? [[String : Any]] ?? [[String : Any]]()
                        previousDataArray.append(contentsOf: Model.shared.gspDictArray)
                        let trackGPSDict: [String : Any] = ["deviceId": deviceID ?? "", "gpsData": previousDataArray]
                        Model.shared.gspDictArray.removeAll()
                        if Utility.isConnectedToNetwork() {
                            MQTTObject.sharedInstance.mqttGPSData(dict: trackGPSDict)
                        } else {
                            UserDefaults.standard.set(trackGPSDict, forKey: "VW.Consumer.GPSData")
                        }
                    }
                }
            }
        }
    }
    
    func tracingLocationDidFailWithError(error: NSError) {
        print("tracingLocationDidFailWithError TRIP TRACKING")
    }
    
    // MARK: - FILE test
    func store(dictionary: [String : Any], in fileName: String, at directory: String) {
        let fileExtension = "plist"
        let directoryURL = create(directory:directory)
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)
            try data.write(to: directoryURL.appendingPathComponent(fileName).appendingPathExtension(fileExtension))
            // return true
        } catch {
            print(error)
            // return false
        }
    }
    
    // MARK: - FILE test
    func storeCSVFile(str: String, in fileName: String, at directory: String) {
        let fileExtension = "csv"
        let directoryURL = create(directory:directory)
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: str, format: .xml, options: 0)
            try data.write(to: directoryURL.appendingPathComponent(fileName).appendingPathExtension(fileExtension))
            // return true
        } catch {
            print(error)
            // return false
        }
    }
    
    func create(directory: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentsDirectory.appendingPathComponent(directory)
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            fatalError("Error creating directory: \(error.localizedDescription)")
        }
        return directoryURL
    }
    
    
    // PLAN A
    
    
    //    if(Model.shared.prevTime == nil) {
    //    Model.shared.prevTime = Date()
    //    }
    //    let interval: Double = Date().timeIntervalSince(Model.shared.prevTime ?? Date())
    //    Model.shared.prevTime = Date()
    //
    //    Model.shared.velValues.x += Model.shared.lowPassFilterData.x * interval
    //    Model.shared.velValues.y += Model.shared.lowPassFilterData.y *  interval
    //    Model.shared.velValues.z += Model.shared.lowPassFilterData.z * interval
    //
    //    Model.shared.currentLocation.x = Model.shared.velValues.x * interval + (0.5 * Model.shared.lowPassFilterData.x) * interval * interval
    //    Model.shared.currentLocation.y = Model.shared.velValues.y * interval + (0.5 * Model.shared.lowPassFilterData.y) * interval * interval
    //    Model.shared.currentLocation.z = (Model.shared.velValues.z * interval) + (0.5 * Model.shared.lowPassFilterData.z) * interval * interval
    //
    //    var dirOfTravel: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
    //    dirOfTravel.x = Model.shared.currentLocation.x - Model.shared.previousLocation.x
    //    dirOfTravel.y = Model.shared.currentLocation.y - Model.shared.previousLocation.y
    //    dirOfTravel.z = Model.shared.currentLocation.z - Model.shared.previousLocation.z
    //
    //    Model.shared.previousLocation = Model.shared.currentLocation
    //    Model.shared.overallForwardDir.x += dirOfTravel.x
    //    Model.shared.overallForwardDir.x += dirOfTravel.y
    //    Model.shared.overallForwardDir.x += dirOfTravel.z
    //
    
    
    // MARK: - CoreMotionDelegate  PLAN B
    func tracingDeviceMotion(deviceMotion: CMDeviceMotion) {
        if csvtext.isEmpty {
            csvtext =  "seconds beforeFilter_x beforeFilter_y beforeFilter_z afterFilter_x afterFilter_y afterFilter_z gravity_x gravity_y gravity_z gravity_magnitude longitudinal_x longitudinal_y longitudinal_z longitudinal_magnitude latitudinal_x latitudinal_y latitudinal_z latitudinal_magnitude Speed UserMotion\n"
        }
        var newLine: String = ""
        if logFilePreviousTime == nil {
            logFilePreviousTime = Date()
        }
        // TIME
        let timeInterval: TimeInterval = Date().timeIntervalSince(logFilePreviousTime!)
        logFilePreviousTime = Date()
        
        if isTripStarted! {
            // print("deviceMotion == \(deviceMotion.userAcceleration)")
            Model.shared.gravityData = deviceMotion.gravity
            // apply lowPassFilter to userAccelerometerData
            
            var userDataAftMultiplyingGValue : CMAcceleration =  CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
            userDataAftMultiplyingGValue.x = deviceMotion.userAcceleration.x * 9.81
            userDataAftMultiplyingGValue.y = deviceMotion.userAcceleration.y * 9.81
            userDataAftMultiplyingGValue.z = deviceMotion.userAcceleration.z * 9.81
            
            Model.shared.lowPassFilterData = lowPassFilter(userData: userDataAftMultiplyingGValue)
            Model.shared.userAccelerometerData = Model.shared.lowPassFilterData
            //calculate gravity along three directions
            let gravity_xSqr = (Model.shared.gravityData.x) * (Model.shared.gravityData.x)
            let gravity_ySqr = (Model.shared.gravityData.y) * (Model.shared.gravityData.y)
            let gravity_zSqr = (Model.shared.gravityData.z) * (Model.shared.gravityData.z)
            let gravityMagnitude = sqrt(Double(gravity_xSqr + gravity_ySqr + gravity_zSqr))
            
            var gravityDir:CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
            gravityDir.x = (Model.shared.gravityData.x) / gravityMagnitude
            gravityDir.y = (Model.shared.gravityData.y) / gravityMagnitude
            gravityDir.z = (Model.shared.gravityData.z) / gravityMagnitude
            
            var gravityZVector: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
            let zVector: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 1.0)
            
            gravityZVector.x = (gravityDir.y * zVector.z) - (zVector.y * gravityDir.z)
            gravityZVector.y = (gravityDir.z * zVector.x) - (zVector.z * gravityDir.x)
            gravityZVector.z = (gravityDir.x * zVector.y) - (zVector.x * gravityDir.y)
            
            let gravityZVector_xSqr = (gravityZVector.x) * (gravityZVector.x)
            let gravityZVector_ySqr = (gravityZVector.y) * (gravityZVector.y)
            let gravityZVector_zSqr = (gravityZVector.z) * (gravityZVector.z)
            let gravityZVectorMagnitude = sqrt(Double(gravityZVector_xSqr + gravityZVector_ySqr + gravityZVector_zSqr))
            
            var longitudeDir: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
            var latitudeDir: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
            
            if gravityZVectorMagnitude < 0.1 {
                latitudeDir.x = 1.0
                latitudeDir.y = 0.0
                latitudeDir.z = 0.0
                
                longitudeDir.x = 0.0
                longitudeDir.y = 1.0
                longitudeDir.z = 0.0
            } else {
                latitudeDir.x = (zVector.y * gravityDir.z) - (gravityDir.y * zVector.z)
                latitudeDir.y = (zVector.z * gravityDir.x) - (gravityDir.z * zVector.x)
                latitudeDir.z = (zVector.x * gravityDir.y) - (gravityDir.x * zVector.y)
                
                longitudeDir.x = -zVector.x
                longitudeDir.y = -zVector.y
                longitudeDir.z = -zVector.z
            }
            
            //Acceleration and braking detection
            let longitudinalMagnitudeTemp: Double = dotProduct(userMotionData: Model.shared.userAccelerometerData, latOrLongData: longitudeDir)
            
            let longitudinalMagnitude: Double = -longitudinalMagnitudeTemp
            
            let latitudeDir_xSqr = (latitudeDir.x) *  (latitudeDir.x)
            let latitudeDir_ySqr = (latitudeDir.y) * (latitudeDir.y)
            let latitudeDir_zSqr = (latitudeDir.z) * (latitudeDir.z)
            let latitudeDirMagnitude = sqrt(Double(latitudeDir_xSqr + latitudeDir_ySqr + latitudeDir_zSqr))
            
            latitudeDir.x = (latitudeDir.x) / latitudeDirMagnitude
            latitudeDir.y = (latitudeDir.y) / latitudeDirMagnitude
            latitudeDir.z = (latitudeDir.z) / latitudeDirMagnitude
            
            // Cornering detection
            let latitudinalMagnitude: Double = dotProduct(userMotionData: Model.shared.userAccelerometerData, latOrLongData: latitudeDir)
            
            //            print("CORNERING == \(String(format:"%.5f", latitudinalMagnitude))")
            //            print("ACCEL BRAKING  == \(String(format:"%.5f", longitudinalMagnitude))")
            
            newLine = String(timeInterval) + " " + (String(format:"%.5f", userDataAftMultiplyingGValue.x)) + " " + (String(format:"%.5f", userDataAftMultiplyingGValue.y)) + " " + (String(format:"%.5f", userDataAftMultiplyingGValue.z)) + " "  + (String(format:"%.5f", Model.shared.userAccelerometerData.x)) + " " + (String(format:"%.5f", Model.shared.userAccelerometerData.y)) + " " + (String(format:"%.5f", Model.shared.userAccelerometerData.z))
            
            var event: String = "-"
            if longitudinalMagnitude > accelerationThreshold, Date().timeIntervalSince(lastAccelTime) > 5, Date().timeIntervalSince(lastBrakingTime) > 2, currentSpeed > 30 {
                
                // INITIALISATION
                if accelHalfSecTime == nil {
                    accelHalfSecTime = Date()
                }
                
                if Date().timeIntervalSince((accelHalfSecTime)!) > 0.5 {
                    accelHalfSecTime = nil
                    lastAccelTime = Date()
                    print("ACCEL")
                    event = "A"
                    // ACCEL
                    let accelValue = longitudinalMagnitude
                    hardAccelCount =  hardAccelCount + 1
                    hardAccelCountLbl.text = String(hardAccelCount)
                    showWarning(warningType: 1)
                    
                    // COUNT + 1 // Accel
                    let speedBefAcc = TypeAndUnit.init(type: previousSpeed, unit: "km/h")
                    let speedAftAcc = TypeAndUnit.init(type: currentSpeed, unit: "km/h")
                    let accValue = TypeAndUnit.init(type: accelValue * 1000, unit: "m/s^2")
                    
                    let alertDataDict = ["speedBeforeAcc": speedBefAcc.type, "speedAfterAcc": speedAftAcc.type, "accValue": accValue.type]
                    let deviceID = UserDefaults.standard.object(forKey: "VW.Consumer.deviceID") as? String
                    let alert = AlertParams.init(deviceId: deviceID ?? "", reportTime: Utility.getcurrentDate(date: Date()), reportGPS: getGPSData(), alertType: .suddenAcceleration, alertData: alertDataDict)
                    
                    let alertDict: [String: Any] = ["deviceId" : alert.deviceId, "reportTime" : alert.reportTime, "reportGPS" : alert.reportGPS, "alertType" : alert.alertType.rawValue, "alertData" : alert.alertData]
                    print("Dict to be passed ACCEL=== \(alertDict)")
                    if Utility.isConnectedToNetwork() {
//                        var accelDict = alertDict
//                        accelDict["gravityDirection"] = gravityDir
//                        var tempArray : [[String : Any]] = Model.shared.tripsLogDict["INCIDENTS"] as? [[String : Any]] ?? [[String : Any]]()
//                        tempArray.append(accelDict)
//                        Model.shared.tripsLogDict["INCIDENTS"] = tempArray
                        MQTTObject.sharedInstance.mqttAlert(dict: alertDict, topic: topics.alert)
                    } else {
                        var previousIncidentsData : [[String : Any]] = UserDefaults.standard.object(forKey: "VW.Consumer.Incidents") as? [[String : Any]] ?? [[String : Any]]()
                        previousIncidentsData.append(alertDict)
                        UserDefaults.standard.set(previousIncidentsData, forKey: "VW.Consumer.Incidents")
                    }
                }
            } else if accelHalfSecTime != nil, Date().timeIntervalSince((accelHalfSecTime)!) > 0.6 {
                accelHalfSecTime = nil
            }
            
            if longitudinalMagnitude < brakingThreshold, Date().timeIntervalSince(lastBrakingTime) > 5, Date().timeIntervalSince(lastAccelTime) > 2  {
                
                // INITIALISATION
                if brakingHalfSecTime == nil {
                    brakingHalfSecTime = Date()
                }
                
                if Date().timeIntervalSince((brakingHalfSecTime)!) > 0.5 {
                    brakingHalfSecTime = nil
                    print("BRAKING")
                    event = "B"
                    lastBrakingTime = Date()
                    // BRAKING
                    let brakingValue = longitudinalMagnitude
                    // COUNT + 1 // Braking
                    hardBrakingCount = hardBrakingCount + 1
                    hardBrakingCountLbl.text = String(hardBrakingCount)
                    showWarning(warningType: 0)
                    
                    let speedBefDec = TypeAndUnit.init(type: previousSpeed, unit: "km/h")
                    let speedAftDec = TypeAndUnit.init(type: currentSpeed, unit: "km/h")
                    let decValue = TypeAndUnit.init(type: brakingValue * 1000, unit: "m/s^2")
                    
                    let alertDataDict = ["speedBeforeDec": speedBefDec.type, "speedAfterDec": speedAftDec.type, "decValue": decValue.type]
                    
                    let deviceID = UserDefaults.standard.object(forKey: "VW.Consumer.deviceID") as? String
                    let alert = AlertParams.init(deviceId: deviceID ?? "", reportTime: Utility.getcurrentDate(date: Date()), reportGPS: getGPSData(), alertType: .suddenDeceleration, alertData: alertDataDict)
                    
                    let alertDict: [String: Any] = ["deviceId" : alert.deviceId, "reportTime" : alert.reportTime, "reportGPS" : alert.reportGPS, "alertType" : alert.alertType.rawValue, "alertData" : alert.alertData]
                
                    if Utility.isConnectedToNetwork() {
                        MQTTObject.sharedInstance.mqttAlert(dict: alertDict, topic: topics.alert)
//                        var brakDict = alertDict
//                        brakDict["gravityDirection"] = gravityDir
//                        var tempArray : [[String : Any]] = Model.shared.tripsLogDict["INCIDENTS"] as? [[String : Any]] ?? [[String : Any]]()
//                        tempArray.append(brakDict)
//                        Model.shared.tripsLogDict["INCIDENTS"] = tempArray
                    } else {
                        var previousIncidentsData : [[String : Any]] = UserDefaults.standard.object(forKey: "VW.Consumer.Incidents") as? [[String : Any]] ?? [[String : Any]]()
                        previousIncidentsData.append(alertDict)
                        UserDefaults.standard.set(previousIncidentsData, forKey: "VW.Consumer.Incidents")
                    }
                }
            } else if brakingHalfSecTime != nil, Date().timeIntervalSince((brakingHalfSecTime)!) > 0.6 {
                brakingHalfSecTime = nil
            }
            
            if latitudinalMagnitude > corneringThreshold || latitudinalMagnitude < -corneringThreshold,  Date().timeIntervalSince(lastCorneringTime) > 5 {
                
                // INITIALISATION
                if corneringHalfSecTime == nil {
                    corneringHalfSecTime = Date()
                }
                
                if Date().timeIntervalSince((corneringHalfSecTime)!) > 0.5 {
                    corneringHalfSecTime = nil
                    print("CORNERING")
                    event = "C"
                    // CORNERING
                    lastCorneringTime = Date()
                    let corneringValue = latitudinalMagnitude
                    
                    hardCorneringCount = hardCorneringCount + 1
                    hardCorneringCountLbl.text = String(hardCorneringCount)
                    showWarning(warningType: 2)
                    
                    let turn = TypeAndUnit.init(type: corneringValue, unit: "g/s^2")   // shreeee check UNIT
                    
                    let alertDataDict = ["turn": turn.type]
                    
                    let deviceID = UserDefaults.standard.object(forKey: "VW.Consumer.deviceID") as? String
                    let alert = AlertParams.init(deviceId: deviceID ?? "", reportTime: Utility.getcurrentDate(date: Date()), reportGPS: getGPSData(), alertType: .sharpTurn, alertData: alertDataDict)
                    
                    let alertDict: [String: Any] = ["deviceId" : alert.deviceId, "reportTime" : alert.reportTime, "reportGPS" : alert.reportGPS, "alertType" : alert.alertType.rawValue, "alertData" : alert.alertData]
                    
                    print("Dict to be passed CORNERING=== \(alertDict)")
                    if Utility.isConnectedToNetwork() {
//                        var corDict = alertDict
//                        corDict["gravityDirection"] = gravityDir
//                        var tempArray : [[String : Any]] = Model.shared.tripsLogDict["INCIDENTS"] as? [[String : Any]] ?? [[String : Any]]()
//                        tempArray.append(corDict)
//                        Model.shared.tripsLogDict["INCIDENTS"] = tempArray
                        MQTTObject.sharedInstance.mqttAlert(dict: alertDict, topic: topics.alert)
                    } else {
                        var previousIncidentsData : [[String : Any]] = UserDefaults.standard.object(forKey: "VW.Consumer.Incidents") as? [[String : Any]] ?? [[String : Any]]()
                        previousIncidentsData.append(alertDict)
                        UserDefaults.standard.set(previousIncidentsData, forKey: "VW.Consumer.Incidents")
                    }
                }
                storeCSVFile(str: csvtext, in: "Incidents_\(startTime)", at: "Incidents")
                
            } else if corneringHalfSecTime != nil, Date().timeIntervalSince((corneringHalfSecTime)!) > 0.6 {
                corneringHalfSecTime = nil
            }
            newLine.append(" "  + (String(format:"%.5f", gravityDir.x)) + " " + (String(format:"%.5f", gravityDir.y)) + " " + (String(format:"%.5f", gravityDir.z)) + " " +  (String(format:"%.5f", gravityMagnitude)) + " " + (String(format:"%.5f", longitudeDir.x)) + " " + (String(format:"%.5f", longitudeDir.y)) + " " + (String(format:"%.5f", longitudeDir.z)) + " " + (String(format:"%.5f", longitudinalMagnitude)) + " " + (String(format:"%.5f", latitudeDir.x)) + " " + (String(format:"%.5f", latitudeDir.y)) + " " + (String(format:"%.5f", latitudeDir.z)) + " " + (String(format:"%.5f", latitudinalMagnitude)) + " " +  String(currentSpeed) +  " " + event + " " + motionstatus + "\n")
                
                csvtext.append(newLine)
        }
    }
    
    // MARK: - CoreMotionDelegate -- PLAN C
    //    func tracingDeviceMotion(deviceMotion: CMDeviceMotion) {
    //
    //        if csvtext.isEmpty {
    //            csvtext =  "seconds beforeFilter_x beforeFilter_y beforeFilter_z afterFilter_x afterFilter_y afterFilter_z gravity_x gravity_y gravity_z gravity_magnitude longitudinal_x longitudinal_y longitudinal_z longitudinal_magnitude latitudinal_x latitudinal_y latitudinal_z latitudinal_magnitude\n"
    //        }
    //        var newLine: String = ""
    //
    //        if logFilePreviousTime == nil {
    //            logFilePreviousTime = Date()
    //        }
    //        // TIME
    //        if logFilePreviousTime == nil {
    //            logFilePreviousTime = Date()
    //        }
    //
    //            // shreeeeee NEW LOGIC
    //
    //            let roll = deviceMotion.attitude.roll
    //            let pitch = deviceMotion.attitude.pitch
    //            var rotateVector : CMAcceleration = CMAcceleration(x: 0, y: 0, z: 0)
    //
    //            rotateVector.x = rotate(radAngle: pitch, xCoordinate: deviceMotion.userAcceleration.x, yCoordinate: deviceMotion.userAcceleration.y, sensorData: deviceMotion.userAcceleration, whichCoordinate: "x")
    //
    //            rotateVector.y = rotate(radAngle: roll, xCoordinate: deviceMotion.userAcceleration.x, yCoordinate: deviceMotion.userAcceleration.y, sensorData: deviceMotion.userAcceleration, whichCoordinate: "y")
    //
    //            let rotateVector_x_Sqr = (rotateVector.x) * (rotateVector.x)
    //            let rotateVector_y_Sqr = (rotateVector.y) * (rotateVector.y)
    //
    //            Model.shared.magnitude = sqrt(rotateVector_x_Sqr + rotateVector_y_Sqr)
    //
    //            if Model.shared.magnitude - Model.shared.magnitudePrevious > 0.1 {
    //                // DEVICE IS MOVING
    //                Model.shared.magnitude = 0.0
    //                Model.shared.magnitudePrevious = 0.0
    //                logFilePreviousTime = Date()
    //            } else {
    //                // DEVICE IS NOT IN MOTION
    //                Model.shared.avgBuffer = Model.shared.magnitude + Model.shared.avgBuffer
    //                Model.shared.avgCount += 1
    //            }
    //            Model.shared.magnitudePrevious = Model.shared.magnitude
    //
    //            if Model.shared.avgCount >= 25 { // 5 SEC
    //                logFilePreviousTime = Date()
    //
    //                print("rotateVector.x == \(radiansToDegres(radians: rotateVector.x))")
    //                print("rotateVector.y == \(radiansToDegres(radians: rotateVector.y))")
    //                print("Model.shared.magnitude == \(Model.shared.magnitude)")
    //
    //              //  Model.shared.roll_avg = Model.shared.rollSum / Model.shared.count
    //              //  Model.shared.pitch_avg = Model.shared.pitchSum / Model.shared.count
    //
    ////                if Model.shared.xyMagnitudeOffset - Model.shared.xyMagnitudeOffsetPrevious > 0.02 ||  Model.shared.xyMagnitudeOffsetPrevious == 0 {
    //
    //                if Model.shared.magnitude - Model.shared.magnitudePrevious > 0.1 {
    //                    // DEVICE IS MOVING
    //                    let yaw = Model.shared.avgBufferYaw / Double(Model.shared.avgCountYaw)
    //                    Model.shared.avgBufferYaw = yaw + Model.shared.avgBufferYaw
    //                    Model.shared.xyMagnitudeOffset = Model.shared.avgBufferYaw / Double(Model.shared.avgCountYaw)
    //
    //                    print("Model.shared.xyMagnitudeOffset == \(Model.shared.xyMagnitudeOffset)")
    
    //                    print("Model.shared.avgBufferYaw == \(Model.shared.avgBufferYaw)")
    //                    Model.shared.avgCountYaw += 1
    //                    if  Model.shared.avgCountYaw >= 25 {
    //                        let finalAngle = Model.shared.avgBufferYaw / Double(Model.shared.avgCountYaw)
    //                        rotateVector.z = finalAngle
    //                        print("rotateVector_final.x == \(radiansToDegres(radians: rotateVector.x))")
    //                        print("rotateVector_final.y == \(radiansToDegres(radians: rotateVector.y))")
    //                        print("rotateVector_final.z == \(radiansToDegres(radians: rotateVector.z))")
    //                    }
    //                } else {
    //                    // DEVICE NOT MOVING
    //                    Model.shared.avgCountYaw = 0
    //                    Model.shared.avgBufferYaw = 0.0
    //                }
    //                Model.shared.xyMagnitudeOffsetPrevious = Model.shared.xyMagnitudeOffset
    //                Model.shared.avgCount = 0
    //
    //            } else {
    //               // NO
    //            }
    //
    //
    //    }
    
    // MARK: - CoreMotionDelegate -- PLAN D -- YET TO IMPLEMENT
    //    func tracingDeviceMotion(deviceMotion: CMDeviceMotion) {
    //    }
    //
    func rotate (radAngle : Double , xCoordinate : Double , yCoordinate : Double , sensorData : CMAcceleration, whichCoordinate : String) -> Double{
        if whichCoordinate == "y" {
            return sensorData.x * sin(radAngle) + sensorData.y * cos(radAngle)
        } else {
            return sensorData.x * cos(radAngle) - sensorData.y * sin(radAngle)
        }
    }
    
    func dotProduct(userMotionData: CMAcceleration, latOrLongData: CMAcceleration) -> Double {
        return (userMotionData.x * latOrLongData.x) + (userMotionData.y * latOrLongData.y) + (userMotionData.z * latOrLongData.z)
    }
    
    func lowPassFilter(userData : CMAcceleration) -> CMAcceleration  {
        var output: CMAcceleration = CMAcceleration(x: 0.0, y: 0.0, z: 0.0)
        output.x = alpha * userData.x + (1 - alpha) * (Model.shared.lowPassFilterData.x)
        output.y = alpha * userData.y + (1 - alpha) * (Model.shared.lowPassFilterData.y)
        output.z = alpha * userData.z + (1 - alpha) * (Model.shared.lowPassFilterData.z)
        return output
    }
    
    
    // OLD LOGIC
    //    func tracingDeviceMotion(deviceMotion: CMDeviceMotion) {
    ////        print("GRAVITY ==== \(deviceMotion.gravity)")
    ////        print("ATTITUDE ==== \(deviceMotion.attitude)")
    //
    //
    //        var gravityDirection : String = ""
    //        var direction : String = ""
    //        create(directory: "Trips")
    //
    //        let xaxis = fabs(deviceMotion.gravity.x)
    //        let yaxis = fabs(deviceMotion.gravity.y)
    //        let zaxis = fabs(deviceMotion.gravity.z)
    //
    //        var firstValue : Double = 0.0
    //        var secondValue : Double = 0.0
    //
    //        var corFirstValue : Double = 0.0
    //        var corSecondValue : Double = 0.0
    //
    //        // ACCEL BRAKING
    //        let gravityDir = max(max(xaxis, yaxis), zaxis)
    //        if gravityDir == xaxis {
    //            gravityDirection = "xaxis"
    //            firstValue = deviceMotion.userAcceleration.y
    //            secondValue = deviceMotion.userAcceleration.z
    //
    //            corFirstValue = deviceMotion.rotationRate.y
    //            corSecondValue = deviceMotion.rotationRate.z
    ////            corFirstValue = deviceMotion.attitude.roll
    //            //            corSecondValue = deviceMotion.attitude.yaw
    //
    //        } else if gravityDir == yaxis {
    //            gravityDirection = "yaxis"
    //            firstValue = deviceMotion.userAcceleration.z
    //            secondValue = deviceMotion.userAcceleration.x
    //
    //            corFirstValue = deviceMotion.rotationRate.z
    //            corSecondValue = deviceMotion.rotationRate.x
    //
    ////            corFirstValue = deviceMotion.attitude.yaw
    ////            corSecondValue = deviceMotion.attitude.pitch
    //        } else {
    //            gravityDirection = "zaxis"
    //            firstValue = deviceMotion.userAcceleration.x
    //            secondValue = deviceMotion.userAcceleration.y
    //
    //            corFirstValue = deviceMotion.rotationRate.x
    //            corSecondValue = deviceMotion.rotationRate.y
    ////            corFirstValue = deviceMotion.attitude.roll
    ////            corSecondValue = deviceMotion.attitude.pitch
    //        }
    //
    ////        if gravityDir == xaxis {
    ////            corFirstValue = deviceMotion.rotationRate.y
    ////            corSecondValue = deviceMotion.rotationRate.z
    ////        } else if gravityDir == yaxis {
    ////            corFirstValue = deviceMotion.rotationRate.z
    ////            corSecondValue = deviceMotion.rotationRate.x
    ////        } else {
    ////            corFirstValue = deviceMotion.rotationRate.x
    ////            corSecondValue = deviceMotion.rotationRate.y
    ////        }
    //
    //       // notiCount = notiCount + 1
    //        // notificationSetUp(msg: "Testting kiplecar", identifierName: String(notiCount))
    //
    //        let accelerationThreshold: Double = 0.3
    //        let brakingThreshold: Double = -0.35
    //        if firstValue > accelerationThreshold || secondValue > accelerationThreshold {
    //            if previousSpeed >= 5, currentSpeed >= 5, Model.shared.userLoc?.signalStrength != GPSSignalStatus.low.rawValue {
    //                let accelValue = max(firstValue, secondValue)
    //                hardAccelCount =  hardAccelCount + 1
    //                hardAccelCountLbl.text = String(hardAccelCount)
    //                showWarning(warningType: 1)
    //
    //                // COUNT + 1 // Accel
    //                let speedBefAcc = TypeAndUnit.init(type: previousSpeed, unit: "km/h")
    //                let speedAftAcc = TypeAndUnit.init(type: currentSpeed, unit: "km/h")
    //                let accValue = TypeAndUnit.init(type: accelValue * 1000, unit: "m/s^2")
    //
    //                let alertDataDict = ["speedBeforeAcc": speedBefAcc.type, "speedAfterAcc": speedAftAcc.type, "accValue": accValue.type]
    //                let deviceID = UserDefaults.standard.object(forKey: "VW.Consumer.deviceID") as? String
    //                let alert = AlertParams.init(deviceId: deviceID ?? "", reportTime: Utility.getcurrentDate(date: Date()), reportGPS: getGPSData(), alertType: .suddenAcceleration, alertData: alertDataDict)
    //
    //                let alertDict: [String: Any] = ["deviceId" : alert.deviceId, "reportTime" : alert.reportTime, "reportGPS" : alert.reportGPS, "alertType" : alert.alertType.rawValue, "alertData" : alert.alertData]
    //
    //                print("Dict to be passed ACCEL=== \(alertDict)")
    //                if Utility.isConnectedToNetwork() {
    //                    var accelDict = alertDict
    //                    accelDict["gravityDirection"] = gravityDirection
    //                    var tempArray : [[String : Any]] = Model.shared.tripsLogDict["INCIDENTS"] as? [[String : Any]] ?? [[String : Any]]()
    //                    tempArray.append(accelDict)
    //                    Model.shared.tripsLogDict["INCIDENTS"] = tempArray
    //
    //                    mqttAlert(dict: alertDict, topic: topics.alert)
    //                } else {
    //                    var previousIncidentsData : [[String : Any]] = UserDefaults.standard.object(forKey: "VW.Consumer.Incidents") as? [[String : Any]] ?? [[String : Any]]()
    //                    previousIncidentsData.append(alertDict)
    //                    UserDefaults.standard.set(previousIncidentsData, forKey: "VW.Consumer.Incidents")
    //                }
    //            }
    //
    //        }
    //            else if firstValue < brakingThreshold || secondValue < brakingThreshold {
    //            let brakingValue = max(firstValue, secondValue)
    //            if previousSpeed >= 5, currentSpeed >= 5, Model.shared.userLoc?.signalStrength != GPSSignalStatus.low.rawValue {
    //                // COUNT + 1 // Braking
    //                hardBrakingCount = hardBrakingCount + 1
    //                hardBrakingCountLbl.text = String(hardBrakingCount)
    //                showWarning(warningType: 0)
    //
    //                let speedBefDec = TypeAndUnit.init(type: previousSpeed, unit: "km/h")
    //                let speedAftDec = TypeAndUnit.init(type: currentSpeed, unit: "km/h")
    //                let decValue = TypeAndUnit.init(type: brakingValue * 1000, unit: "m/s^2")
    //
    //                let alertDataDict = ["speedBeforeDec": speedBefDec.type, "speedAfterDec": speedAftDec.type, "decValue": decValue.type]
    //
    //                let deviceID = UserDefaults.standard.object(forKey: "VW.Consumer.deviceID") as? String
    //                let alert = AlertParams.init(deviceId: deviceID ?? "", reportTime: Utility.getcurrentDate(date: Date()), reportGPS: getGPSData(), alertType: .suddenDeceleration, alertData: alertDataDict)
    //
    //                let alertDict: [String: Any] = ["deviceId" : alert.deviceId, "reportTime" : alert.reportTime, "reportGPS" : alert.reportGPS, "alertType" : alert.alertType.rawValue, "alertData" : alert.alertData]
    //
    //                print("Dict to be passed DEC=== \(alertDict)")
    //                if Utility.isConnectedToNetwork(){
    //                    var brakDict = alertDict
    //                    brakDict["gravityDirection"] = gravityDirection
    //                    var tempArray : [[String : Any]] = Model.shared.tripsLogDict["INCIDENTS"] as? [[String : Any]] ?? [[String : Any]]()
    //                    tempArray.append(brakDict)
    //                    Model.shared.tripsLogDict["INCIDENTS"] = tempArray
    //                    mqttAlert(dict: alertDict, topic: topics.alert)
    //                } else {
    //                    var previousIncidentsData : [[String : Any]] = UserDefaults.standard.object(forKey: "VW.Consumer.Incidents") as? [[String : Any]] ?? [[String : Any]]()
    //                    previousIncidentsData.append(alertDict)
    //                    UserDefaults.standard.set(previousIncidentsData, forKey: "VW.Consumer.Incidents")
    //                }
    //            }
    //        } else {
    //            let corneringThreshold: Double = 15000
    //            if radiansToMilliDegres(radians: corFirstValue) > corneringThreshold, radiansToMilliDegres(radians: corSecondValue) > corneringThreshold {
    //
    //                if previousSpeed >= 5, currentSpeed >= 5, Model.shared.userLoc?.signalStrength != GPSSignalStatus.low.rawValue {
    //                    // COUNT + 1 // Cornering
    //                    let corneringValue = max(radiansToMilliDegres(radians: corFirstValue), radiansToMilliDegres(radians: corSecondValue))
    //
    //                    hardCorneringCount = hardCorneringCount + 1
    //                    hardCorneringCountLbl.text = String(hardCorneringCount)
    //                    showWarning(warningType: 2)
    //
    //                    let turn = TypeAndUnit.init(type: corneringValue, unit: "g/s^2")   // shreeee check UNIT
    //                    let alertDataDict = ["turn": turn.type]
    //
    //                    let deviceID = UserDefaults.standard.object(forKey: "VW.Consumer.deviceID") as? String
    //                    let alert = AlertParams.init(deviceId: deviceID ?? "", reportTime: Utility.getcurrentDate(date: Date()), reportGPS: getGPSData(), alertType: .sharpTurn, alertData: alertDataDict)
    //
    //                    let alertDict: [String: Any] = ["deviceId" : alert.deviceId, "reportTime" : alert.reportTime, "reportGPS" : alert.reportGPS, "alertType" : alert.alertType.rawValue, "alertData" : alert.alertData]
    //
    //                    print("Dict to be passed CORNERING=== \(alertDict)")
    //                    if Utility.isConnectedToNetwork() {
    //                        var corDict = alertDict
    //                        corDict["gravityDirection"] = gravityDirection
    //                        var tempArray : [[String : Any]] = Model.shared.tripsLogDict["INCIDENTS"] as? [[String : Any]] ?? [[String : Any]]()
    //                        tempArray.append(corDict)
    //                        Model.shared.tripsLogDict["INCIDENTS"] = tempArray
    //                        mqttAlert(dict: alertDict, topic: topics.alert)
    //                    } else {
    //                        var previousIncidentsData : [[String : Any]] = UserDefaults.standard.object(forKey: "VW.Consumer.Incidents") as? [[String : Any]] ?? [[String : Any]]()
    //                        previousIncidentsData.append(alertDict)
    //                        UserDefaults.standard.set(previousIncidentsData, forKey: "VW.Consumer.Incidents")
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    func tracingDeviceActivity(deviceActivity: CMMotionActivity) {
//        if deviceActivity.stationary || deviceActivity.walking {
//            // speedLbl.text = "stationary"
//            if deviceActivity.stationary {
//                print("stationary")
//                currentSpeed = 0.0
//                speedLbl.text = "0"
//                // speedLbl.text = "stationary"
//            } else {
//                print("walking")
//            }
//            if Model.shared.isOngoingTrip, !Model.shared.stopped {
//                Model.shared.stopped = true
//                stopTripTimer?.invalidate()
//                stopTripTimer = Timer.scheduledTimer(timeInterval: TimeInterval(stopTripDuration), target: self, selector: #selector(stopTripUpdate), userInfo: nil, repeats: false)
//            }
//        } else if deviceActivity.automotive {
//            stopTripTimer?.invalidate()
//            Model.shared.stopped = false
//            if !Model.shared.isOngoingTrip {
//                speedLbl.text = "Automotive"
//                startTimer()
//            }
//        }

        if deviceActivity.walking {
            motionstatus = "walking"
        } else if deviceActivity.running {
            motionstatus = "running"
        } else if deviceActivity.stationary {
            motionstatus = "stationary"
        } else if deviceActivity.automotive {
            motionstatus = "automotive"
        }
    }
    
    func stopTripUpdate() {
        stopTrip()
    }
    
    // MARK: - UIBUTTON ACTIONS
    
    @IBAction func menuBtnCall(_ sender: Any) {
        if revealViewController() != nil {
            revealViewController().revealToggle(animated: true)
        }
    }
    
    @IBAction func emergencyBtnCall(_ sender: Any) {
        // NAVIGATE TO EMERGENCY SCREEN
        if let emergencyVC = mainSB.instantiateViewController(withIdentifier: StoryBoardVC.emergency) as? EmergencyVC {
            emergencyVC.isFromDashBoard = true
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(emergencyVC, animated: true)
        }
    }
    
}



