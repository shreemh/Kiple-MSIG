//
//  MenuVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 28/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class MenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var retryCount: Int = 0
    var isFinished : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        getUnreadAlertsCount()
        getUnreadNotificationsCount()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setTableView() {
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        self.view.frame = CGRect(x: 0, y: 0, width: (2 * UIScreen.main.bounds.width) / 3, height: UIScreen.main.bounds.height)
    }

    override func viewWillAppear(_ animated: Bool) {
        isFinished = false
        // OBD and OBDless
        tableView.reloadData()
        fetchDataFromFile()
    }
    
    func getUnreadAlertsCount() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getAlerts + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                if let response = response as? [String : Any], let responseObj = response["data"] as? [String : Any], let count = responseObj["unread_count"] as? Int {
                    Model.shared.unreadAlertsCount = count
                    if self.isFinished {
                        self.tableView.reloadData()
                    }
                    self.isFinished = true
                } else if let res = response as? [String : Any], let responseObj = res["error"] as? [String : Any], let error =  responseObj["error"] as? String {
                    if error == ErrorsFromAPI.tokenError.rawValue {
                        // CALL SUBSCRIPTION API
                        Utility.checkSubscription(viewController: self)
                    } else {
                        Utility.storeStaticDataToFile(fileName: ErrorMsgs.serverError, rawData: responseObj)
                    }
                }
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }
    
    func getUnreadNotificationsCount() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getNotifications + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                if let responseObj = response as? [String : Any], let result = responseObj["data"] as? [String : Any], let count = result["unread_count"] as? Int {
                    Model.shared.unreadNotificationsCount = count
                    if self.isFinished {
                        self.tableView.reloadData()
                    }
                    self.isFinished = true
                } else if let res = response as? [String : Any], let responseObj = res["error"] as? [String : Any], let error =  responseObj["error"] as? String {
                    if error == ErrorsFromAPI.tokenError.rawValue {
                        // CALL SUBSCRIPTION API
                        Utility.checkSubscription(viewController: self)
                    } else {
                        Utility.storeStaticDataToFile(fileName: ErrorMsgs.serverError, rawData: responseObj)
                    }
                } else {}
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }

    // MARK: - TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  Menu.menuTitles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profileCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as UITableViewCell!
        profileCell.selectionStyle = .none
        let menuCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as UITableViewCell!
        menuCell.selectionStyle = .none
//        if indexPath.row == 0 {
//            //Adarsh - profile API
//            let name = profileCell.viewWithTag(2) as? UILabel
//            let model = profileCell.viewWithTag(3) as? UILabel
//            let names = Model.shared.profileDict["name"]
//            let email = Model.shared.carModelDict[0]["value"]
//            name?.text = names
//            model?.text = email
//            return profileCell
//        }
        
        let title = menuCell.viewWithTag(1) as? UILabel
        let notificationsCount = menuCell.viewWithTag(2) as? UILabel
        title?.text = Menu.menuTitles[indexPath.row]
        notificationsCount?.isHidden = true
        if (indexPath.row == 2) {
          
            let accountType = Utility.getLoginMode()
            if accountType == "OBDless" {
                  // DRIVE AND TRACK
                title?.text = "Drive And Track"
            } else {
                 // CAR STATUS + ALERTS
                if Model.shared.unreadAlertsCount > 0 {
                    notificationsCount?.isHidden = false
                    notificationsCount?.text = String(Model.shared.unreadAlertsCount)
                }
            }
        } else if indexPath.row == 4, Model.shared.unreadNotificationsCount > 0 {
            notificationsCount?.isHidden = false
            notificationsCount?.text = String(Model.shared.unreadNotificationsCount)
        }
        return menuCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0, 1, 2, 5:
            // HOME, TRIPS, CAR STATUS AND SETTINGS
            let selectedIndex = indexPath.row != 5 ? indexPath.row : 3
            if let tabBarVC = revealViewController().frontViewController as? TabBarController {
               tabBarVC.selectedIndex = selectedIndex
            } else {
                if let tabBarVC = mainSB.instantiateViewController(withIdentifier: StoryBoardVC.tabBar) as? TabBarController {
                    revealViewController().setFront(tabBarVC, animated: true)
                    tabBarVC.selectedIndex = selectedIndex
                }
            }
            break
        case 3:
            // EMERGENCY
            if let emergencyNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.emergency) as? UINavigationController {
                revealViewController().setFront(emergencyNC, animated: true)
            }
            print("EMERGENCY")
            break
