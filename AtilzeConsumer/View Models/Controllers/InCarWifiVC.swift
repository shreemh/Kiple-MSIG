//
//  InCarWifiVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 02/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//
//{
//    "wifi_ssid": null,
//    "wifi_password": null
//}
import UIKit

class InCarWifiVC: UIViewController {
    
    //Key values
    enum WifiData:String {
        case wifiSsid = "wifi_ssid"
        case wifiPassword = "wifi_password"
    }
    
    // MARK: - OUTLETS
    @IBOutlet weak var wifiState: UILabel!
    @IBOutlet weak var wifiRange: UIImageView!
    @IBOutlet weak var wifiSsid: UILabel!
    @IBOutlet weak var wifiPassword: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.image = UIImage(named: "emergency")
        setUpView()
        //Wifi call
        getWifi()
    }
    
    // MARK: - SETUP
    func setUpView() {
        //MENU
        if revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        }
        wifiSsid.text = ""
        wifiPassword.text = ""
    }
    
    // MARK: - COPY
    @IBAction func copyTapped(_ sender: Any) {
        
    }
    
    // MARK: - GO TO U MOBILE APP
    @IBAction func goToTapped(_ sender: Any) {
        
    }
    
    func getWifi() {
        let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getWifiDetail + "?"
        networkManager.getMethod(url, params: nil, success: {(response) in
            
            if let response = response as? [String : Any], let wifiResponse = response["data"] as? [String:Any] {
                self.wifiSsid.text = wifiResponse[WifiData.wifiSsid.rawValue] as? String
                self.wifiPassword.text = wifiResponse[WifiData.wifiPassword.rawValue] as? String
            } else if let response = response as? [String : Any], let responseObj = response["error"] as? [String : Any], let error =  responseObj["error"] as? String {
                if error == ErrorsFromAPI.tokenError.rawValue {
                    // CALL SUBSCRIPTION API
                    Utility.checkSubscription(viewController: self)
                } else {
                    Utility.storeStaticDataToFile(fileName: ErrorMsgs.serverError, rawData: responseObj)
                }
            } else {
                Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
            }
        }, failure: {(error) in
            print("Error *** \(error)")
            Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
        })
        
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
