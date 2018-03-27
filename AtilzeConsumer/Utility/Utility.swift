//
//  Utility.swift
//  AtilzeConsumer
//
//  Created by Sreejith on 24/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import SystemConfiguration
import NVActivityIndicatorView

class Utility: NSObject {

    class func getLoader()-> NVActivityIndicatorView {
        return NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), type: .ballRotateChase, color: .red, padding: NVActivityIndicatorView.DEFAULT_PADDING)
    }
    
    class func showAlert(title: String = "", message: String, viewController: UIViewController ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    class func getKipleCarAttributedLabel() -> UILabel {
        let titleLabel = UILabel()
        let attributed = NSMutableAttributedString(string: "ConnectedCar")
        let font = UIFont(name: "Montserrat-Regular", size: 18)
        attributed.addAttributes([NSFontAttributeName : font ?? UIFont()], range: NSRange(location: 0, length: attributed.length))
        attributed.addAttributes([NSForegroundColorAttributeName: UIColor(hexString: "#00A3EA")], range: NSRange(location: 0, length: 9))
        attributed.addAttributes([NSForegroundColorAttributeName: UIColor(hexString: "#A4B1B7")], range: NSRange(location: 9, length: 3))
        titleLabel.attributedText = attributed
        titleLabel.sizeToFit()
        return titleLabel
    }
    class func setTransparentNavigationBar(navigationController: UINavigationController?) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
    }
    
//    class func attributedText(completeText: String, primaryText: String, secondaryText: String) -> NSMutableAttributedString {
//        let attributed = NSMutableAttributedString(string: completeText)
//        let primaryTextFont = UIFont(name: "Montserrat-Bold", size: 40)
//        let font = UIFont(name: "Montserrat-Bold", size: 14)
//        attributed.addAttributes([NSFontAttributeName : primaryTextFont ?? UIFont()], range: NSRange(location: 0, length: primaryText.characters.count))
//        attributed.addAttributes([NSFontAttributeName : font ?? UIFont()], range: NSRange(location: primaryText.characters.count, length: attributed.length - primaryText.characters.count))
//        return attributed
//    }
//
    class func attributedText(completeText: String, primaryText: String, secondaryText: String) -> NSMutableAttributedString {
        let attributed = NSMutableAttributedString(string: completeText)
        let primaryTextFont = UIFont(name: "Montserrat-BoldItalic", size: 25)
        let font = UIFont(name: "Montserrat-BoldItalic", size: 14)
        attributed.addAttributes([NSFontAttributeName : primaryTextFont ?? UIFont()], range: NSRange(location: 0, length: primaryText.characters.count))
        attributed.addAttributes([NSFontAttributeName : font ?? UIFont()], range: NSRange(location: primaryText.characters.count, length: attributed.length - primaryText.characters.count))
        attributed.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: primaryText.characters.count, length: attributed.length - primaryText.characters.count))
        return attributed
    }
    
    class func getFormattedDate(date : String) -> String {
        let formatterTest = DateFormatter()
        formatterTest.dateStyle = .long
        formatterTest.timeStyle = .long
        formatterTest.dateFormat =  "ZZZ"
        let myDate = Date()
        formatterTest.timeZone = TimeZone(identifier: Model.shared.timeZone)
        let timeZoneSting  = formatterTest.string(from: myDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone(identifier: Model.shared.timeZone)
        let formattedDate:Date = formatter.date(from: date + " " + timeZoneSting) ?? Date()
        var formattedDateInString: String
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: Model.shared.timeZone)!
        if calendar.isDateInToday(formattedDate) {
            formatter.dateFormat = "hh:mma"
            formattedDateInString = formatter.string(from: formattedDate)
            return "Today, \(formattedDateInString)"
        } else if Calendar.current.isDateInYesterday(formattedDate) {
            formatter.dateFormat = "hh:mma"
            formattedDateInString = formatter.string(from: formattedDate)
            return "Yesterday, \(formattedDateInString)"
        } else {
            formatter.dateFormat = "dd MMM, hh:mma"
            formattedDateInString = formatter.string(from: formattedDate)
            return formattedDateInString
        }
    }
    
    // TRIPS
    class func getTripDate(date : Date, isStartDate : Bool) -> String {
        // shreeeeee
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: Model.shared.timeZone)
        formatter.dateFormat = "yyyy-MM-dd"
        let formattedDate : String = formatter.string(from: date)
        let finalDateString = isStartDate ? formattedDate + "%2000:00:00" : formattedDate + "%2023:59:59"
        return finalDateString
    }
    
    class func getHomeScreenDate(date : Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: Model.shared.timeZone)
        formatter.dateFormat = "dd MMM"
        let formattedDate : String = formatter.string(from: date)
        return formattedDate
    }
    
    
