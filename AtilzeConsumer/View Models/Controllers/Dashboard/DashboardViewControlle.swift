//
//  DashboardViewController.swift
//  AtilzeConsumer
//
//  Created by Sreejith on 24/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import Foundation
import MBCircularProgressBar
import SWRevealViewController
import Firebase

class DashboardViewController: UIViewController {
    
    enum FloatValue:CGFloat {
        case zero = 0, ten  = 10, twenty = 20, onePointThree = 1.3
    }
    
    @IBOutlet weak var tripView: UIView!
    @IBOutlet weak var viewMiddle: CustomShadeView!
    @IBOutlet weak var carStatusView: CustomShadeView!
    @IBOutlet weak var driverScore: UIView!
    @IBOutlet weak var activeIcon: UIView!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var lastDetectedLabel: UILabel!
    @IBOutlet var statusLabelCollection: [UILabel]!
    @IBOutlet var lastTripsButtonColletction: [UIButton]!
    @IBOutlet weak var todayDateLabel: UILabel!
    @IBOutlet weak var safetyScoreChart: MBCircularProgressBarView!
    @IBOutlet var otherChartViewCollection: [MBCircularProgressBarView]!
    @IBOutlet var averageLabelCollection: [UILabel]!
    @IBOutlet var incidentLblCollection: [UILabel]!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastTipLbl: UILabel!
    @IBOutlet weak var coupenView: UIView!
    
    @IBOutlet weak var vehicleStatusHeight: NSLayoutConstraint!
    @IBOutlet weak var vehicleStausSpacing: NSLayoutConstraint!
    
    @IBOutlet weak var locateMyCarHeight: NSLayoutConstraint!
    @IBOutlet weak var locateMyCarSpacing: NSLayoutConstraint!
    
    // TOTAL TRIPS
    @IBOutlet weak var totalDriverScore: MBCircularProgressBarView!
    @IBOutlet weak var totalTrips: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var totalAvgSpeed: UILabel!
    
    var las30DaysTrips = [TripModelView]()
    var currentTripData = [TripModelView]()
    var last7DaysTrips = [TripModelView]()
    var refreshControl: UIRefreshControl!
    var toDateTime : String = ""
    var fromDateTime : String = ""
    var viewSelect = ""
    
    var menuBtn: UIBarButtonItem?
    var drivingStatusView: UIView?
    var drivingStatusButton: UIButton?
    
    var last7DaysStartDate:String = ""
    var last7DaysEndDate:String = ""
    
