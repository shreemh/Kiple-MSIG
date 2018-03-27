//
//  CarStausVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 31/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import DZNEmptyDataSet
import CoreLocation

class CarStausVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, LocationServiceDelegate {
    //
    //    @IBOutlet var statusLabelCollection2: [UILabel]!
    //    @IBOutlet weak var lastDetectedLabel: UILabel!
    //    @IBOutlet weak var activeLabel: UILabel!
    //    @IBOutlet weak var activeIcon: UIView!
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var retryCount: Int = 0
    var enableEmptyData : Bool = false
    var alerts: [AlertsViewModel] = [AlertsViewModel]()
    var last7DaysAlets: [AlertsViewModel] = [AlertsViewModel]()
    var selectedItem = Int()
    var menuBtn: UIBarButtonItem?
    
    var carStatusRawData: [String : Any]?
    var flag: Bool = false
    var alertsRawData: [[String : Any]] = [[String : Any]]()
  //  var isTempStatusResolved: Bool = false
    var alertsViewArray : [UIView] = [UIView]()
    var overlayView : UIVisualEffectView = UIVisualEffectView()
    var lastDetected : String = String()
    var batteryStatus : String = ""
    var tempStatus: String = ""
    var deviceStatus: String = ""
    var fieldToBeUpdated: String = ""
    
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    lazy var geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.image = UIImage(named: "emergency")
        setUpView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        //        let accountType = Utility.getLoginMode()
        //        if accountType == "OBDless" {
        //            menuBtn = self.navigationItem.leftBarButtonItem
        //            self.navigationItem.leftBarButtonItem = nil
        //        } else {
        //            if self.navigationItem.leftBarButtonItem == nil { self.navigationItem.leftBarButtonItem = menuBtn }
        //        }
        // MENU
        if revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        }
    }
    // MARK: - SETUP
    func setUpView() {
        // TABLE VIEW
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        // fetchDataFromFile()
        if Utility.isConnectedToNetwork() {
            self.refresh() } else {
            fetchDataFromFile()
        }
        
        // ADD OBSERVER
        NotificationCenter.default.addObserver(self, selector: #selector(fetchDataFromFile), name: NSNotification.Name(rawValue: "refreshAlerts"), object: nil)
        // REFRESH CONTROL
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.tintColor = UIColor.init(hexString: "00A3EA")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        var alertsDictArray : [[String : String]] = [carStatusDict, batteryDict, tempDict, carStatusWarningDict, batteryWaringDict, tempWaringDict]
        var height : CGFloat = 400.0
        var warningView : UIView = UIView()
        for index in 0...alertsDictArray.count - 1 {
            if index == 0 || index == 3 {
                height = 460
                warningView = Bundle.main.loadNibNamed("CarStatusAlertView2", owner: self, options: nil)?[0] as! UIView
                // CAR STATUS NORMAL/ WARNING
                let locateMyCarBtn = warningView.viewWithTag(7) as? UIButton
                locateMyCarBtn?.addTarget(self, action: #selector(locateMyCarBtnCall), for: .touchUpInside)
                
            } else if index == 4 || index == 5 {
                //  BATTERY/TEMP WARING ----  PROBLEM HAS BEEN SOLVED AND CANCEL BUTTONS
                height = 550.0
                warningView = Bundle.main.loadNibNamed("CarStatusAlertsView3", owner: self, options: nil)?[0] as! UIView
                let problemResolvedBtn = warningView.viewWithTag(7) as? UIButton
                problemResolvedBtn?.addTarget(self, action: #selector(probResolvedBtnCall), for: .touchUpInside)
                let cancelBtn = warningView.viewWithTag(8) as? UIButton
                cancelBtn?.addTarget(self, action: #selector(cancelBtnCall), for: .touchUpInside)
            }
            else {
                // BATTERY/TEMP NORMAL
                height = 350.0
                warningView = Bundle.main.loadNibNamed("CarStatusAlertView", owner: self, options: nil)?[0] as! UIView
            }
            warningView.frame = CGRect(x: 30, y: 10, width: UIScreen.main.bounds.width - 60, height: height)
            warningView.center = self.view.center
            let blurEffect = UIBlurEffect(style: .dark)
            overlayView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            overlayView.frame = self.view.bounds
            overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.addSubview(overlayView)
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
            overlayView.addGestureRecognizer(tap)
            
            overlayView.alpha = 0.0
            warningView.backgroundColor = .white
            warningView.alpha = 0.0
            let lastDetected = warningView.viewWithTag(10) as? UILabel
            let icon = warningView.viewWithTag(2) as? UIImageView
            let warningLbl = warningView.viewWithTag(3) as? UILabel
            let mainWarining = warningView.viewWithTag(4) as? UILabel
            let warning = warningView.viewWithTag(5) as? UILabel
            let dismissBtn = warningView.viewWithTag(6) as? UIButton
            dismissBtn?.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
            lastDetected?.text = "Shree"
            icon?.image = UIImage(named: (alertsDictArray[index]["icon"])!)
            warningLbl?.text = alertsDictArray[index]["warningLbl"]
            mainWarining?.text = alertsDictArray[index]["mainWarning"]
            warning?.text = alertsDictArray[index]["warning"]
            
            alertsViewArray.append(warningView)
            //  UIApplication.shared.keyWindow?.addSubview(overlayView)
            self.view.addSubview(warningView)
        }
        getCarLocation()
    }
    
    func getCarLocation() {
        let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getCurrentLocationOfCar + "?"
        networkManager.getMethod(url, params: nil, success: {(response) in
           // self.stopAnimating()
            print("Response:\(response ?? "")")
            self.stopAnimating()
            if let locationAddress = response as? [String:Any], let responseObj = locationAddress["data"] as? [String:Any] {
                let lat = responseObj["latitude"] as? Double
                let longitude = responseObj["longitude"] as? Double
                self.longitude = longitude ?? 0.0
                self.latitude = lat ?? 0.0
                
                // Geocode Location
                let addressLbl = self.alertsViewArray[0].viewWithTag(5) as? UILabel
                
                let addressLbl2 = self.alertsViewArray[3].viewWithTag(5) as? UILabel
                
                let locations = CLLocation(latitude:CLLocationDegrees(self.latitude), longitude: CLLocationDegrees(self.longitude))
                self.geocoder.reverseGeocodeLocation(locations) { (placemarks, error) in
                    // Process Response
                    addressLbl?.text = self.processResponse(withPlacemarks: placemarks, error: error)
                    addressLbl2?.text = self.processResponse(withPlacemarks: placemarks, error: error)
                    print(placemarks ?? 0)
                }
            }
        }, failure: {(error) in
            self.stopAnimating()
            print("Error *** \(error)")
            Utility.showAlert(title: APPNAME, message: "Server Error!", viewController: self)
        })
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    func refresh() {
        // PULL TO REFRESH
        getCarStatus()
        getAlerts()
    }
    
    func fetchDataFromFile() {
        if Utility.isConnectedToNetwork() {
            self.refresh()
        } else {
            // FETCH ALERTS FROM FILE
            let storedData2 = Utility.readFromFile(fileName: FileNames.alerts.rawValue)
            // CHECK TRIPS FOR THE SELECTED MONTH
            if let status = storedData2["status"] as? String, status == "OK", let alertsDict = storedData2["data"] as? [String : Any], let alertsArray = alertsDict["alerts"] as? [[String : Any]], let tempStatus = alertsDict["resolved"] as? Bool {
                loadAlerts(alerts : alertsArray, tempStatus : tempStatus)
                // updateTempStatus(alertsArray: alertsArray)
            } else {
                // STATUS == ERROR OR NO DATA - CALL API
                getAlerts()
            }
            
            // FETCH CAR STATUS FROM FILE
            let storedData = Utility.readFromFile(fileName: FileNames.carStatus.rawValue)
            // CHECK TRIPS FOR THE SELECTED MONTH
            if let status = storedData["status"] as? String, status == "OK", let carStatusDict = storedData["data"] as? [String : Any] {
                assignValues(rawData: carStatusDict)
            } else {
                // STATUS == ERROR OR NO DATA - CALL API
                getCarStatus()
            }
        }
    }
    
    func getCarStatus() {
        if Utility.isConnectedToNetwork() {
            //self.stopAnimating()
            startAnimating(CGSize(width: 30, height: 30), message: "")
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getDeviceStatus + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                self.stopAnimating()
                guard let response = response as? [String : Any], let responseObj = response["data"] as? [String : Any] else {
                    return
                }
                DispatchQueue.global(qos: .background).async {
                    // UPDATE TO DB
                    Utility.storeStaticDataToFile(fileName: FileNames.carStatus.rawValue, rawData: responseObj)
                }
                Model.shared.isBatteryStatusResolved = false
                self.assignValues(rawData: responseObj)
            }) { (error) in
                self.stopAnimating()
                print("error *** \(error)")
            }
        } else {
            // NO INTERNET CONNECTION
            // FETCH CAR STATUS FROM FILE
            let storedData = Utility.readFromFile(fileName: FileNames.carStatus.rawValue)
            // CHECK TRIPS FOR THE SELECTED MONTH
            guard let status = storedData["status"] as? String, status == "OK", let carStatusDict = storedData["data"] as? [String : Any] else {
                self.assignValues(rawData: [:])
                return
            }
            self.assignValues(rawData: carStatusDict)
        }
    }
    func getAlerts() {
        if Utility.isConnectedToNetwork() {
            //self.stopAnimating()
            startAnimating(CGSize(width: 30, height: 30), message: "")
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getAlerts + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                /* STOP LOADER */
                self.refreshControl.endRefreshing()
                self.stopAnimating()
                if let response = response as? [String : Any], let responseObj = response["data"] as? [String : Any], let alertsArray = responseObj["alerts"] as? [[String : Any]], let count = responseObj["unread_count"] as? Int, let tempStatus = responseObj["resolved"] as? Bool {
                    DispatchQueue.global(qos: .background).async {
                        // UPDATE TO DB
                        Utility.storeStaticDataToFile(fileName: FileNames.alerts.rawValue, rawData: responseObj)
                    }
                    self.loadAlerts(alerts: alertsArray, tempStatus : tempStatus)
                    //  self.updateTempStatus(alertsArray: alertsArray)
                    guard count > 0 else {
                        return
                    }
                    self.markAsRead()
                } else if let response = response as? [String : Any], let responseObj = response["error"] as? [String : Any], let error =  responseObj["error"] as? String {
                    if error == ErrorsFromAPI.tokenError.rawValue {
                        // CALL SUBSCRIPTION API
                        Utility.checkSubscription(viewController: self)
                    } else {
                        Utility.storeStaticDataToFile(fileName: ErrorMsgs.serverError, rawData: responseObj)
                    }
                } else {
                    //                    self.statusLabelCollection2[1].text = "Normal"
                    //                    self.statusLabelCollection2[1].textColor = UIColor(hexString: "0073A4")
                }
            }) { (error) in
                print("error *** \(error)")
                self.refreshControl.endRefreshing()
                self.stopAnimating()
            }
        } else {
            if self.refreshControl != nil {
                self.refreshControl.endRefreshing()
            }
            // FETCH ALERTS FROM FILE
            let storedData2 = Utility.readFromFile(fileName: FileNames.alerts.rawValue)
            guard let status = storedData2["status"] as? String, status == "OK", let alertsDict = storedData2["data"] as? [String : Any], let alertsArray = alertsDict["alerts"] as? [[String : Any]], let tempStatus = alertsDict["resolved"] as? Bool else {
                return
            }
            self.loadAlerts(alerts : alertsArray, tempStatus : tempStatus)
            // self.updateTempStatus(alertsArray: alertsArray)
        }
    }
    
    func loadAlerts(alerts : [[String : Any]], tempStatus : Bool) {
        //  enableEmptyData = true
        self.alerts.removeAll()
        //        guard alerts.count > 0 else {
        //            self.tableView.reloadData()
        //            return
        //        }
        // USING MAP
        self.alerts = alerts.map {AlertsViewModel(alert: Alert(data: $0))}
        alertsRawData = alerts
        Model.shared.isTempStatusResolved = tempStatus
        
        if flag {
            flag = false
            self.tableView.reloadData()
        } else {
            flag = true
        }
    }
    
    func markAsRead() {
        guard retryCount <= 1 else {
            return
        }
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.markAlertsAsRead + "?"
            networkManager.putMethod(url, params: nil, success: { (response) in
                self.stopAnimating()
                guard let res = response as? [String : Any], res["error"] == nil else {
                    self.retryCount = self.retryCount + 1
                    self.markAsRead()
                    return
                }
                Model.shared.unreadAlertsCount = 0
                self.getAlerts()
            }) { (error) in
                print("error *** \(error)")
                self.stopAnimating()
                self.retryCount =  self.retryCount + 1
                self.markAsRead()
            }
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }
    
    func updateTempStatus(alertsArray : [[String : Any]]) {
        // shreeee
    }
    
    func assignValues(rawData : [String : Any]) {
        // shreeee
        carStatusRawData = rawData
        if flag {
            flag = false
            tableView.reloadData()
        } else {
            flag = true
        }
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
    // MARK: - TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if alerts.count > 3 {
            return 4
        } else {
            if carStatusRawData != nil {
                return alerts.count + 1
            } else {
                return 0
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let alertCell = tableView.dequeueReusableCell(withIdentifier: "EngineCell") else {
            print("ERROR")
            fatalError()
        }
        guard let carStatusCell = tableView.dequeueReusableCell(withIdentifier: "CarStatusCell") as? CarStatusCell else {
            print("ERROR")
            fatalError()
        }
        
        alertCell.selectionStyle = .none
        carStatusCell.selectionStyle = .none
        
        if indexPath.row == 0 {
            carStatusCell.carStatusView.layer.borderColor = GRAY.cgColor
            carStatusCell.tempView.layer.borderColor = GRAY.cgColor
            carStatusCell.batteryView.layer.borderColor = GRAY.cgColor
            carStatusCell.engineView.layer.borderColor = GRAY.cgColor
            
            let tapCarStatus: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCarStatusView))
            carStatusCell.carStatusView.addGestureRecognizer(tapCarStatus)
            
            let tapBattery: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapBatteryView))
            carStatusCell.batteryView.addGestureRecognizer(tapBattery)
            
            let tapTemp: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapTempView))
            carStatusCell.tempView.addGestureRecognizer(tapTemp)
        
            let tapEngine: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapEngineView))
            carStatusCell.engineView.addGestureRecognizer(tapEngine)
            
            if let engineDetails = carStatusRawData?["engine_status"] as? [String : Any] {
                if Model.shared.isBatteryStatusResolved {
                    carStatusCell.batteryLbl.textColor = UIColor(hexString: "0073A4")
                    carStatusCell.batteryLbl.text = "Normal"
                    batteryStatus = "Normal"
                } else {
                    var _battery_volt_status = engineDetails["battery_volt_status"] as? String
                    if _battery_volt_status?.lowercased() == "warning" {
                        carStatusCell.batteryLbl.textColor = UIColor(hexString: "D0021B")
                        _battery_volt_status = _battery_volt_status! + "!"
                    } else {
                        carStatusCell.batteryLbl.textColor = UIColor(hexString: "0073A4")
                    }
                    carStatusCell.batteryLbl.text = _battery_volt_status
                    batteryStatus = _battery_volt_status ?? "-"
                }
                var engine_coolant_temperature_status = engineDetails["engine_coolant_temperature_status"] as? String
                let last7DaysCal: Date! = Calendar.current.date(byAdding: .day, value: -6, to: Date())
                var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: last7DaysCal)
                components.timeZone = TimeZone(identifier: Model.shared.timeZone)
                components.hour = 0
                components.minute = 0
                components.second = 0
                let last7DaysFinal : Date! = Calendar.current.date(from: components)
                last7DaysAlets = self.alerts.filter({$0.reportTime >= last7DaysFinal})
                
                if engine_coolant_temperature_status?.lowercased() == "warning" {
                    carStatusCell.engineLbl.textColor = UIColor(hexString: "D0021B")
                    engine_coolant_temperature_status = engine_coolant_temperature_status! + "!"
                    carStatusCell.alertsCount.isHidden = false
                    carStatusCell.alertsCount.text = String(last7DaysAlets.count)
                   // carStatusCell.alertsCount.text = "999"
                } else {
                    carStatusCell.engineLbl.textColor = UIColor(hexString: "0073A4")
                    carStatusCell.alertsCount.isHidden = true
                }
                carStatusCell.engineLbl.text = engine_coolant_temperature_status
            }
            if let deviceStatus = carStatusRawData?["device_status"] as? [String : Any], let reportTime = deviceStatus["report_time"] as? String {
                carStatusCell.lastDetected.text = Utility.getFormattedDate(date: reportTime)
                lastDetected = Utility.getFormattedDate(date: reportTime)
                let deviceState = deviceStatus["status"] as? String
                carStatusCell.carStatus.text = deviceState?.capitalized
                self.deviceStatus = deviceState?.capitalized as? String ?? "-"
                carStatusCell.greenOrRedView.backgroundColor = deviceState?.lowercased() == "online" ? UIColor.init(hexString: "#86CE3B") : .red
            }
            
            carStatusCell.carSystemAlertsBtn.addTarget(self, action: #selector(carSystemAlertsBtnCall), for: .touchUpInside)
            
            if alertsRawData.count > 0 {
                if Model.shared.isTempStatusResolved {
                    carStatusCell.tempLbl.text = "Normal"
                    carStatusCell.tempLbl.textColor = UIColor(hexString: "0073A4")
                    tempStatus = carStatusCell.tempLbl.text ?? ""
                } else {
                    
                    let alerts = alertsRawData.map {Alert(data: $0)}
                    var overHeatAlerts = alerts.filter({$0.type == "high_temperature"})
                    if overHeatAlerts.count > 0 {
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
                            carStatusCell.tempLbl.text = "Normal"
                            carStatusCell.tempLbl.textColor = UIColor(hexString: "0073A4")
                        } else {
                            carStatusCell.tempLbl.text = "Warning!"
                            carStatusCell.tempLbl.textColor = UIColor(hexString: "D0021B")
                        }
                        
                    } else {
                        carStatusCell.tempLbl.text = "Normal"
                        carStatusCell.tempLbl.textColor = UIColor(hexString: "0073A4")
                    }
                    tempStatus = carStatusCell.tempLbl.text ?? ""
                    
                }
            } else {
                carStatusCell.tempLbl.text = "Normal"
                carStatusCell.tempLbl.textColor = UIColor(hexString: "0073A4")
                tempStatus = carStatusCell.tempLbl.text ?? ""
            }
            return carStatusCell
        } else {
            let image = alertCell.viewWithTag(1) as? UIImageView
            let time = alertCell.viewWithTag(2) as? UILabel
            let message = alertCell.viewWithTag(3) as? UILabel
            let status = alertCell.viewWithTag(4) as? UIImageView
            
            image?.image = UIImage(named: alerts[indexPath.row - 1].image)
            time?.text = alerts[indexPath.row - 1].date
            message?.text = alerts[indexPath.row - 1].message
            status?.isHidden = true
            if alerts[indexPath.row - 1].status.lowercased() == "unread" {
                status?.isHidden = false
            }
            return alertCell
        }
    }
    
    func carSystemAlertsBtnCall() {
        // NAVIGATE TO CarStatusAlertsVC SCREEN
        if let alertsVC = mainSB.instantiateViewController(withIdentifier: "CarStatusAlertsVC") as? CarStatusAlertsVC {
            alertsVC.alertsArray = alerts
            alertsVC.islast7DaysAlerts = false
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(alertsVC, animated: true)
        }
    }
    
    //    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //
    //        if alerts[indexPath.row].status.lowercased() == "unread" {
    //            return true
    //        }
    //
    //        return false
    //
    //    }
    
    //    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
    //
    //        selectedItem = editActionsForRowAt.row
    //
    //        let markAsRead = UITableViewRowAction(style: .normal, title: "Mark As\n Read") { action, index in
    //
    //            // Call API
    //
    //            self.putMarkAsRead(alertId: self.alerts[self.selectedItem].alertId)
    //
    //            // after success dismiss the left button reaload that cell
    //
    //        }
    //        markAsRead.backgroundColor = #colorLiteral(red: 0.2073091865, green: 0.6597844958, blue: 1, alpha: 1)
    //        return [markAsRead]
    //    }
    
    //    func putMarkAsRead(alertId:String) {
    //
    //        let url = Constants.ServerAddress.baseURL + "/api/alert/markread/" + alertId + "?"
    //
    //        networkManager.putMethod(url, params: nil, success: { (response) in
    //
    //            if  let alertResponse = response as? [String:Any] {
    //                self.alerts[self.selectedItem].status = "Read"
    //                let indexPath = IndexPath(item: self.selectedItem, section: 0)
    //                self.tableView.reloadRows(at: [indexPath], with: .none)
    //            }
    //        }, failure: { (error) in
    //
    //            print("Error: \(error)")
    //        })
    //    }
    
    func locateMyCarBtnCall() {
        if let locateMyCarVC = mainSB.instantiateViewController(withIdentifier: "LocateMyCarVC") as? LocateMyCarVC {
            locateMyCarVC.lastDetectedDate = lastDetected
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(locateMyCarVC, animated: true)
        }
    }
    
    func cancelBtnCall() {
        dismissView()
    }
    
    func probResolvedBtnCall() {
        if Utility.isConnectedToNetwork() {
            startAnimating(CGSize(width: 30, height: 30), message: "")
          //  let params :[String : String] = ["type" : fieldToBeUpdated]
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.maskAsResolved + fieldToBeUpdated
            networkManager.putMethod(url, params: nil, success: { (response) in
                self.stopAnimating()
                guard let res = response as? [String : Any], res["error"] == nil else {
                    Utility.showAlert(message: ErrorMsgs.tryAgain, viewController: self)
                    return
                }
                if self.fieldToBeUpdated == "battery" {
                    Model.shared.isBatteryStatusResolved = true
                } else {
                    Model.shared.isTempStatusResolved = true
                }
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                self.dismissView()
//                if self.fieldToBeUpdated == "battery" {
//                    self.getCarStatus()
//                } else {
//                    self.getAlerts()
//                }
            }) { (error) in
                print("error *** \(error)")
                self.stopAnimating()
                Utility.showAlert(message: ErrorMsgs.serverError, viewController: self)
            }
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
        /// Utility.showAlert(message: "Waiting for the API 😝", viewController: self)
    }
    
    func tapCarStatusView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.overlayView.alpha = 0.5
            if self.deviceStatus.lowercased() == "online" {
                DispatchQueue.main.async {
                    self.alertsViewArray[0].alpha = 1.0
                    self.view.bringSubview(toFront: self.alertsViewArray[0])
                    let lastDetectedLbl = self.alertsViewArray[0].viewWithTag(10) as? UILabel
                    let warningLbl = self.alertsViewArray[0].viewWithTag(3) as? UILabel
                    warningLbl?.textColor = .black
                    lastDetectedLbl?.text = self.lastDetected
                }
            } else {
                DispatchQueue.main.async {
                    self.alertsViewArray[3].alpha = 1.0
                    self.view.bringSubview(toFront: self.alertsViewArray[3])
                    let lastDetectedLbl = self.alertsViewArray[3].viewWithTag(10) as? UILabel
                    let warningLbl = self.alertsViewArray[3].viewWithTag(3) as? UILabel
                    warningLbl?.textColor = .black
                    lastDetectedLbl?.text = self.lastDetected
                }
            }
        })
    }
    
    func tapBatteryView() {
        fieldToBeUpdated = "battery"
        UIView.animate(withDuration: 0.5, animations: {
            self.overlayView.alpha = 0.5
            if self.batteryStatus.lowercased().contains("warning") {
                DispatchQueue.main.async {
                    self.alertsViewArray[4].alpha = 1.0
                    self.view.bringSubview(toFront: self.alertsViewArray[4])
                    let lastDetectedLbl = self.alertsViewArray[4].viewWithTag(10) as? UILabel
                    let warningLbl = self.alertsViewArray[4].viewWithTag(3) as? UILabel
                    warningLbl?.textColor = .red
                    lastDetectedLbl?.text = self.lastDetected
                }
            } else {
                DispatchQueue.main.async {
                    self.alertsViewArray[1].alpha = 1.0
                    self.view.bringSubview(toFront: self.alertsViewArray[1])
                    let lastDetectedLbl = self.alertsViewArray[1].viewWithTag(10) as? UILabel
                    let warningLbl = self.alertsViewArray[1].viewWithTag(3) as? UILabel
                    warningLbl?.textColor = .black
                    lastDetectedLbl?.text = self.lastDetected
                }
            }
        })
    }
    
    func tapTempView() {
        fieldToBeUpdated = "temperature"
        UIView.animate(withDuration: 0.5, animations: {
            self.overlayView.alpha = 0.5
            if self.tempStatus.lowercased().contains("warning") {
                DispatchQueue.main.async {
                    self.alertsViewArray[5].alpha = 1.0
                    self.view.bringSubview(toFront: self.alertsViewArray[5])
                    let lastDetectedLbl = self.alertsViewArray[5].viewWithTag(10) as? UILabel
                    let warningLbl = self.alertsViewArray[5].viewWithTag(3) as? UILabel
                    warningLbl?.textColor = RED
                    lastDetectedLbl?.text = self.lastDetected
                }
            } else {
                DispatchQueue.main.async {
                    self.alertsViewArray[2].alpha = 1.0
                    let lastDetectedLbl = self.alertsViewArray[2].viewWithTag(10) as? UILabel
                    self.view.bringSubview(toFront: self.alertsViewArray[2])
                    let warningLbl = self.alertsViewArray[2].viewWithTag(3) as? UILabel
                    warningLbl?.textColor = .black
                    lastDetectedLbl?.text = self.lastDetected
                }
            }
        })
    }
    
    func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) -> String {
        // Update View
        
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            return "Unable to Find Address for Location"
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                if let addrDict = placemark.addressDictionary as? [String : Any], let addrArr = addrDict["FormattedAddressLines"] as? [String] {
                    return addrArr.joined(separator: ", ")
                }
            } else {
               return "No Matching Addresses Found"
            }
        }
        return ""
    }
    
    func tapEngineView() {
        // NAVIGATE TO CarStatusAlertsVC SCREEN
        if let alertsVC = mainSB.instantiateViewController(withIdentifier: "CarStatusAlertsVC")
            as? CarStatusAlertsVC {
            
            alertsVC.alertsArray = last7DaysAlets
            alertsVC.islast7DaysAlerts = true
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(alertsVC, animated: true)
        }
    }
    
    func dismissView() {
        self.overlayView.alpha = 0.0
        for index in 0...alertsViewArray.count - 1 {
            self.alertsViewArray[index].alpha = 0.0
        }
    }
    
    // MARK: - DZN VIEW
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return nil
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String!
        text = "No Alerts"
        let attributed = NSAttributedString(string: text)
        return attributed
    }
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    // MARK: - DZNEmptyDataSetDelegate Methods
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if enableEmptyData {
            return true
        }
        return false
    }
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    // MARK: - LocationServiceDelegate
    func tracingLocation(currentLocation: CLLocation, GPSSignal : String) {
        self.latitude = currentLocation.coordinate.latitude
        self.longitude = currentLocation.coordinate.longitude
    }
    
    func tracingLocationDidFailWithError(error: NSError) {
        print("tracingLocationDidFailWithError TRIP TRACKING")
    }
    
    
}

class CarStatusCell: UITableViewCell {
    @IBOutlet weak var greenOrRedView: UIView!
    @IBOutlet weak var carStatus: UILabel!
    @IBOutlet weak var lastDetected: UILabel!
    @IBOutlet weak var batteryLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var engineLbl: UILabel!
    
    @IBOutlet weak var carStatusView: UIView!
    @IBOutlet weak var batteryView: UIView!
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var engineView: UIView!
    @IBOutlet weak var carSystemAlertsBtn: UIButton!
    @IBOutlet weak var alertsCount: UILabel!
    
}


