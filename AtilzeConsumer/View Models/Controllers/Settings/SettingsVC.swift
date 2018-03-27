//
//  SettingsVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 31/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Instabug
import Firebase
import Moscapsule
class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex : IndexPath?
    var refreshControl: UIRefreshControl!
    var menuBtn: UIBarButtonItem?
    var trackingModeOverlay: UIView = UIView()
    var drivingStatusView: UIView?
    var drivingStatusButton: UIButton?
    
//    var profileDict: [String : String] = ["name" : "", "phone" : "", "email" : ""]
//    var carModelDict: [[String : String]] = [["key" : "Car Model", "value" : ""], ["key" : "VIN NO.", "value" : ""], ["key" : "Car Plate", "value" : ""], ["key" : "Starting Mileage", "value" : ""], ["key" : "Current Mileage", "value" : ""]]
//    
    /// Enums for sections
    enum TableViewSections {
        case profile
        case carInformation
        case trackingMode
        case extra
        static let sectionNames = [trackingMode: "Tracking Mode", profile: "Account", carInformation: "Car Information"]
        func sectionName() -> String { return TableViewSections.sectionNames[self]! }
    }
    
    let sections = [TableViewSections.trackingMode, TableViewSections.profile, TableViewSections.carInformation, TableViewSections.extra]
    
    /// Enums for Indexpaths
    enum IndexPathValues {
        static let firstSectionNames = ["Full Name", "Email", "Contact no", "Password", "Emergency Contact", "Time Zone"]
       // static let secondSectionNames = ["Car Model", "VIN No.", "Car Plate", "Starting Mileage", "Current Mileage"]
        static let secondSectionNames = ["Car Model", "VIN No.", "Car Plate"]
        static let thirdSectionNames = ["FAQ", "Terms", "Give Feedback", "Logout"]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.image = UIImage(named: "emergency")
        setUpView()
        fetchDataFromFile()
    }
    override func viewWillAppear(_ animated: Bool) {
        updateDrivingStatus()
        
//        let accountType = Utility.getLoginMode()
//        if accountType == "OBDless" {
//            menuBtn = self.navigationItem.leftBarButtonItem
//            self.navigationItem.leftBarButtonItem = nil
//        } else {
//            if self.navigationItem.leftBarButtonItem == nil { self.navigationItem.leftBarButtonItem = menuBtn }
//        }
        guard selectedIndex != nil else {
            return
        }
        tableView.reloadRows(at: [selectedIndex!], with: .fade)
//        getVehicleInfo()
//        getUserInfo()

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(_ animated: Bool) {
    }
    
    // MARK: - SETUP
    func setUpView() {
        // ADD OBSERVER
        NotificationCenter.default.addObserver(self, selector: #selector(fetchDataFromFile), name: NSNotification.Name(rawValue: "refreshSettings"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDrivingStatus), name: NSNotification.Name(rawValue: "updateDrivingStatus"), object: nil)
        // MENU
        if revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        }
        // TABLE VIEW
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        // REFRESH CONTROL
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.tintColor = UIColor.init(hexString: "00A3EA")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        trackingModeOverlay = Bundle.main.loadNibNamed("TrackingModeView", owner: self, options: nil)?[0] as? UIView ?? UIView()
        trackingModeOverlay.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        trackingModeOverlay.alpha = 0.0
        UIApplication.shared.keyWindow?.addSubview(trackingModeOverlay)
       // self.view.addSubview(trackingModeOverlay)
    }
    
    func refresh() {
        getUserInfo()
        getVehicleInfo()
    }
    
    func fetchDataFromFile() {
        // FETCH CAR STATUS FROM FILE
        let storedData = Utility.readFromFile(fileName: FileNames.vehicleInfo.rawValue)
        // CHECK TRIPS FOR THE SELECTED MONTH
        guard let status = storedData["status"] as? String, status == "OK", let vehicleInfo = storedData["data"] as? [String : Any] else {
            getVehicleInfo()
            return
        }
        assignValue(rawData : vehicleInfo)
        
        let storedData2 = Utility.readFromFile(fileName: FileNames.userInfo.rawValue)
        if let status = storedData2["status"] as? String, status == "OK", let userInfo = storedData2["data"] as? [String : Any] {
            Model.shared.profileDict["emergency_name"] = userInfo["emergency_name"] as? String
            Model.shared.profileDict["emergency_contact"] = userInfo["emergency_contact"] as? String
            Model.shared.profileDict["name"] = userInfo["name"] as? String
            Model.shared.profileDict["phone"] = userInfo["contact"] as? String
            Model.shared.profileDict["email"] = userInfo["email"] as? String
            tableView.reloadData()
        } else {
            // STATUS == ERROR OR NO DATA - CALL API
            getUserInfo()
        }
        
    }
    func getVehicleInfo() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getVehicleInfo + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                self.refreshControl.endRefreshing()
                guard let res = response as? [String : Any], let responseObj = res["data"] as? [String : Any] else {
                    if let res = response as? [String : Any], let responseObj = res["error"] as? [String : Any], let error =  responseObj["error"] as? String {
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
                    Utility.storeStaticDataToFile(fileName: FileNames.vehicleInfo.rawValue, rawData: responseObj)
                }
                self.assignValue(rawData : responseObj)
            }) { (error) in
                if self.refreshControl != nil {
                    self.refreshControl.endRefreshing()
                }
                print("error *** \(error)")
            }
        } else {
            // NO INTERNET CONNECTION
            // FETCH CAR STATUS FROM FILE
            if self.refreshControl != nil {
                self.refreshControl.endRefreshing()
            }
            let storedData = Utility.readFromFile(fileName: FileNames.vehicleInfo.rawValue)
            // CHECK TRIPS FOR THE SELECTED MONTH
            guard let status = storedData["status"] as? String, status == "OK", let carStatusDict = storedData["data"] as? [String : Any] else {
                self.assignValue(rawData: [:])
                return
            }
            self.assignValue(rawData: carStatusDict)
        }
    }
    
    // MARK: - API
    func getUserInfo() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getAccountInfo + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                guard let res = response as? [String : Any], let responseObj = res["data"] as? [String : Any] else {
                    if let res = response as? [String : Any], let responseObj = res["error"] as? [String : Any], let error =  responseObj["error"] as? String {
                        if error == ErrorsFromAPI.tokenError.rawValue {
                            // CALL SUBSCRIPTION API
                            Utility.checkSubscription(viewController: self)
                        } else {
                            Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
                        }
                    }
                    return
                }
                Model.shared.profileDict["emergency_name"] = responseObj["emergency_name"] as? String
                Model.shared.profileDict["emergency_contact"] = responseObj["emergency_contact"] as? String
                Model.shared.profileDict["name"] = responseObj["name"] as? String
                Model.shared.profileDict["phone"] = responseObj["contact"] as? String
                Model.shared.profileDict["email"] = responseObj["email"] as? String
                DispatchQueue.global(qos: .background).async {
                    Utility.storeStaticDataToFile(fileName: FileNames.userInfo.rawValue, rawData: responseObj)
                }
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            // NO INTERNET CONNECTION
        }
    }

    func assignValue(rawData : [String : Any]) {
        // CAR MODEL
        if let modelName = rawData["model"] as? String {
            Model.shared.carModelDict[0]["value"] = modelName
        }
        if let vin = rawData["vin"] as? String {
             Model.shared.carModelDict[1]["value"] = vin
        }
        if let licensePlate = rawData["license_plate"] as? String {
             Model.shared.carModelDict[2]["value"] = licensePlate
        }
        if let manufacturer = rawData["manufacturer"] as? String {
            Model.shared.carModelDict[5]["value"] = manufacturer
        }
        if let startingMileage = rawData["start_mileage"] as? Double {
            Model.shared.carModelDict[3]["value"] =  String(describing: startingMileage)
        }
        if let currentMileage = rawData["current_mileage"] as? Double {
            Model.shared.carModelDict[4]["value"] =  String(describing: currentMileage)
        }
        // PROFILE
        Model.shared.profileDict["name"] = rawData["driver_name"] as? String
        Model.shared.profileDict["phone"] = rawData["driver_contact"] as? String
        Model.shared.profileDict["email"] = rawData["driver_email"] as? String
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = sections[section]
        switch sectionType {
        case .profile:
            return 6
        case .carInformation:
            return 3
        case .trackingMode:
            return 1
        case .extra:
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let profileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") else {
            print("ERROR")
            fatalError()
        }
        guard let passwordCell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell") else {
            print("ERROR")
            fatalError()
        }
        guard let carModelCell = tableView.dequeueReusableCell(withIdentifier: "CarModelCell") else {
            print("ERROR")
            fatalError()
        }
        profileCell.selectionStyle = .none
        passwordCell.selectionStyle = . none
        carModelCell.selectionStyle = .none
        
        let sectionType = sections[indexPath.section]
        
        switch sectionType {
        case .profile:
            switch indexPath.row {
            case 0, 1, 2, 5:
                var labelText : String = ""
                var valueText : String = ""
                
                let arrow = carModelCell.viewWithTag(3) as? UIImageView
                arrow?.isHidden = false
                
                if indexPath.row == 0 {
                    labelText = "Full Name"
                    valueText = Model.shared.profileDict["name"] ?? ""
                } else if indexPath.row == 1 {
                    labelText = "Email"
                    valueText = Model.shared.profileDict["email"] ?? ""
                    arrow?.isHidden = true
                } else if indexPath.row == 2 {
                    labelText = "Contact no."
                    valueText = Model.shared.profileDict["phone"] ?? ""
                } else {
                    labelText = "Time Zone"
                    valueText = Model.shared.timeZone
                }

                if let label = carModelCell.viewWithTag(1) as? UILabel {
                    label.text = labelText
                }
                if let valueLbl = carModelCell.viewWithTag(2) as? UILabel {
                    valueLbl.text = valueText
                }
                return carModelCell
                
            case 3, 4:
                if let label = passwordCell.viewWithTag(1) as? UILabel {
                    if indexPath.row == 3 {
                        label.text = "Password"
                    } else {
                        label.text = "Emergency Contact"
                    }
                }
                return passwordCell
                
            default: return passwordCell
            }
        case .carInformation:
            
            // LOGOUT
//            if indexPath.row == 5 {
//                if let label = carModelCell.viewWithTag(1) as? UILabel {
//                    label.text = "Log Out"
//                }
//                if let valueLbl = carModelCell.viewWithTag(2) as? UILabel {
//                    valueLbl.text = ""
//                }
//                return carModelCell
//            }
            
            if let label = carModelCell.viewWithTag(1) as? UILabel, let keyName = Model.shared.carModelDict[indexPath.row]["key"] {
                label.text = keyName
            }
            if let valueLbl = carModelCell.viewWithTag(2) as? UILabel, let value = Model.shared.carModelDict[indexPath.row]["value"], let arrow = carModelCell.viewWithTag(3) as? UIImageView {
                
//                if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 || indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 2 {
//                    valueLbl.text = "\(value) km"
//                } else {
//                    valueLbl.text = value
//                }
                arrow.isHidden = true
                valueLbl.text = value
                if indexPath.row == 1 || indexPath.row == 2 {
                    arrow.isHidden = true
                }
            }
            if let image = carModelCell.viewWithTag(3) as? UIImageView {
                image.isHidden = false
                if indexPath.row == 4 {
                    image.isHidden = true
                }
            }
            return carModelCell
        case .trackingMode:
            if let label = carModelCell.viewWithTag(1) as? UILabel {
                label.text = "Tracking Mode"
            }
            if let valueLbl = carModelCell.viewWithTag(2) as? UILabel {
                var trackingMode : String = Utility.getLoginMode()
                if trackingMode == "OBDless" {
                    trackingMode =  trackingMode + "-" + Utility.getLoginType()
                }
                valueLbl.text = trackingMode
            }
            return carModelCell
        case .extra:
            if indexPath.row == 4 {
                let arrow = carModelCell.viewWithTag(3) as? UIImageView
                arrow?.isHidden = true
                if let label = carModelCell.viewWithTag(1) as? UILabel {
                    label.text = ""
                }
                if let valueLbl = carModelCell.viewWithTag(2) as? UILabel {
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        valueLbl.text = "Version " + version
                    } else {
                        valueLbl.text = "NA"
                    }
                }
                return carModelCell
            } else {
                let label = passwordCell.viewWithTag(1) as? UILabel
                label?.text = IndexPathValues.thirdSectionNames[indexPath.row]
                return passwordCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 3 {
            let view: UIView = UIView()
            view.backgroundColor = UIColor(hexString: "F1F1F1")
            return view
        }
        let view  = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        view.backgroundColor = UIColor(hexString: "F1F1F1")
        let sectionLabel = UILabel.init(frame: CGRect(x: 15, y: 20, width: tableView.bounds.width, height: 30))
        sectionLabel.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        sectionLabel.textAlignment = .left
        sectionLabel.textColor = .black
        
        // Get Section Name
        let sectionType = sections[section]
        sectionLabel.text = sectionType.sectionName()
        
        view.addSubview(sectionLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 3 {
            return 20
        }
        return 50.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSection = sections[indexPath.section]
        switch selectedSection {
        case .trackingMode:
            let alert = UIAlertController(title: "SELECT TRACKING MODE", message: nil, preferredStyle: .actionSheet)
            let auto = UIAlertAction(title: "OBDless Auto", style: .default, handler: changetoAutoTracking)
            let manual = UIAlertAction(title: "OBDless Manual", style: .default, handler: changetoManualTracking)
            let obd = UIAlertAction(title: "OBD", style: .default, handler: changetoObd)
            alert.addAction(obd)
            alert.addAction(auto)
            alert.addAction(manual)
            self.present(alert, animated: true, completion: nil)
            return
        case .profile:
            if indexPath.row != 5 {
                if indexPath.row == 4 {
                    guard let addEmergencyVC = mainSB.instantiateViewController(withIdentifier: StoryBoardVC.addEmergencyContact) as? AddEmergencyContacts else {
                        return
                    }
                    let backItem = UIBarButtonItem()
                    backItem.title = ""
                    self.navigationItem.backBarButtonItem = backItem
                    addEmergencyVC.isAddContact = true
                    if let name = Model.shared.profileDict["emergency_name"], let contactNo = Model.shared.profileDict["emergency_contact"], !name.isEmpty, !contactNo.isEmpty {
                        addEmergencyVC.isAddContact = false
                    }
                    navigationController?.pushViewController(addEmergencyVC, animated: true)
                }
                else if indexPath.row == 1 {
                    return
                } else {
                    guard let  changePasswordVc  = mainSB.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC else {
                        return
                    }
                    changePasswordVc.selectedField = IndexPathValues.firstSectionNames[indexPath.row]
                    changePasswordVc.currectValuesDict = Model.shared.profileDict
                    changePasswordVc.selectedIndex =  indexPath
                    selectedIndex = indexPath
                    navigationController?.pushViewController(changePasswordVc, animated: true)
                }
            } else {
                guard let  timeZoneVc  = mainSB.instantiateViewController(withIdentifier: "EditTimeZoneVC") as? EditTimeZoneVC else {
                    return
                }
                selectedIndex = indexPath
                navigationController?.pushViewController(timeZoneVc, animated: true)
            }
            return
        case .extra:
            if indexPath.row == 0 {
                guard let  supportVC  = mainSB.instantiateViewController(withIdentifier: "HelpSupportVC") as? HelpSupportVC else {
                    return
                }
                self.navigationItem.backBarButtonItem?.title = ""
                navigationController?.pushViewController(supportVC, animated: true)}
            else if indexPath.row == 1 {
                guard let  termsVC  = mainSB.instantiateViewController(withIdentifier: "TermsVC") as? TermsVC else {
                    return
                }
                self.navigationItem.backBarButtonItem?.title = ""
                navigationController?.pushViewController(termsVC, animated: true)}
            else if indexPath.row == 3 {
                let alertController = UIAlertController(title: "LOG OUT", message: "Are you sure you want to logout?", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Log Out", style: .default, handler: { _ in
                    self.okAction()
                })
                alertController.addAction(defaultAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                present(alertController, animated: true, completion: nil)}
            else {
               // Utility.showAlert(message: "Under Development", viewController: self)
                //FEEDBACK
                Analytics.logEvent("Feedback_Submit", parameters: nil)
                Instabug.invoke()
            }
            return
            
        default :
            let carInfoIndex = IndexPathValues.secondSectionNames[indexPath.row]
            switch carInfoIndex {
            case EditProfile.carModel :
                guard let  editCarModelVC  = mainSB.instantiateViewController(withIdentifier: "EditCarModelVC") as? EditCarModelVC else {
                    return
                }
                editCarModelVC.carModelString = Model.shared.carModelDict[indexPath.row]["value"]!
                editCarModelVC.manufacturerString = Model.shared.carModelDict[5]["value"]!
                editCarModelVC.selectedIndex =  indexPath
                selectedIndex = indexPath
                navigationController?.pushViewController(editCarModelVC, animated: true)
            default:
                if indexPath.row == 5 {
                    okAction()
                    return
                }
//                if indexPath.row != 4 {
//                    guard let  changePasswordVc  = mainSB.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC else {
//                        return
//                    }
//                    changePasswordVc.selectedField = IndexPathValues.secondSectionNames[indexPath.row]
//                    changePasswordVc.currentValue = Model.shared.carModelDict[indexPath.row]["value"]!
//                    changePasswordVc.currectValuesDict = Model.shared.carModelDict[indexPath.row]
//                    changePasswordVc.selectedIndex =  indexPath
//                    selectedIndex = indexPath
//                    navigationController?.pushViewController(changePasswordVc, animated: true)
//                }
            }
        }
        self.navigationItem.backBarButtonItem?.title = ""
    }
    func okAction() {
        if Utility.isConnectedToNetwork() {
            let deviceToken = UserDefaults.standard.object(forKey: "VW.Consumer.deviceToken") as? String
            if deviceToken != nil {
                let params: [String : String] = ["device_token" : deviceToken ?? ""]
                print("params ===== \(params)")
                let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.deleteDeviceToken
                networkManager.deleteMethod(url, params: params, success: { (response) in
                    guard let result = response as? [String : Any], let resultString = result["message"] as? String, resultString.lowercased().range(of:"unsuccessfully") == nil else {
                        // TRY ONE MORE TIME
                        // SHUD BE SUCCESSFUL ALL TIME
                        Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                        return
                    }
                    self.clearLocaldata()
                    
                }) { (error) in
                    print("error *** \(error)")
                    Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
                }
            } else {
                // NO DEVICE TOKEN
                clearLocaldata()
            }
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
            print("internetConnectMsg -- Update device token")
        }
    }
    
    func changetoAutoTracking(action: UIAlertAction) {
        let currentTrackingMode = Utility.getLoginMode()
        let currentTrackingtype = Utility.getLoginType()
        guard currentTrackingtype.lowercased() != "auto" else {
//            if !Model.shared.isAutoTrackingMode {
//                Model.shared.isAutoTrackingMode = true
//                Model.shared.isTrackingModeChanged = true
//            }
            return
        }
        
        var alertTitle : String = ""
        if currentTrackingMode != "OBDless" {
            // OBD TO AUTO
            alertTitle = "Changing to OBDless Auto tracking will stop the OBD device tracking and will continue tracking through your phone. Are you sure you want proceed to OBDless Auto tracking?"
            
        } else {
            // MANUAL TO AUTO
            alertTitle = "Changing to OBDless Auto will hide start and stop buttons. Are you sure you want proceed to OBDless Auto tracking?"
        }
        showAlert(title: alertTitle, changeToMode: "OBDless", changeToType: "Auto")
    }

    func changetoManualTracking(action: UIAlertAction) {
        let currentTrackingMode = Utility.getLoginMode()
        let currentTrackingtype = Utility.getLoginType()
        guard currentTrackingtype.lowercased() != "manual" else {
//            if Model.shared.isAutoTrackingMode {
//                Model.shared.isAutoTrackingMode = false
//                Model.shared.isTrackingModeChanged = true
//            }
            return
        }
        
        var alertTitle : String = ""
        if currentTrackingMode != "OBDless" {
            // OBD TO MANUAL
           alertTitle = "Changing to OBDless Manual will stop the OBD device tracking and will continue tracking through your phone. Are you sure you want proceed to OBDless Manual tracking?"
            
        } else {
            // AUTO TO MANUAL
            alertTitle = "Changing to OBDless Manual will stop Auto tracking. Are you sure you want proceed to OBDless Manual tracking?"
        }
        
        showAlert(title: alertTitle, changeToMode: "OBDless", changeToType: "Manual")
    }

    func changetoObd(action: UIAlertAction){
        let currentTrackingMode = Utility.getLoginMode()
        guard currentTrackingMode != "OBD"  else {
            return
        }
        showAlert(title: "Changing to OBD will stop the Phone tracking and will continue tracking through your OBD device. Are you sure you want proceed to OBD tracking?", changeToMode: "OBD", changeToType: "Api")
    }
    
    func showAlert(title : String, changeToMode : String, changeToType : String){
        let alertController = UIAlertController(title: APPNAME, message: title, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.switchAccountType(changeToMode: changeToMode, changeToType : changeToType)
        })
        alertController.addAction(defaultAction)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func switchAccountType(changeToMode: String, changeToType : String) {
        // shreeeee add loader
        
//        var changeTo : String  = ""
//        changeTo = Utility.getLoginMode() ? "OBDless" : "OBD"
        
        print("changeTo == \(changeToMode)")
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            "Setup_Selection" : changeToMode
            ])
        
        self.startAnimating(CGSize(width: 30, height: 30), message: "")
        UIView.animate(withDuration: 0.0, animations: {
            self.trackingModeOverlay.alpha = 1.0
            let label = self.trackingModeOverlay.viewWithTag(1) as? UILabel
            label?.text = "Switching to \(changeToMode) Tracking Mode"
        })
        let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.switchAccountType + changeToMode + "/" +  changeToType
        networkManager.putMethod(url, params: nil, success: { (response) in
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.trackingModeOverlay.alpha = 0.0
                    self.stopAnimating()
                })
            }
            guard let res = response as? [String : Any], res["error"] == nil else {
                Utility.showAlert(message: "Try Again!!", viewController: self)
                return
            }
            guard let dict = res["data"] as? [String : Any], let mode = dict["mode"] as? String else {
                return
            }
            UserDefaults.standard.set(mode, forKey: "VW.Consumer.loginMode")
            
            let device_id: String = dict["device_id"] as? String ?? ""
            if mode == "OBDless" {
                UserDefaults.standard.set(device_id, forKey: "VW.Consumer.deviceID")
                self.getMQTTInfo()
            }
            Model.shared.isTrackingModeChanged = true
            if let type = dict["type"] as? String {
                UserDefaults.standard.set(type, forKey: "VW.Consumer.loginType")
                if type.lowercased() == "auto" {
                     Model.shared.isAutoTrackingMode = true
                } else {
                    Model.shared.isAutoTrackingMode = false
                }
            } else {
                UserDefaults.standard.set("", forKey: "VW.Consumer.loginType")
                Model.shared.isAutoTrackingMode =  false
            }
           
            if let msg = dict["message"] as? String {
            Utility.showAlert(message: msg, viewController: self)
               return
            }
           
            let accountType = Utility.getLoginMode()
            let driveNdTrack : UITabBarItem = (self.tabBarController?.tabBar.items![2])!
            if (driveNdTrack.title?.lowercased().contains("car"))! {
                
                if accountType == "OBD" {
                    // NO CHNAGE
                } else {
                    let driveAndTrackNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.driveAndTrack)
                    var controllers = self.tabBarController?.viewControllers
                    controllers?[2] = driveAndTrackNC
                    
                    self.tabBarController?.setViewControllers(controllers, animated: true)
                    self.tabBarController?.selectedIndex = 2  // DRIVE AND TRACK
                    
                    let driveNdTrack : UITabBarItem = (self.tabBarController?.tabBar.items![2])!
                    driveNdTrack.image = UIImage(named: "DriveTrack")?.withRenderingMode(.alwaysOriginal)
                    driveNdTrack.selectedImage = UIImage(named: "DriveTrackSelected")?.withRenderingMode(.alwaysOriginal)
                }
            } else if (driveNdTrack.title?.lowercased().contains("drive"))! {
                if accountType == "OBDless" {
                    // NO CHANGE
                } else {
                    let driveAndTrackNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.car)
                    var controllers = self.tabBarController?.viewControllers
                    controllers?[2] = driveAndTrackNC
                    
                    self.tabBarController?.setViewControllers(controllers, animated: true)
                    self.tabBarController?.selectedIndex = 2  // DRIVE AND TRACK
                    
                    let driveNdTrack : UITabBarItem = (self.tabBarController?.tabBar.items![2])!
                    driveNdTrack.image = UIImage(named: "CarStatus")?.withRenderingMode(.alwaysOriginal)
                    driveNdTrack.selectedImage = UIImage(named: "CarStatusSelected")?.withRenderingMode(.alwaysOriginal)
                }
                print("Drive And Track")
            }
            self.tabBarController?.selectedIndex = 0
          //  Utility.showAlert(title: APPNAME, message: "Successfully changed the Tracking Mode to \(mode)", viewController: self)
            UserDefaults.standard.set(mode, forKey: "VW.Consumer.loginMode")
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)

        }) { (_) in
            UIView.animate(withDuration: 3.0, animations: {
                self.trackingModeOverlay.alpha = 0.0
            })
            self.stopAnimating()
            Utility.showAlert(message: "Server Error", viewController: self)
        }
    }
    
    func getMQTTInfo() {
        if Utility.isConnectedToNetwork() {
            // INTERNET CONNECTION AVAILABLE
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getMqqtSeverInfo + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                if let res = response as? [String : Any], let mqttInfo = res["data"] as? [String : Any] {
                    UserDefaults.standard.set(mqttInfo, forKey: "VW.Consumer.MQTTInfo")
                    // MQTT
                    let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
                    let port: Int = mqttInfo["port"] as? Int ?? 0
                    let portInt32 : Int32 = Int32(port)
                    let host : String = mqttInfo["host"] as? String ?? ""
                    let userName : String = mqttInfo["username"] as? String ?? ""
                    let password : String = mqttInfo["password"] as? String ?? ""
                    Model.shared.mqttConfig = MQTTConfig(clientId: clientID, host: host, port: portInt32, keepAlive: 100)
                    Model.shared.mqttConfig?.mqttAuthOpts = MQTTAuthOpts(username: userName, password: password)
                }
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            print(internetConnectMsg)
        }
    }
    
    func clearLocaldata() {
        // STOP TIMER AS WE NO LONGER NEED TO REFRESH THE ACCESS TOKEN AND OTHER APIS
        timerForRefreshToken.invalidate()
        timerForTripsRefresh.invalidate()
        timerForSetingsRefresh.invalidate()
        timerForDashBoardRefresh.invalidate()
        timerForNotificationsRefresh.invalidate()
        timerForAlertsRefresh.invalidate()
        Model.destroy()
        // DELETE ALL FILES FROM DOC DIR
        let fileManager = FileManager.default
        let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        let documentsPath = documentsUrl.path
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
            print("All files in doc: \(fileNames)")
            for fileName in fileNames {
                if (fileName.hasSuffix(".dat")) {
                    let filePathName = "\(documentsPath)/\(fileName)"
                    try fileManager.removeItem(atPath: filePathName)
                }
            }
            let files = try fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
            print("Files in doc after deleting: \(files)")
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        let deviceToken = UserDefaults.standard.object(forKey: "VW.Consumer.deviceToken") as? String
        
        // REMOVE UserDefaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(deviceToken, forKey: "VW.Consumer.deviceToken")
        
        // REDIRECT TO FIRST VC
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let navController = secondSB.instantiateViewController(withIdentifier: "KipleNC")
        appDelegate?.window?.rootViewController = navController
        appDelegate?.window?.makeKeyAndVisible()
        
    }
}
