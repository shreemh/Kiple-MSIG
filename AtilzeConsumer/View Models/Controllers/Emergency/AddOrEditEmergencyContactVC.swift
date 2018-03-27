//
//  AddOrEditEmergencyContactVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 22/12/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class AddOrEditEmergencyContactVC: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var contact: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var barItem: UIBarButtonItem!
    @IBOutlet weak var removeContactBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barItem.title = "Save"
        name.text = Model.shared.profileDict["emergency_name"]
        contact.text = Model.shared.profileDict["emergency_contact"]
        guard (contact.text?.isEmpty)! else {
            removeContactBtn.isHidden = false
            return
        }
        removeContactBtn.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func removeBtnCall(_ sender: Any) {
        name.text = ""
        contact.text =  ""
        updateUserInfo()
    }
    
    @IBAction func saveBtnCall(_ sender: Any) {
        if !(name?.text?.isEmpty)!, !(contact?.text?.isEmpty)! {
              updateUserInfo()
        } else {
            Utility.showAlert(title: APPNAME, message: "Add contact name and number", viewController: self)
        }
    }

    func updateUserInfo() {
        let params : [String : Any] = ["driver_email" : Model.shared.profileDict["email"] ?? "", "driver_contact" : Model.shared.profileDict["phone"] ?? "", "driver_name" : Model.shared.profileDict["name"] ?? "", "emergency_name" : name.text ?? "", "emergency_contact" : contact.text ?? ""]

        let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.postAccountInfo + "?"
        networkManager.postMethod(url, params: params, success: { (response) in
            guard let result = response as? [String : Any], result["error"] == nil else {
                if let result = response as? [String : Any], let resultData = result["error"] as? [String : Any], let errors = resultData["errors"] as? [String : Any], let firstError = errors.values.first as? [Any], let msg = firstError.first as? String {
                    Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                } else {
                    Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                }
                return
            }
            Model.shared.profileDict["emergency_name"] = self.name?.text
            Model.shared.profileDict["emergency_contact"] = self.contact?.text
            self.getUserInfo()
            DispatchQueue.main.async {
                Utility.showAlert(title: APPNAME, message: "Updated!", viewController: self)
            }
            self.navigationController?.popToRootViewController(animated: true)
            
        }, failure: { (error) in
            print("Error *** \(error)")
            Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.serverError, viewController: self)
        })
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

}