//    class func getTimeString(dateString : String) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//        let formattedDate:Date = formatter.date(from: dateString) ?? Date()
//        var formattedTimeString: String
//        formatter.dateFormat = "hh:mma"
//        formattedTimeString = formatter.string(from: formattedDate)
//        return "Today, \(formattedTimeString)"
//    }
    
    class func getOnlyTime(dateString : String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate:Date = formatter.date(from: dateString) ?? Date()
        var formattedTimeString: String
        formatter.dateFormat = "hh:mm:ssa"
        formattedTimeString = formatter.string(from: formattedDate)
        return formattedTimeString
    }
    
//    class func getDateString(dateString : String) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//        let formattedDate:Date = formatter.date(from: dateString) ?? Date()
//        var formattedDateString: String
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd MMMM, yyyy"
//        formattedDateString = dateFormatter.string(from: formattedDate)
//        return formattedDateString
//    }
    
    class func getcurrentDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let dateString = formatter.string(from: date)
        return dateString
    }
    
//    class func convertStringToDate(date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//        formatter.timeZone = TimeZone(identifier: "UTC")
//        let dateString = formatter.string(from: date)
//        return dateString
//    }
    
    
    /// give store mailid
    ///
    /// - Returns: mail id
    class func getEmail() -> String {
        let email = UserDefaults.standard.object(forKey: "VW.Consumer.Email") as? String ?? ""
        return email
    }
    
    class func getToken() -> String {
        let accessToken = UserDefaults.standard.object(forKey: "VW.Consumer.Token") as? String ?? ""
        guard accessToken.characters.count > 0 else {
           return ""
        }
        return "Bearer \(accessToken)"
    }
    
    class func getRefreshToken() -> String {
        let refreshToken = UserDefaults.standard.object(forKey: "VW.Consumer.refreshToken") as? String ?? ""
        guard refreshToken.characters.count > 0 else {
            return ""
        }
        return refreshToken
    }
    
    class func getMQTTUserName() -> String {
        guard let mqttDict = UserDefaults.standard.object(forKey: "VW.Consumer.MQTTInfo") as? [String : Any], let userName = mqttDict["username"] as? String else {
            return ""
        }
        return userName
    }
   
    
    // MARK: - REFRESH
    class func refreshTokenMethod() {
        if Utility.isConnectedToNetwork() {
        //base url and api end point
        let logInURL = Constants.ServerAddress.baseURL + Constants.APIEndPoints.login
        let params: [String : Any] = ["grant_type" : GrandTypes.refreshToken, "client_id" : "3", "client_secret" : clientSecret, "refresh_token" : getRefreshToken(), "scope" : ""]
        networkManager.postMethod(logInURL, params: params, success: { (response) in
            if let res = response as? [String: Any], let jsonResponse = res["data"] as? [String : Any], let refreshToken = jsonResponse["refresh_token"] as? String {
                
                guard let accessToken = jsonResponse["access_token"] as? String else {
                    return
                }
                UserDefaults.standard.set(accessToken, forKey: "VW.Consumer.Token")
                UserDefaults.standard.set(refreshToken, forKey: "VW.Consumer.refreshToken")
                let currentTime = Date()
                UserDefaults.standard.set(currentTime, forKey: "VW.Consumer.refreshTime")
                timerForRefreshToken = Timer.scheduledTimer(timeInterval: refreshTokenTime, target: self, selector: #selector(self.refreshTokenMethod), userInfo: nil, repeats: false)
            }
        }, failure: { (error) in
            print("Error *** \(error)")
        })
        } else {
            print("No internet connection -- refresh token")
        }
    }
    
    class func refreshDashBoard() {
        print("refreshDashBoard called")
        // SCHEDULE TIMER
        timerForDashBoardRefresh = Timer.scheduledTimer(timeInterval: refreshTime, target: Utility.self, selector: #selector(Utility.refreshDB), userInfo: ["vc":"dashboard"], repeats: true)
    }
    
    class func refreshTrips() {
        print("refreshTrips called")
        // SCHEDULE TIMER
        timerForTripsRefresh = Timer.scheduledTimer(timeInterval: refreshTime, target: Utility.self, selector: #selector(Utility.refreshTripsHistory), userInfo: ["vc":"trips"], repeats: true)
        
    }
    
    class func refreshNotifications() {
        print("refreshNotifications called")
        // SCHEDULE TIMER
        timerForNotificationsRefresh = Timer.scheduledTimer(timeInterval: refreshTime, target: Utility.self, selector: #selector(Utility.refreshNoti), userInfo: ["vc":"notifications"], repeats: true)
    }
    
    class func refreshAlerts() {
        print("refreshAlerts called")
        // SCHEDULE TIMER
        timerForAlertsRefresh = Timer.scheduledTimer(timeInterval: refreshTime, target: Utility.self, selector: #selector(Utility.refreshCarStatusAlerts), userInfo: ["vc":"alerts"], repeats: true)
    }
    
    class func refreshSettings() {
        print("refreshSettings called")
        // SCHEDULE TIMER
        timerForSetingsRefresh = Timer.scheduledTimer(timeInterval: refreshTimeForStaticData, target: Utility.self, selector: #selector(Utility.refreshSettingsAPI), userInfo: ["vc":"settings"], repeats: true)
    }

    class func refreshCarStatusAlerts() {
        let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getAlerts + "?"
        networkManager.getMethod(url, params: nil, success: { (response) in
            if let response = response as? [String : Any], let responseObj = response["data"] as? [String : Any] {
                DispatchQueue.global(qos: .background).async {
                    // UPDATE TO DB
                    Utility.storeStaticDataToFile(fileName: FileNames.alerts.rawValue, rawData: responseObj)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshAlerts"), object: nil)
                }
            } else {}
        }) { (error) in
            print("error *** \(error)")
        }
    }
    
    class func refreshNoti() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getNotifications + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                if let responseObj = response as? [String : Any], let result = responseObj["data"] as? [ String : Any] {
                    DispatchQueue.global(qos: .background).async {
                        // UPDATE TO DB
                        Utility.storeStaticDataToFile(fileName: FileNames.notifications.rawValue, rawData: result)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshNotifications"), object: nil)
                }
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            // NO INTERNET CONNECTION
        }
    }
    
    class func refreshSettingsAPI(timer: Timer) {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getVehicleInfo + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                guard let response = response as? [String : Any], let responseObj = response["data"] as? [String : Any] else {
                    return
                }
                Model.shared.carModelDict[0]["value"] = responseObj["model"] as? String
                // STORE TRIPS BASED ON SELECTED MONTH
                DispatchQueue.global(qos: .background).async {
                    // UPDATE TO DB
                    Utility.storeStaticDataToFile(fileName: FileNames.vehicleInfo.rawValue, rawData: responseObj)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshSettings"), object: nil)
                }
            }) { (error) in
                print("error *** \(error)")
            }
            
            let url2 = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getAccountInfo + "?"
            networkManager.getMethod(url2, params: nil, success: { (response) in
                guard let response = response as? [String : Any], let responseObj = response["data"] as? [String : Any] else {
                    return
                }
                // STORE TRIPS BASED ON SELECTED MONTH
                DispatchQueue.global(qos: .background).async {
                    // UPDATE TO DB
                    Utility.storeStaticDataToFile(fileName: FileNames.userInfo.rawValue, rawData: responseObj)
                }
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            // NO INTERNET CONNECTION
        }
    }
    
    class func refreshDB(timer: Timer) {
        var finished : Bool = Bool()
        let from30DaysCal: Date! = Calendar.current.date(byAdding: .day, value: -29, to: Date())
        let today = Date()
        let toDateTime = getTripDate(date: today, isStartDate: false)
        let fromDateTime = getTripDate(date: from30DaysCal, isStartDate: true)
        if Utility.isConnectedToNetwork() {
            // TRIPS
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getTrips + "?" + "from_datetime=\(fromDateTime)&to_datetime=\(toDateTime)"
            networkManager.getMethod(url, params: nil, success: { (response) in
                if let responseData = response as? [[String: Any]] {
                    guard responseData.count > 0 else {
                        // NO TRIPS AVAILABLE FOR THE SELECTED MONTH
                        DispatchQueue.global(qos: .background).async {
                            // UPDATE AN EMPTY ARRAY TO DB
                            Utility.storeToFile(fileName: FileNames.dashBoard.rawValue, updateStatus: false, trips: responseData, date : fromDateTime)
                            
                            guard finished else {
                                finished = true
                                return
                            }
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshDB"), object: nil)
                        }
                        return
                    }
                    // STORE 30 DAYS TRIPS
                    DispatchQueue.global(qos: .background).async {
                        // UPDATE TRIPS ARRAY TO DB
                        Utility.storeToFile(fileName: FileNames.dashBoard.rawValue, updateStatus: true, trips: responseData, date : fromDateTime)
                        guard finished else {
                            finished = true
                            return
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshDB"), object: nil)
                    }
                }
            }) { (error) in
                print("error *** \(error)")
            }
        
            // CAR STATUS
            let url2 = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getDeviceStatus + "?"
            networkManager.getMethod(url2, params: nil, success: { (response) in
                guard let response = response as? [String : Any], let responseObj = response["data"] as? [String : Any] else {
                    return
                }
                Model.shared.isBatteryStatusResolved = false
                // STORE TRIPS BASED ON SELECTED MONTH
                DispatchQueue.global(qos: .background).async {
                    // UPDATE TO DB
                    Utility.storeStaticDataToFile(fileName: FileNames.carStatus.rawValue, rawData: responseObj)
                    guard finished else {
                        finished = true
                        return
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshDB"), object: nil)
                }
                
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            // NO INTERNET CONNECTION
        }
        
    }
    
    class func refreshTripsHistory(timer: Timer) {
        // DATE
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())
        let dateComponents = DateComponents(year: year, month: month)
        let date : Date! = calendar.date(from: dateComponents)
        
        let range = calendar.range(of: .day, in: .month, for: date)
        let numDays: Int! = range?.count
        let monthString = String(month).characters.count == 1 ? "0" + String(month) : String(month)
        let startDateString = String(year) + "-\(monthString)-"  + "01" + "%2000:00:00"
        let endDateString = String(year) + "-\(monthString)-" + String(numDays) + "%2023:59:59"
        if Utility.isConnectedToNetwork() {
            // TRIPS
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getTrips + "?" + "from_datetime=\(startDateString)&to_datetime=\(endDateString)"
            networkManager.getMethod(url, params: nil, success: { (response) in
                if let responseData = response as? [[String: Any]] {
                    guard responseData.count > 0 else {
                        // NO TRIPS AVAILABLE FOR THE SELECTED MONTH
                        DispatchQueue.global(qos: .background).async {
                            // UPDATE AN EMPTY ARRAY TO DB
                            Utility.storeToFile(fileName: FileNames.trips.rawValue, updateStatus: false, trips: responseData, date : startDateString)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshTrips"), object: nil)
                        }
                        return
                    }
                    // STORE 30 DAYS TRIPS
                    DispatchQueue.global(qos: .background).async {
                        // UPDATE TRIPS ARRAY TO DB
                        Utility.storeToFile(fileName: FileNames.trips.rawValue, updateStatus: true, trips: responseData, date : startDateString)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshTrips"), object: nil)
                    }
                }
            }) { (error) in
                print("error *** \(error)")
            }
            
        }
    }
    
    class func checkSubscription(viewController : UIViewController) {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.checkSubscription + Utility.getEmail() + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                guard let response = response as? [String : Any], let errorDat = response["error"] as? [String : Any], let msg = errorDat["message"] as? String else {
                    return
                }
                let alertController = UIAlertController(title: "ERROR", message: msg, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Login Again", style: .default, handler: { _ in
                    self.logout()
                })
                alertController.addAction(defaultAction)
                viewController.present(alertController, animated: true, completion: nil)
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            // NO INTERNET CONNECTION
        }
    }
    
    class func clearTripData() {
        UserDefaults.standard.removeObject(forKey: "VW.Consumer.Start")
        UserDefaults.standard.removeObject(forKey: "VW.Consumer.GPSData")
        UserDefaults.standard.removeObject(forKey: "VW.Consumer.Incidents")
        UserDefaults.standard.removeObject(forKey: "VW.Consumer.Stop")
        UserDefaults.standard.removeObject(forKey: "VW.Consumer.Summary")
    }
    
    class func logout() {
        // STOP TIMER AS WE NO LONGER NEED TO REFRESH THE ACCESS TOKEN AND OTHER APIS
        timerForRefreshToken.invalidate()
        timerForTripsRefresh.invalidate()
        timerForSetingsRefresh.invalidate()
        timerForDashBoardRefresh.invalidate()
        timerForNotificationsRefresh.invalidate()
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
    
    // INTERNET CHECK
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability : SCNetworkReachability! = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
    // WRIRE DATA INTO FILE
    class func writeToFile(fileName: String, data : [String : Any]) {
        let filePath = getFileURL(fileName: fileName).path
        // write to file
        NSKeyedArchiver.archiveRootObject(data, toFile: filePath)
    }
    // READ DATA FROM FILE
    class func getFileURL(fileName: String) -> URL {
        let manager = FileManager.default
        let dirURL: URL! = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return dirURL.appendingPathComponent(fileName)
    }
    
    // READ FROM FILE
    class func readFromFile(fileName: String) -> [String: Any] {
        // read from file
        let filePath = getFileURL(fileName: fileName).path
        let dict = NSKeyedUnarchiver.unarchiveObject(withFile: filePath)
        
        guard dict != nil else {
            return noData
        }
        guard let _dict = dict as? [String : Any] else {
            return errorDict
        }
        return _dict
    }
    class func storeToFile(fileName: String, updateStatus: Bool, trips: [[String : Any]], date :  String) {
        var storedData = Utility.readFromFile(fileName: fileName)
        
        if let status = storedData["status"] as? String, status != "error" {
            if updateStatus {
                storedData["status"] = "OK"
            }
            storedData[date] = trips
            Utility.writeToFile(fileName: fileName, data: storedData)
        }
    
    }
    class func storeStaticDataToFile(fileName: String, rawData: [String : Any]) {
        var storedData : [String : Any]  = ["data" : rawData]
        storedData["status"] = "OK"
        Utility.writeToFile(fileName: fileName, data: storedData)
    }
    
    class func getLoginMode() -> String {
        let type = UserDefaults.standard.object(forKey: "VW.Consumer.loginMode") as? String ?? ""
        return type
    }
    
    class func getLoginType() -> String {
        let type = UserDefaults.standard.object(forKey: "VW.Consumer.loginType") as? String ?? ""
        return type
    }
    
    
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