//        case 4:
//            // IN CAR WIFI
//            if let inCarWifiNC = secondSB.instantiateViewController(withIdentifier: StoryBoardNC.inCarWifi) as? UINavigationController {
//                revealViewController().setFront(inCarWifiNC, animated: true)
//            }
//            print("IN CAR WIFI")
//            break
        case 4:
            // ALERTS
            if let notificationsNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.alerts) as? UINavigationController {
                revealViewController().setFront(notificationsNC, animated: true)
            }
            print("ALERTS")
            break
//        case 6:
//            // SUPPORT
//            if let supportNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.support) as? UINavigationController {
//                revealViewController().setFront(supportNC, animated: true)
//            }
//            break
        default:
            print("Profile Cell")
            return
        }
        
        // ********** //
        // OLD CODE
        
//        switch indexPath.row {
//        case 1:
//            // DASHBOARD
//            if let dashboardNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.dashBoard) as? UINavigationController {
//                revealViewController().setFront(dashboardNC, animated: true)
//                revealViewController().frontViewController = dashboardNC
//            }
//
//            // TabBarVC
//
//
//            print("DASHBOARD")
//            break
//        case 2:
//            // TRIP
//            if let tripHistoryNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.trip) as? UINavigationController {
//                revealViewController().setFront(tripHistoryNC, animated: true)
//            }
//            print("TRIP")
//            break
//        case 3:
//            // CAR
//            if let carStatusNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.car) as? UINavigationController {
//                revealViewController().setFront(carStatusNC, animated: true)
//            }
//            print("CAR")
//            break
//        case 4:
//            // EMERGENCY
//            if let emergencyNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.emergency) as? UINavigationController {
//                revealViewController().setFront(emergencyNC, animated: true)
//            }
//            print("EMERGENCY")
//            break
//        case 5:
//            // IN CAR WIFI
//            if let inCarWifiNC = secondSB.instantiateViewController(withIdentifier: StoryBoardNC.inCarWifi) as? UINavigationController {
//                revealViewController().setFront(inCarWifiNC, animated: true)
//            }
//            print("IN CAR WIFI")
//
//            break
//        case 6:
//            // ALERTS
//            if let notificationsNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.alerts) as? UINavigationController {
//                revealViewController().setFront(notificationsNC, animated: true)
//            }
//            print("ALERTS")
//            break
//        case 7:
//            // SETTINGS
//            if let settingsNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.settings) as? UINavigationController {
//                revealViewController().setFront(settingsNC, animated: true)
//            }
//            break
//        case 8:
//            // SUPPORT
//            if let supportNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.support) as? UINavigationController {
//                revealViewController().setFront(supportNC, animated: true)
//            }
//            break
//
//        default:
//            print("Profile Cell")
//            return
//        }
        if revealViewController() != nil {
            revealViewController().revealToggle(animated: true)
        }
    }
    
    // shreeeee not using this method
    func changeTabBarItem(selectedTab : Int) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let parentViewControllers = appDelegate?.window?.rootViewController?.childViewControllers
        for revealVC in parentViewControllers! {
            if let tabBarVC = revealVC as? TabBarController {
                tabBarVC.selectedIndex = selectedTab
            }
        }
    }

    func fetchDataFromFile() {
        // FETCH USER INFO FROM FILE
        let storedData = Utility.readFromFile(fileName: FileNames.userInfo.rawValue)
        if let status = storedData["status"] as? String, status == "OK", let userInfo = storedData["data"] as? [String : Any] {
            assignValues(rawData: userInfo)
        } else {
            // STATUS == ERROR OR NO DATA - CALL API
            getUserInfo()
        }
//        // FETCH CAR STATUS FROM FILE
//        let storedData2 = Utility.readFromFile(fileName: FileNames.vehicleInfo.rawValue)
//        if let status = storedData2["status"] as? String, status == "OK", let vehicleInfo = storedData2["data"] as? [String : Any] {
//            guard let modelName = vehicleInfo["model"] as? String, let driverName = vehicleInfo["driver_name"] as? String else {
//                return
//            }
//            Model.shared.carModelDict[0]["value"] = modelName
//            Model.shared.profileDict["name"] = driverName
//            self.tableView.reloadData()
//        } else {
//            getVehicleInfo()
//        }
    }
    
    func assignValues(rawData : [String : Any]) {
        if let _timeZone = rawData["time_zone"] as? String {
            Model.shared.timeZone = _timeZone
        }
        Utility.storeStaticDataToFile(fileName: FileNames.selectedTimeZone.rawValue, rawData: ["timezone" : Model.shared.timeZone])
        self.tableView.reloadData()
    }
    
    func getVehicleInfo() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getVehicleInfo + "?"
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
                // STORE TRIPS BASED ON SELECTED MONTH
                DispatchQueue.global(qos: .background).async {
                    // UPDATE TO DB
                    Utility.storeStaticDataToFile(fileName: FileNames.vehicleInfo.rawValue, rawData: responseObj)
                }
                guard let modelName = responseObj["model"] as? String, let driverName = responseObj["driver_name"] as? String else {
                    return
                }
                Model.shared.carModelDict[0]["value"] = modelName
                Model.shared.profileDict["name"] = driverName
                self.tableView.reloadData()
                
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            // NO INTERNET CONNECTION
        }
    }

    // MARK: - API
    func getUserInfo() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getAccountInfo + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                guard let res = response as? [String : Any], let responseObj = res["data"] as? [String : Any] else {
                    self.assignValues(rawData: [:])
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
                // STORE TRIPS BASED ON SELECTED MONTH
                DispatchQueue.global(qos: .background).async {
                    // UPDATE TRIPS ARRAY TO DB
                    Utility.storeStaticDataToFile(fileName: FileNames.userInfo.rawValue, rawData: responseObj)
                }
                self.assignValues(rawData: responseObj)
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            // NO INTERNET CONNECTION
            // // FETCH USER INFO FROM FILE
            let storedData = Utility.readFromFile(fileName: FileNames.userInfo.rawValue)
            // CHECK TRIPS FOR THE SELECTED MONTH
            guard let status = storedData["status"] as? String, status == "OK", let userInfoDict = storedData["data"] as? [String : Any] else {
                self.assignValues(rawData: [:])
                return
            }
            self.assignValues(rawData: userInfoDict)
        }
    }
    // MARK: - UIBUTTON ACTIONS
    @IBAction func logoutBtnCall(_ sender: Any) {
        
        let alertController = UIAlertController(title: "LOG OUT", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Log Out", style: .default, handler: { _ in
            self.okAction()
        })
        alertController.addAction(defaultAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func okAction() {
        guard retryCount <= 1 else {
            return
        }
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
                        self.retryCount = self.retryCount + 1
                        self.okAction()
                        Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                        return
                    }
                    self.clearLocaldata()
                    
                }) { (error) in
                    print("error *** \(error)")
                    // TRY ONE MORE TIME
                    self.retryCount = self.retryCount + 1
                    self.okAction()
                }
            } else {
                // NO DEVICE TOKEN
                clearLocaldata()
            }
        } else {
            print("internetConnectMsg -- Update device token")
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
