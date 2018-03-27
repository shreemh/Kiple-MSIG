//
//  SignInVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 27/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import SWRevealViewController
import NVActivityIndicatorView
import Moscapsule
import Firebase

class SignInVC: UIViewController, NVActivityIndicatorViewable {
    enum SignInError : Error {
        case emptyEmail
        case emptyPassword
        case invalidEmail
        case signInError
        case serverError
    }
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    var flag: Bool = false
    var retryCount: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        emailText.text = "testsubscription@yopmail.com"
//        emailText.text = "shree@yopmail.com"
//        passwordText.text = "shree123"

//       emailText.text = "steven.kok@atilze.com"
//       passwordText.text = "kiplepass6"
        
//        emailText.text = "kirrukanna@hotmail.com"
//        passwordText.text = "password"
//
//        emailText.text = "shree@yopmail.com"
//        passwordText.text = "shree123"

        // AFTER ACCOUNT ACTIVATION
      //  emailText.text = Utility.getEmail()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        Model.shared.isFromForgotPW = false
        navigationController?.navigationBar.isHidden = true
        navigationItem.hidesBackButton = true
        // NAV TITLE
        Utility.setTransparentNavigationBar(navigationController: navigationController)
        navigationItem.titleView = Utility.getKipleCarAttributedLabel()
    }

    override func viewWillLayoutSubviews() {
//        Utility.setTransparentNavigationBar(navigationController: navigationController)
//        navigationItem.titleView = Utility.getKipleCarAttributedLabel()
    }
    // MARK: - UIBUTTON ACTIONS
    @IBAction func nextBtnCall(_ sender: Any) {
        do {
            try signInValidation()
        } catch SignInError.emptyEmail {
            Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.enterEmail, viewController: self)
        } catch SignInError.emptyPassword {
            Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.enterPassword, viewController: self)
        } catch SignInError.invalidEmail {
            Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.invalidEmail, viewController: self)
        } catch SignInError.signInError {
            Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.signInError, viewController: self)
        } catch {
            print(error)
        }
    }
    
    @IBAction func forgotPasswordBtnCall(_ sender: Any) {
        Analytics.logEvent("forgot_password", parameters: nil)
        Model.shared.isFromForgotPW = true
    }
    // MARK: - VALIDATIONS
    func signInValidation() throws {
        guard emailText.text?.characters.count != 0 else {
            throw SignInError.emptyEmail
        }
        guard passwordText.text?.characters.count != 0 else {
            throw SignInError.emptyPassword
        }
        guard validateEmail(email: emailText.text) else {
            throw SignInError.invalidEmail
        }
        signInAPICall()
    }
    
    func signInAPICall() {
        if Utility.isConnectedToNetwork() {
            startAnimating(CGSize(width: 30, height: 30), message: "")
            //base url and api end point
            let logInURL = Constants.ServerAddress.baseURL + Constants.APIEndPoints.login
            let params: [String : Any] = ["grant_type" : GrandTypes.password, "client_id" : "3", "client_secret" : clientSecret, "username" : emailText.text ?? "", "password" : passwordText.text ?? "", "scope" : ""]
            networkManager.postMethod(logInURL, params: params, success: { (response) in
                self.stopAnimating()
                if let res = response as? [String: Any], let jsonResponse = res["data"] as? [String: Any] {
                    guard let accessToken = jsonResponse["access_token"] as? String, let refreshToken = jsonResponse["refresh_token"] as? String else {
                        Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.serverError, viewController: self)
                        return
                    }
                    UserDefaults.standard.set(accessToken, forKey: "VW.Consumer.Token")
                    UserDefaults.standard.set((self.emailText.text ?? ""), forKey: "VW.Consumer.Email")
                    UserDefaults.standard.set(refreshToken, forKey: "VW.Consumer.refreshToken")
                    // REFRESH TOKEN
                    // STORE CURRENT TIME IN UserDefaults
                    let currentTime = Date()
                    UserDefaults.standard.set(currentTime, forKey: "VW.Consumer.refreshTime")
                    // SCHEDULE TIMER
                    timerForRefreshToken = Timer.scheduledTimer(timeInterval: refreshTokenTime, target: Utility(), selector: #selector(Utility.refreshTokenMethod), userInfo: nil, repeats: false)
                    DispatchQueue.global(qos: .background).async {
                        // UPDATE DEVICE TOKEN
                        self.updateDeviceToken()
                        self.getTimeZones()
                    }
                    // AUTO REFRESH
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 120.0, execute: {
//                        Utility.refreshDashBoard()
//                    })
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 240.0, execute: {
//                        Utility.refreshTrips()
//                    })
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 360.0, execute: {
//                        Utility.refreshNotifications()
//                    })
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 480.0, execute: {
//                        Utility.refreshSettings()
//                    })
                    // STORE TIMEZONE AND MOVE TO NEXT SCREEN
                    self.getDriverTimeZone()
                    self.getLoginMode()
                    
                } else if let res = response as? [String: Any], let errorData = res["error"] as? [String : Any], let errorString = errorData["error"] as? String, errorString == ErrorsFromAPI.invalidCredentials.rawValue {
                    self.checkSubscription()
                } else {
                    guard let res = response as? [String: Any], let errorData = res["error"] as? [String : Any], let message = errorData["message"] as? String else {
                        Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                        return
                    }
                    Utility.showAlert(title: APPNAME, message: message, viewController: self)
                }
                
            }, failure: { (error) in
                print("Error *** \(error)")
                self.stopAnimating()
                Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.serverError, viewController: self)
            })
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }
    
    func checkSubscription() {
        if Utility.isConnectedToNetwork() {
            startAnimating(CGSize(width: 30, height: 30), message: "")
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.checkSubscription + emailText.text! + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                self.stopAnimating()
                
                guard let result = response as? [String : Any], result["error"] != nil else {
                   Utility.showAlert(title: APPNAME, message: "Wrong password", viewController: self)
                    return
                }
                if let result = response as? [String : Any], let resultData = result["error"] as? [String : Any], let errors = resultData["errors"] as? [String : Any], let firstError = errors.values.first as? [Any], let msg = firstError.first as? String {
                    Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                } else if let result = response as? [String : Any], let resultData = result["error"] as? [String : Any], let msg = resultData["message"] as? String {
                    Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                } else {
                    Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                }
            }) { (error) in
                print("error *** \(error)")
                Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
            }
        } else {
            // NO INTERNET CONNECTION
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }
    
    func updateDeviceToken() {
        guard retryCount <= 1 else {
            return
        }
        if Utility.isConnectedToNetwork() {
            // INTERNET CONNECTION AVAILABLE
            let deviceToken  = UserDefaults.standard.object(forKey: "VW.Consumer.deviceToken")
            let params: [String : Any] = ["device_token" : deviceToken ?? "", "device_type" : "iOS"]
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.registerDeviceToken + "?"
            networkManager.postMethod(url, params: params, success: { (response) in
                if let resultDict = response as? [String : Any], resultDict["error"] == nil {
                    print("SUCCESS")
                } else {
                    print("FAILED")
                    // TRY ONE MORE TIME
                    DispatchQueue.global(qos: .background).async {
                        self.retryCount = self.retryCount + 1
                        self.updateDeviceToken()
                    }
                }
            }) { (error) in
                print("error *** \(error)")
                // TRY ONE MORE TIME
                DispatchQueue.global(qos: .background).async {
                    self.retryCount =  self.retryCount + 1
                    self.updateDeviceToken()
                }
            }
        } else {
            print("internetConnectMsg -- Update device token")
        }
    }
    // MARK: - API
    func getDriverTimeZone() {
        if Utility.isConnectedToNetwork() {
            startAnimating(CGSize(width: 30, height: 30), message: "")
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getAccountInfo + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                self.stopAnimating()
                guard let res = response as? [String : Any], let responseObj = res["data"] as? [String : Any] else {
                    Model.shared.timeZone = "Asia/Kuala_Lumpur"
                    if self.flag {
                        self.stopAnimating()
                        let dashBoardVC = mainSB.instantiateViewController(withIdentifier: "SWRevealVC")
                        self.present(dashBoardVC, animated: true)
                    }
                    self.flag = true
                    return
                }
                if let timeZone = responseObj["time_zone"] as? String {
                    Model.shared.timeZone = timeZone
                    Utility.storeStaticDataToFile(fileName: FileNames.selectedTimeZone.rawValue, rawData: ["timezone" : Model.shared.timeZone])
                } else {
                    Model.shared.timeZone = "Asia/Kuala_Lumpur"
                }
                if self.flag {
                    self.stopAnimating()
                    let dashBoardVC = mainSB.instantiateViewController(withIdentifier: "SWRevealVC")
                    self.present(dashBoardVC, animated: true)
                }
                self.flag = true
            }) { (error) in
                self.stopAnimating()
                print("error *** \(error)")
            }
        } else {
            Utility.showAlert(title: APPNAME, message: "No Internet", viewController: self)
        }
    }
    
    func getLoginMode() {
        if Utility.isConnectedToNetwork() {
            // INTERNET CONNECTION AVAILABLE
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getLoginMode + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                if let res = response as? [String : Any], let successData = res["data"] as? [String : Any], let mode = successData["mode"] as? String, let type = successData["type"] as? String {
                    print("SUCCESS")
                    UserDefaults.standard.set(mode, forKey: "VW.Consumer.loginMode")
                    UserDefaults.standard.set(type, forKey: "VW.Consumer.loginType")
                    guard mode == "OBDless" else {
                        if self.flag {
                            self.stopAnimating()
                            let dashBoardVC = mainSB.instantiateViewController(withIdentifier: "SWRevealVC")
                            self.present(dashBoardVC, animated: true)
                        }
                        self.flag = true
                        return
                    }
                    if type.lowercased() == "auto" {
                        Model.shared.isAutoTrackingMode = true
                    } else {
                        Model.shared.isAutoTrackingMode = false
                    }
                    
                    // CALL MQTT SERVER INFO
                    let device_id: String = successData["device_id"] as? String ?? ""
                    UserDefaults.standard.set(device_id, forKey: "VW.Consumer.deviceID")
                    self.getMQTTInfo()
                }
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            print(internetConnectMsg)
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
                    
                    if self.flag {
                        self.stopAnimating()
                        let dashBoardVC = mainSB.instantiateViewController(withIdentifier: "SWRevealVC")
                        self.present(dashBoardVC, animated: true)
                    }
                    self.flag = true
                }
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            print(internetConnectMsg)
        }
    }
    
    func getTimeZones() {
        guard retryCount <= 1 else {
            return
        }
        if Utility.isConnectedToNetwork() {
            // INTERNET CONNECTION AVAILABLE
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getTimeZones + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                
                if let response = response as? [String : Any], let resultArray = response["data"] as? [String] {
                    print("SUCCESS")
                    DispatchQueue.main.async {
                        // STORE TIMEZONES TO LOCAL DB
                        DispatchQueue.global(qos: .background).async {
                            Utility.storeStaticDataToFile(fileName: FileNames.timeZones.rawValue, rawData: ["timezones" : resultArray])
                        }
                    }
                } else if let resultDict = response as? [String : Any] {
                    print("FAILED")
                    // TRY ONE MORE TIME
                    DispatchQueue.global(qos: .background).async {
                        self.retryCount = self.retryCount + 1
                        self.getTimeZones()
                    }
                }
            }) { (error) in
                print("error *** \(error)")
                // TRY ONE MORE TIME
                DispatchQueue.global(qos: .background).async {
                    self.retryCount =  self.retryCount + 1
                    self.getTimeZones()
                }
            }
        } else {
            print(internetConnectMsg)
        }
    }
    
    @IBAction func activeNowBtnCall(_ sender: Any) {
  
      //  Analytics.logEvent("Activate_Now", parameters: ["type" : "OBDLess"])
    
    }
    func validateEmail(email: String?) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
