//
//  EmergencyVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 31/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import MapKit
import NVActivityIndicatorView
import CoreLocation
import Firebase

class EmergencyVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, LocationServiceDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var isFromDashBoard : Bool = false
    var isLocationAvailable : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        if !isFromDashBoard {
            // MENU
            if revealViewController() != nil {
                self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
                self.view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
            }
        } else {
            // FROM DASHBOARD
            navigationController?.navigationItem.backBarButtonItem?.title = ""
            navigationItem.leftBarButtonItem = nil
            navigationItem.hidesBackButton = false
        }
    }
    
    // MARK: - SETUP
    func setUpView() {
        // TABLE VIEW
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        getCurrentLocation()
        
        let storedData = Utility.readFromFile(fileName: FileNames.userInfo.rawValue)
        if let status = storedData["status"] as? String, status == "OK", let userInfo = storedData["data"] as? [String : Any] {
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
                self.tableView.reloadData()
                // STORE TRIPS BASED ON SELECTED MONTH
                DispatchQueue.global(qos: .background).async {
                    // UPDATE TRIPS ARRAY TO DB
                    Utility.storeStaticDataToFile(fileName: FileNames.userInfo.rawValue, rawData: responseObj)
                }
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            // NO INTERNET CONNECTION
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func menuBtnCall(_ sender: Any) {
        if revealViewController() != nil {
            revealViewController().revealToggle(animated: true)
        }
    }
    func getCurrentLocation() {
        startAnimating(CGSize(width: 30, height: 30), message: "Getting location")
        let trackingMode = Utility.getLoginMode()
        if trackingMode == "OBD" {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getCurrentLocationOfCar + "?"
            networkManager.getMethod(url, params: nil, success: {(response) in
                self.stopAnimating()
                print("Response:\(response ?? "")")
                self.stopAnimating()
                if let locationAddress = response as? [String:Any], let responseObj = locationAddress["data"] as? [String:Any] {
                    let lat = responseObj["latitude"] as? Double
                    let longitude = responseObj["longitude"] as? Double
                    self.longitude = longitude ?? 0.0
                    self.latitude = lat ?? 0.0
                    self.isLocationAvailable = true
                }
            }, failure: {(error) in
                self.stopAnimating()
                print("Error *** \(error)")
                Utility.showAlert(title: APPNAME, message: "Server Error!", viewController: self)
            })
            
        } else {
            locationSetUp()
        }
    }
    
    // MARK:- LOCATION
    func locationSetUp() {
        self.stopAnimating()
        if Model.shared.userLoc == nil {
            Model.shared.userLoc = UserLocation.init()
        }
        Model.shared.userLoc?.delegate = self
        
        self.isLocationAvailable = true
    }
    
    func enableLocationService() {
        let alertController = UIAlertController (title: "Location Sevices Disabled", message: "Please enable location services.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened iOS 10")
                    })
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(settingsUrl)
                    print("Settings opened")
                }
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.latitude = locations.last?.coordinate.latitude ?? 0.0
        self.longitude = locations.last?.coordinate.longitude ?? 0.0
        isLocationAvailable = true
        
    }
    
    // MARK: - LocationServiceDelegate
    func tracingLocation(currentLocation: CLLocation, GPSSignal : String) {
        self.latitude = currentLocation.coordinate.latitude
        self.longitude = currentLocation.coordinate.longitude
        isLocationAvailable = true
    }
    
    func tracingLocationDidFailWithError(error: NSError) {
        print("tracingLocationDidFailWithError TRIP TRACKING")
    }
    
    // MARK: - TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let panicCell = tableView.dequeueReusableCell(withIdentifier: "PanicCell") else {
            print("ERROR")
            fatalError()
        }
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") else {
            print("ERROR")
            fatalError()
        }
        guard let emergencyCell = tableView.dequeueReusableCell(withIdentifier: "EmergencyCell") else {
            print("ERROR")
            fatalError()
        }
        guard let addContactCell = tableView.dequeueReusableCell(withIdentifier: "AddEmergencyContactCell") else {
            print("ERROR")
            fatalError()
        }
        
        panicCell.selectionStyle = .none
        addContactCell.selectionStyle = .none
        headerCell.selectionStyle = .none
        emergencyCell.selectionStyle = .none
        let cellImage = panicCell.viewWithTag(2) as? UIImageView
        let title = panicCell.viewWithTag(3) as? UILabel
        let description = panicCell.viewWithTag(4) as? UILabel
        let cellButton = panicCell.viewWithTag(5) as? UIButton
        
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == 0 {
            cellImage?.image = UIImage(named: "SOS")
            title?.text = "Panic Button"
            title?.font = UIFont(name: "Montserrat-Regular", size: 24)
            description?.text = "In the event of an EMERGENCY, simply PRESS the panic button. We will receive your location and call you back"
            // cellButton?.setTitle("GET HELP", for: .normal)
            cellButton?.addTarget(self, action: #selector(panicConfirm), for: .touchUpInside)
            return panicCell
        } else if indexPath.row == 1 {
            cellImage?.image = UIImage(named: "RoadSideAssist")
            title?.text = "Roadside Assist"
            title?.font = UIFont(name: "Montserrat-Medium", size: 24)
            description?.text = "Car breakdown or accident? Request for help now."
            // cellButton?.setTitle("REQUEST HELP", for: .normal)
            cellButton?.addTarget(self, action: #selector(roadsideAssistConfirm), for: .touchUpInside)
            return panicCell
        } else if indexPath.row == lastRow {
            let title = emergencyCell.viewWithTag(10) as? UILabel
            let contactNo = emergencyCell.viewWithTag(2) as? UILabel
            if let name = Model.shared.profileDict["emergency_name"], let contact = Model.shared.profileDict["emergency_contact"], !name.isEmpty, !contact.isEmpty {
                title?.text = name
                contactNo?.text = contact
                return emergencyCell
            } else {
                let btn = addContactCell.viewWithTag(10) as? UIButton
                btn?.addTarget(self, action: #selector(addContact), for: .touchUpInside)
                return addContactCell
            }
        } else if indexPath.row == 2 {
            return headerCell
        } else {
            let title = emergencyCell.viewWithTag(10) as? UILabel
            let contactNo = emergencyCell.viewWithTag(2) as? UILabel
            title?.text = "Police / Ambulance"
            contactNo?.text = "999"
            return emergencyCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            self.call(number: 999)
        } else if indexPath.row == 4 {
            let digits = Model.shared.profileDict["emergency_contact"]!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            self.call(number: Int(digits)!)
        }
    }
    
    func call(number : Int) {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func addContact() {
        Analytics.logEvent("Add_Emergency_Contact", parameters: nil)
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
    
    func roadsideAssistConfirm(){
        let alertController = UIAlertController(title: APPNAME, message:  "This function is only for testing purposes", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.roadsideAssistBtnCall()
        })
        alertController.addAction(defaultAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func roadsideAssistBtnCall() {
        Analytics.logEvent("RSA_button", parameters: nil)
        if isLocationAvailable {
            guard let roadsideAssistVC = mainSB.instantiateViewController(withIdentifier: "RoadsideAssistVC") as? RoadsideAssistVC else {
                return
            }
            roadsideAssistVC.latitude = self.latitude
            roadsideAssistVC.longitude = self.longitude
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(roadsideAssistVC, animated: true)
        } else {
            Utility.showAlert(message: "Turn on the location services", viewController: self)
        }
    }
    
    func panicConfirm(){
        let alertController = UIAlertController(title: APPNAME, message:  "This function is only for testing purposes", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.panicBtnCall()
        })
        alertController.addAction(defaultAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func panicBtnCall() {
        Analytics.logEvent("Panic_Button", parameters: nil)
        if isLocationAvailable {
            if Utility.isConnectedToNetwork() {
                //base url and api end point
                let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.regEmergency
                let latString = String(self.latitude)
                let longString = String(self.longitude)
                let params: [String : Any] = ["type" : "panic_button", "latitude" : latString, "longitude" : longString]
                networkManager.postMethod(url, params: params, success: { (response) in
                    print("Res *** \(String(describing: response))")
                    if let res = response as? [String: Any], res["error"] == nil, let responseObj = res["data"] as? [String : Any] {
                        // Utility.showAlert(title: APPNAME, message: "Successfull", viewController: self)
                        guard let panicButtonDetailVC = mainSB.instantiateViewController(withIdentifier: "PanicButtonDetailVC") as? PanicButtonDetailVC else {
                            return
                        }
                        panicButtonDetailVC.requestID = responseObj["request_id"] as? Int ?? 0
                        let backItem = UIBarButtonItem()
                        backItem.title = ""
                        self.navigationItem.backBarButtonItem = backItem
                        self.navigationController?.pushViewController(panicButtonDetailVC, animated: true)
                        
                    } else if let response = response as? [String : Any], let responseObj = response["error"] as? [String : Any], let error =  responseObj["error"] as? String, let msg = responseObj["message"] as? String {
                        if error == ErrorsFromAPI.tokenError.rawValue {
                            // CALL SUBSCRIPTION API
                            Utility.checkSubscription(viewController: self)
                        } else {
                            Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
                        }
                    } else {
                        Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                    }
                }, failure: { (error) in
                    print("Error *** \(error)")
                    Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.serverError, viewController: self)
                })
            } else {
                Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
            }
        } else {
            Utility.showAlert(message: "Turn on the location services", viewController: self)
        }
    }
}