    var last30DaysStartDate:String = ""
    var last30DaysEndDate:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ADD OBSERVER
        NotificationCenter.default.addObserver(self, selector: #selector(fetchDataFromFile), name: NSNotification.Name(rawValue: "refreshDB"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDrivingStatus), name: NSNotification.Name(rawValue: "updateDrivingStatus"), object: nil)
        // NAV BAR
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem?.image = UIImage(named: "emergency")
        
        setUpView()
        fetchDataFromFile()
        loadTotalTripsDetail()
}
    override func viewWillAppear(_ animated: Bool) {
//        let accountType = Utility.getLoginMode()
//        if accountType == "OBDless" {
//            menuBtn = self.navigationItem.leftBarButtonItem
//            self.navigationItem.leftBarButtonItem = nil
//        } else {
//            if self.navigationItem.leftBarButtonItem == nil { self.navigationItem.leftBarButtonItem = menuBtn }
        //        }
        
        if Model.shared.isTempStatusResolved {
            self.statusLabelCollection[1].text = "Normal"
            self.statusLabelCollection[1].textColor = UIColor(hexString: "0073A4")
        }
        if Model.shared.isBatteryStatusResolved {
            self.statusLabelCollection[0].text = "Normal"
            self.statusLabelCollection[0].textColor = UIColor(hexString: "0073A4")
        }
    
        if Utility.getLoginMode() == "OBDless" {
            vehicleStatusHeight.constant = 0
            vehicleStausSpacing.constant = 0
            locateMyCarHeight.constant = 0
            locateMyCarSpacing.constant = 0
            carStatusView.alpha = 0.0
            
            if Utility.isConnectedToNetwork() {
                self.getCarStatus()
            }
            
        } else {
            vehicleStatusHeight.constant = 110
            vehicleStausSpacing.constant = 10
            locateMyCarHeight.constant = 37
            locateMyCarSpacing.constant = 20
            carStatusView.alpha = 1.0
        }
        //MENU
        if revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        }
        updateDrivingStatus()
    }
    
    func updateDrivingStatus() {
        if drivingStatusView == nil {
            drivingStatusView = UIView()
            drivingStatusView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20)
            drivingStatusView?.backgroundColor = GREEN
            //            drivingStatusView?.backgroundColor = .clear
            drivingStatusButton = UIButton(frame: CGRect(x: 25, y: 0, width: (drivingStatusView?.frame.width)! - 50, height: 20))
            drivingStatusButton?.addTarget(self, action: #selector(toTripTrackScreen), for: .touchUpInside)
            drivingStatusButton?.titleLabel?.lineBreakMode = .byWordWrapping
            drivingStatusButton?.titleLabel?.textAlignment = .center
            drivingStatusButton?.backgroundColor = .clear
            drivingStatusButton?.setTitle("Currently Driving,Tap to see live tracking", for: .normal)
            drivingStatusButton?.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 13)
            drivingStatusButton?.setTitleColor(.white, for: .normal)
            drivingStatusView?.addSubview(drivingStatusButton!)
            drivingStatusView?.alpha = 0.0
            drivingStatusButton?.alpha = 0.0
            self.view.addSubview(drivingStatusView ?? UIView())
            self.view.addSubview(drivingStatusButton ?? UIView())
        }
        drivingStatusView?.alpha = 0.0
        drivingStatusButton?.alpha = 0.0
        if Model.shared.isOngoingTrip {
            drivingStatusView?.alpha = 1.0
            drivingStatusButton?.alpha = 1.0
        }
    }
    
    func toTripTrackScreen() {
        tabBarController?.selectedIndex = 2
    }
    
    override func viewWillLayoutSubviews() {
//        if drivingStatusView == nil {
//            drivingStatusView = UIView()
//            drivingStatusView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
//            drivingStatusView?.backgroundColor = .green
//            drivingStatusView?.alpha = 0.0
//            self.view.addSubview(drivingStatusView ?? UIView())
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    func navigateTocarStaus() {
        tabBarController?.selectedIndex = 2
    }
    
    func navigateToTripSummary() {
        if currentTripData.count > 0 {
            for (index, button) in lastTripsButtonColletction.enumerated() {
                
                for view in button.subviews {
                    if view.tag == 100, view.alpha == 1 {
                        print(" last trip")
                        guard let tripSummaryVC  = mainSB.instantiateViewController(withIdentifier: "CurrentTripDetailsVC") as? TripSummaryVC else {
                            return
                        }
                        let backItem = UIBarButtonItem()
                        backItem.title = ""
                        self.navigationItem.backBarButtonItem = backItem
                        // PASS SELECTED TRIP OBJECT TO DETAIL SCREEN
                        tripSummaryVC.tripDetails = currentTripData[0]
                        navigationController?.pushViewController(tripSummaryVC, animated: true)
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var contentView: UIView!
    override func viewDidAppear(_ animated: Bool) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLayoutSubviews() {
    }
    // MARK: - SETUP
    func setUpView() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(navigateTocarStaus))
        carStatusView.addGestureRecognizer(tap)
        
        let tapTrip: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(navigateToTripSummary))
        tripView.addGestureRecognizer(tapTrip)
        
        // TRIP BUTTONS
        for (index, button) in lastTripsButtonColletction.enumerated() {
            let buttonView = UIView()
            buttonView.backgroundColor = UIColor.init(hexString: "00A2ED")
            buttonView.tag = index + 100
            if index == 0 {
                buttonView.alpha = 1
            } else {
                buttonView.alpha = 0
            }
            buttonView.frame = CGRect(x: 5, y: button.frame.height - 4, width: (UIScreen.main.bounds.width / 3) - 10, height: 4)
            button.addSubview(buttonView)
        }
        // RESET LABELS
        statusLabelCollection[0].text = ""
        statusLabelCollection[1].text = ""
        statusLabelCollection[2].text = ""
        lastDetectedLabel.text = ""
        // REFRESH CONTROL
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.tintColor = UIColor.init(hexString: "00A3EA")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        scrollView.addSubview(refreshControl)
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
    }
    
    func refresh() {
        // PULL TO REFRESH
        getStartAndEndDates()
        fetchLast30DaysTripData()
        getCarStatus()
        getAlerts()
        loadTotalTripsDetail()
    }
    
    func fetchDataFromFile() {
        if Utility.isConnectedToNetwork() {
            refresh()
        } else {
            getStartAndEndDates()
            /* STOP LOADER */
            self.refreshControl.endRefreshing()
            self.currentTripData.removeAll()
            // FETCH TRIP DATA FROM FILE
            let storedData = Utility.readFromFile(fileName: FileNames.dashBoard.rawValue)
            // CHECK TRIPS FOR THE SELECTED DATE
            if let status = storedData["status"] as? String, status == "OK", let tripsArray = storedData[fromDateTime] as? [[String : Any]] {
                // MAP TRIP DATA AND RELOAD TABLEVIEW
                DispatchQueue.main.async {
                    self.loadData(rawData: tripsArray)
                }
            } else {
                // STATUS == ERROR OR NO DATA - CALL API
                DispatchQueue.main.async {
                    self.fetchLast30DaysTripData()
                }
            }
            // FETCH CAR STATUS FROM FILE
            let storedData2 = Utility.readFromFile(fileName: FileNames.carStatus.rawValue)
            if let status = storedData2["status"] as? String, status == "OK", let carStatusDict = storedData2["data"] as? [String : Any] {
                DispatchQueue.main.async {
                    self.loadCarStatus(rawData: carStatusDict)
                }
            } else {
                // STATUS == ERROR OR NO DATA - CALL API
                DispatchQueue.main.async {
                    self.getCarStatus()
                }
            }
            // FETCH ALERTS FROM FILE
            let storedData3 = Utility.readFromFile(fileName: FileNames.alerts.rawValue)
            if let status = storedData3["status"] as? String, status == "OK", let alertsDict = storedData3["data"] as? [String : Any], let alertsArray = alertsDict["alerts"] as? [[String : Any]] {
                self.updateTempStatus(alertsArray: alertsArray, tempStatus : Model.shared.isTempStatusResolved)
            } else {
                // STATUS == ERROR OR NO DATA - CALL API
                getAlerts()
            }
        }
    }
    
    func getAlerts() {
        let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getAlerts + "?"
        networkManager.getMethod(url, params: nil, success: { (response) in
            /* STOP LOADER */
            self.refreshControl.endRefreshing()
            if let response = response as? [String : Any], let responseObj = response["data"] as? [String : Any], let alertsArray = responseObj["alerts"] as? [[String : Any]], let tempStatus = responseObj["resolved"] as? Bool {
                DispatchQueue.global(qos: .background).async {
                    // UPDATE TO DB
                    Utility.storeStaticDataToFile(fileName: FileNames.alerts.rawValue, rawData: responseObj)
                }
                Model.shared.isTempStatusResolved = tempStatus
                self.updateTempStatus(alertsArray: alertsArray, tempStatus : tempStatus)
            } else if let response = response as? [String : Any], let responseObj = response["error"] as? [String : Any], let error =  responseObj["error"] as? String {
                if error == ErrorsFromAPI.tokenError.rawValue {
                    // CALL SUBSCRIPTION API
                    Utility.checkSubscription(viewController: self)
                } else {
                    Utility.storeStaticDataToFile(fileName: ErrorMsgs.serverError, rawData: responseObj)
                }
            } else {
                self.statusLabelCollection[1].text = "Normal"
                self.statusLabelCollection[1].textColor = UIColor(hexString: "0073A4")
            }
        }) { (error) in
            print("error *** \(error)")
            // FETCH ALERTS FROM FILE
            let storedData = Utility.readFromFile(fileName: FileNames.alerts.rawValue)
            guard let status = storedData["status"] as? String, status == "OK", let alertsDict = storedData["data"] as? [String : Any], let alertsArray = alertsDict["alerts"] as? [[String : Any]] else {
                self.statusLabelCollection[1].text = "Normal"
                self.statusLabelCollection[1].textColor = UIColor(hexString: "0073A4")
                return
            }
            self.updateTempStatus(alertsArray: alertsArray, tempStatus : Model.shared.isTempStatusResolved)
        }
    }
    
    func updateTempStatus(alertsArray : [[String : Any]], tempStatus : Bool) {
        let alerts = alertsArray.map {Alert(data: $0)}
        var overHeatAlerts = alerts.filter({$0.type == "high_temperature"})
        guard overHeatAlerts.count > 0 else {
            //DEFAULT VALUES
            self.statusLabelCollection[1].text = "Normal"
            self.statusLabelCollection[1].textColor = UIColor(hexString: "0073A4")
            return
        }
        if tempStatus {
            self.statusLabelCollection[1].text = "Normal"
            self.statusLabelCollection[1].textColor = UIColor(hexString: "0073A4")
        } else {
        let tempStatusDate = overHeatAlerts[0].reportTime
        let last7DaysCal: Date! = Calendar.current.date(byAdding: .day, value: -6, to: Date())
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: last7DaysCal)
        components.timeZone = TimeZone(identifier: Model.shared.timeZone)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let last7DaysFinal : Date! = Calendar.current.date(from: components)
        let formatter_timezone = DateFormatter()
        formatter_timezone.dateFormat = "ZZZ"
        let myDate = Date()
        formatter_timezone.timeZone = TimeZone(identifier: Model.shared.timeZone)
        let timeZoneString  = formatter_timezone.string(from: myDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone(identifier: Model.shared.timeZone)
        let formattedDate:Date = formatter.date(from: "\(tempStatusDate) \(timeZoneString)") ?? Date()
        
        if last7DaysFinal > formattedDate {
            self.statusLabelCollection[1].text = "Normal"
            self.statusLabelCollection[1].textColor = UIColor(hexString: "0073A4")
        } else {
            self.statusLabelCollection[1].text = "Warning!"
            self.statusLabelCollection[1].textColor = UIColor(hexString: "D0021B")
        }
    }
}
    
    // MARK: - CAR STATUS
    func getCarStatus() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getDeviceStatus + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                guard let result = response as? [String : Any], let responseObj = result["data"] as? [String : Any] else {
                    if let response = response as? [String : Any], let responseObj = response["error"] as? [String : Any], let error =  responseObj["error"] as? String {
                        if error == ErrorsFromAPI.tokenError.rawValue {
                            // CALL SUBSCRIPTION API
                            Utility.checkSubscription(viewController: self)
                        } else {
                            Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
                        }
                    }
                    return
                }
                DispatchQueue.global(qos: .background).async {
                    Utility.storeStaticDataToFile(fileName: FileNames.carStatus.rawValue, rawData: responseObj)
                }
                Model.shared.isBatteryStatusResolved = false
                self.loadCarStatus(rawData: responseObj)
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            // NO INTERNET CONNECTION
            // FETCH CAR STATUS FROM FILE
            let storedData = Utility.readFromFile(fileName: FileNames.trips.rawValue)
            guard let status = storedData["status"] as? String, status == "OK", let carStatusDict = storedData["data"] as? [String : Any] else {
                loadCarStatus(rawData: [:])
                return
            }
            loadCarStatus(rawData: carStatusDict)
        }
    }
    
    func loadCarStatus(rawData : [String : Any]) {
        if let engineDetails = rawData["engine_status"] as? [String : Any] {
            if Model.shared.isBatteryStatusResolved {
                self.statusLabelCollection[0].textColor = UIColor(hexString: "0073A4")
                self.statusLabelCollection[0].text = "Normal"
            } else {
                var _battery_volt_status = engineDetails["battery_volt_status"] as? String
                if _battery_volt_status?.lowercased() == "warning" {
                    self.statusLabelCollection[0].textColor = UIColor(hexString: "D0021B")
                    _battery_volt_status = _battery_volt_status! + "!"
                } else {
                    self.statusLabelCollection[0].textColor = UIColor(hexString: "0073A4")
                }
                self.statusLabelCollection[0].text = _battery_volt_status
            }
            
            var engine_coolant_temperature_status = engineDetails["engine_coolant_temperature_status"] as? String
            if engine_coolant_temperature_status?.lowercased() == "warning" {
                self.statusLabelCollection[2].textColor = UIColor(hexString: "D0021B")
                engine_coolant_temperature_status = engine_coolant_temperature_status! + "!"
            } else {
                self.statusLabelCollection[2].textColor = UIColor(hexString: "0073A4")
            }
            self.statusLabelCollection[2].text = engine_coolant_temperature_status
        }
        if let deviceStatus = rawData["device_status"] as? [String : Any], let reportTime = deviceStatus["report_time"] as? String {
            self.lastDetectedLabel.text = Utility.getFormattedDate(date: reportTime)
            let deviceState = deviceStatus["status"] as? String
            self.activeLabel.text = deviceState?.capitalized
            self.activeIcon.backgroundColor = deviceState?.lowercased() == "online" ? UIColor.init(hexString: "#86CE3B") : .red
        }
    }
    
    // MARK: - TRIP SUMMERY
    func getStartAndEndDates() {
        let from30DaysCal: Date! = Calendar.current.date(byAdding: .day, value: -29, to: Date())
        let today = Date()
        toDateTime = Utility.getTripDate(date: today, isStartDate: false)
        fromDateTime = Utility.getTripDate(date: from30DaysCal, isStartDate: true)
    }
    
    func fetchLast30DaysTripData() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getTrips + "?" + "from_datetime=\(fromDateTime)&to_datetime=\(toDateTime)"
            networkManager.getMethod(url, params: nil, success: { (response) in
                /* STOP LOADER */
                self.refreshControl.endRefreshing()
                if let responseObj = response as? [String : Any], let tripsArray = responseObj["data"] as? [[String : Any]] {
                    guard tripsArray.count > 0 else {
                        // NO TRIPS AVAILABLE FOR THE SELECTED MONTH
                        DispatchQueue.global(qos: .background).async {
                            // UPDATE AN EMPTY ARRAY TO DB
                            Utility.storeToFile(fileName: FileNames.dashBoard.rawValue, updateStatus: false, trips: tripsArray, date : self.fromDateTime)
                        }
                        DispatchQueue.main.async {
                            self.setCircularProgressBar(tripData: self.currentTripData)
                        }
                        return
                    }
                    // STORE 30 DAYS TRIPS
                    DispatchQueue.global(qos: .background).async {
                        // UPDATE TRIPS ARRAY TO DB
                        Utility.storeToFile(fileName: FileNames.dashBoard.rawValue, updateStatus: true, trips: tripsArray, date : self.fromDateTime)
                    }
                    DispatchQueue.main.async {
                        self.loadData(rawData: tripsArray)
                    }
                } else  if let response = response as? [String : Any], let responseObj = response["error"] as? [String : Any], let error =  responseObj["error"] as? String {
                    if error == ErrorsFromAPI.tokenError.rawValue {
                        // CALL SUBSCRIPTION API
                        Utility.checkSubscription(viewController: self)
                    } else {
                        Utility.storeStaticDataToFile(fileName: ErrorMsgs.serverError, rawData: responseObj)
                    }
                } else {}
            }) { (error) in
                self.refreshControl.endRefreshing()
                Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
            }
        } else {
            // NO INTERNET CONNECTION
            /* STOP LOADER */
            self.refreshControl.endRefreshing()
            self.currentTripData.removeAll()
            // FETCH TRIP DATA FROM FILE
            let storedData = Utility.readFromFile(fileName: FileNames.dashBoard.rawValue)
            // CHECK TRIPS FOR THE SELECTED MONTH
            guard let status = storedData["status"] as? String, status == "OK", let tripsArray = storedData[fromDateTime] as? [[String : Any]] else {
                self.setCircularProgressBar(tripData: self.currentTripData)
                return
            }
            // MAP TRIP DATA AND RELOAD TABLEVIEW
            loadData(rawData: tripsArray)
        }
    }
    
    func loadData(rawData : [[String: Any]]) {
        let last7DaysCal: Date! = Calendar.current.date(byAdding: .day, value: -6, to: Date())
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: last7DaysCal)
        components.timeZone = TimeZone(identifier: Model.shared.timeZone)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let last7DaysFinal : Date! = Calendar.current.date(from: components)
        
        var components2 = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        components2.timeZone = TimeZone(identifier: Model.shared.timeZone)
        components2.hour = 23
        components2.minute = 59
        components2.second = 59
        let today : Date! = Calendar.current.date(from: components2)
        
        self.las30DaysTrips = rawData.map {TripModelView(trip: Trip(data: $0))}

        last7DaysStartDate =  Utility.getHomeScreenDate(date: last7DaysFinal)
        last7DaysEndDate = Utility.getHomeScreenDate(date: Date())
        
        last30DaysEndDate = Utility.getHomeScreenDate(date: Date())
        let from30DaysCal: Date! = Calendar.current.date(byAdding: .day, value: -29, to: Date())
        last30DaysStartDate = Utility.getHomeScreenDate(date: from30DaysCal)

        self.last7DaysTrips = self.las30DaysTrips.filter({$0.startDateForCompare >= last7DaysFinal && today >= $0.startDateForCompare})
        for (_, button) in lastTripsButtonColletction.enumerated() where self.las30DaysTrips.count > 0 {
            for view in button.subviews {
                if view.tag == 100, view.alpha == 1 {
                    print(" last trip")
                    self.currentTripData = [self.las30DaysTrips[0]]
                    lastTipLbl.text = "Last Trip: \(currentTripData[0].startDate)"
                    self.setCircularProgressBar(tripData: self.currentTripData)
                } else if view.tag == 101, view.alpha == 1 {
                    print(" last 7 days")
                    lastTipLbl.text = last7DaysStartDate + " - " + last7DaysEndDate
                    self.setCircularProgressBar(tripData: self.last7DaysTrips)
                } else if view.tag == 102, view.alpha == 1 {
                    print(" last 30 days")
                    lastTipLbl.text = last30DaysStartDate + " - " + last30DaysEndDate
                    self.setCircularProgressBar(tripData: self.las30DaysTrips)
                }
            }
        }
    }
    
    func loadTotalTripsDetail() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getTripSummary + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                /* STOP LOADER */
                if let responseObj = response as? [String : Any], let totTrips = responseObj["data"] as? [String : Any] {
                    if let totDistance = totTrips["total_distance"] as? Double {
                        let totDistanceInKm: Double = Double(totDistance/1000)
                        self.totalDistance.text = totDistanceInKm > 0 ? String(format:"%.1f", totDistanceInKm) + " KM" : "0"
                    }
                    if let totTrips = totTrips["total_trip"] as? Int {
                        self.totalTrips.text = String(totTrips)
                    }
                    if let driverScore = totTrips["driver_score"] as? Double {
                        self.totalDriverScore.value = CGFloat(driverScore)
                    }
                    if let maxSpeed = totTrips["max_speed"] as? Double {
                        self.totalAvgSpeed.text = String(Int(maxSpeed)) + " kM/H"
                    }
                }
            }) { (_) in
                self.refreshControl.endRefreshing()
                Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
            }
        }
    }
    
    // MARK: - PROGRESS BAR
    func setCircularProgressBar(tripData: [TripModelView]) {
        //   revealViewController().rearViewRevealWidth = (2 * UIScreen.main.bounds.width) / 3
        guard tripData.count > 0 else {
            lastTipLbl.text = "No Trips"
            safetyScoreChart.value = 0
            incidentLblCollection[0].text = "0"
            incidentLblCollection[1].text = "0"
            incidentLblCollection[2].text = "0"
            incidentLblCollection[3].text = "0"
            
            averageLabelCollection[0].text = "0.0"
            averageLabelCollection[1].text = "0.0"
            averageLabelCollection[2].text = "0.0"
            return
        }
        
        /// Safety Score
        let safetyScoreArray = tripData.flatMap({ $0.safetyScore })
        if safetyScoreArray.count > 0 {
            let average = Double(safetyScoreArray.reduce(0, +)) / Double(safetyScoreArray.count)
            safetyScoreChart.value = CGFloat(average)
        } else {
            safetyScoreChart.value = 0
        }
        // Cornering
        let corneringCountDoubleArray = tripData.flatMap({ $0.otherScores[0] })
        let corneringTotal = corneringCountDoubleArray.reduce(0, +)
        incidentLblCollection[3].text = corneringTotal > 0 ? String(corneringTotal) : "0"
        incidentLblCollection[3].textColor = corneringTotal > 0 ? RED : .black
        
        //  Hard Braking
        let hardBrakingDoubleArray = tripData.flatMap({ $0.otherScores[1] })
        let hardBreakTotal = hardBrakingDoubleArray.reduce(0, +)
        incidentLblCollection[1].text = hardBreakTotal > 0 ? String(hardBreakTotal) : "0"
        incidentLblCollection[1].textColor = hardBreakTotal > 0 ?  RED : .black
        // Speeding Count
        let speedingCountDoubleArray = tripData.flatMap({ $0.otherScores[2] })
        let speedingTotal = speedingCountDoubleArray.reduce(0, +)
        incidentLblCollection[0].text = speedingTotal > 0 ? String(speedingTotal) : "0"
        incidentLblCollection[0].textColor = speedingTotal > 0 ? RED : .black
        
        // Hard Accel
        let harshAccDoubleArray = tripData.flatMap({ $0.otherScores[3] })
        let harshAccTotal = harshAccDoubleArray.reduce(0, +)
        incidentLblCollection[2].text = harshAccTotal > 0 ? String(harshAccTotal) : "0"
        incidentLblCollection[2].textColor = harshAccTotal > 0 ?RED : .black
        
        // Total Distance
        var totalDistance = 0.0
        let totalDistanceArray = tripData.flatMap({ $0.tripObj.distance/1000 })
        totalDistance = Double(totalDistanceArray.reduce(0, +))
        averageLabelCollection[0].text = String(format:"%.1f", totalDistance) + " KM"
        
        var totalDuration = 0.0
        let totalDurationArray = tripData.flatMap({ $0.tripObj.duration})
        totalDuration = Double(totalDurationArray.reduce(0, +))
        
        // hh:mm FORMAT
        if totalDuration > 3600 {
            let hours = Int(totalDuration / 3600)
            let mins =  Int((totalDuration.truncatingRemainder(dividingBy: 3600)) / 60)
            let formattedHours = hours > 9 ? "\(hours)" : "0\(hours)"
            if mins > 0 {
                let formattedMins = mins > 9 ? "\(mins)" : "0\(mins)"
                averageLabelCollection[1].text = "\(formattedHours) hr \(formattedMins) MINS"
            } else {
                averageLabelCollection[1].text = "\(formattedHours) HR"
            }
        }
        else  if totalDuration > 60 {
            let mins =  Int((totalDuration.truncatingRemainder(dividingBy: 3600)) / 60)
            let formattedMins = mins > 9 ? "\(mins)" : "0\(mins)"
            averageLabelCollection[1].text = "\(formattedMins) MINS"
        } else {
            averageLabelCollection[1].text = "1 MIN"
        }
        
        // Total Fuel Efficiency
        let totalFuelEfficiencyArray = tripData.flatMap({$0.tripObj.maxSpeed})
        let maxSpeed = totalFuelEfficiencyArray.max()
        averageLabelCollection[2].text = String(Int(maxSpeed!)) + " KM/H"
        
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
    
    @IBAction func locateMyCarPressed(_ sender: Any) {
        if let locateMyCarVC = mainSB.instantiateViewController(withIdentifier: "LocateMyCarVC") as? LocateMyCarVC {
            locateMyCarVC.lastDetectedDate = lastDetectedLabel.text!
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(locateMyCarVC, animated: true)
        }
    }
    
    @IBAction func seeTripHistoryPressed(_ sender: Any) {
        Analytics.logEvent("see_trip_history", parameters:nil)
        // GO TO TripHistoryVC
        self.tabBarController?.selectedIndex = 1
//        if let tripsVC = mainSB.instantiateViewController(withIdentifier: StoryBoardVC.trip) as? TripHistoryVC {
//            tripsVC.isFromDashBoard = true
//            let backItem = UIBarButtonItem()
//            backItem.title = ""
//            self.navigationItem.backBarButtonItem = backItem
//            navigationController?.pushViewController(tripsVC, animated: true)
//        }
    }
    
    @IBAction func lastTripBtnCall(_ sender: Any) {
        
        if currentTripData.count > 0 {
            lastTipLbl.text = "Last Trip: \(currentTripData[0].startDate)"
            /// Set Progressbar Data
            self.setCircularProgressBar(tripData: currentTripData)
        }
        
        for (index, button) in lastTripsButtonColletction.enumerated() {
            
            if index == 0 {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "00A2ED"), for: .normal)
            } else {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "A7ACAE"), for: .normal)
            }
            for view in button.subviews {
                if view.tag == 100 {
                    view.alpha = 1
                } else if view.tag == 101 || view.tag == 102 {
                    view.alpha = 0
                }
            }
        }
    }
    @IBAction func last7daysBtnCall(_ sender: Any) {
         lastTipLbl.text = last7DaysStartDate + " - " + last7DaysEndDate
        /// Set Progressbar Data
        self.setCircularProgressBar(tripData: last7DaysTrips)
        
        for (index, button) in lastTripsButtonColletction.enumerated() {
            if index == 1 {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "00A2ED"), for: .normal)
            } else {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "A7ACAE"), for: .normal)
            }
            for view in button.subviews {
                if view.tag == 101 {
                    view.alpha = 1
                } else if view.tag == 100 || view.tag == 102 {
                    view.alpha = 0
                }
            }
        }
    }
    @IBAction func last30daysBtnCall(_ sender: Any) {
        /// Set Progressbar Data
        lastTipLbl.text = last30DaysStartDate + " - " + last30DaysEndDate
        self.setCircularProgressBar(tripData: las30DaysTrips)
        
        for (index, button) in lastTripsButtonColletction.enumerated() {
            if index == 2 {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "00A2ED"), for: .normal)
            } else {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "A7ACAE"), for: .normal)
            }
            for view in button.subviews {
                if view.tag == 102 {
                    view.alpha = 1
                } else if view.tag == 101 || view.tag == 100 {
                    view.alpha = 0
                }
            }
        }
    }
}

extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - COLLECTION VIEW
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let speedLimit = cell.viewWithTag(4) as? UILabel
        speedLimit?.attributedText = Utility.attributedText(completeText: "30KM/H", primaryText: "30", secondaryText: "KM/H")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 165, height: 160)
    }
}

class DashboardAlertsCell: UICollectionViewCell {
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var speedLimitLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
}
