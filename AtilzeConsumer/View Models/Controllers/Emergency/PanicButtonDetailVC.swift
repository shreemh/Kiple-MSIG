//
//  PanicButtonDetailVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 30/11/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class PanicButtonDetailVC: UIViewController {
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var type : String = ""
    var requestID : Int = 0

    @IBOutlet weak var cancelReqBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func setUp() {
        let swipeButtonLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(cancelReq))
        swipeButtonLeft.direction = UISwipeGestureRecognizerDirection.left
        
        let swipeButtonRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(cancelReq))
        swipeButtonRight.direction = UISwipeGestureRecognizerDirection.right
        
        cancelReqBtn.addGestureRecognizer(swipeButtonLeft)
        cancelReqBtn.addGestureRecognizer(swipeButtonRight)
    }
    
    @IBAction func call999(_ sender: Any) {
        self.call(number: 999)
    }
    
    @IBAction func callMyEmergencyContact(_ sender: Any) {
        
//        Utility.showAlert(title: APPNAME, message: "Under development", viewController: self)
        if let name = Model.shared.profileDict["emergency_name"], let contactNo = Model.shared.profileDict["emergency_contact"], !name.isEmpty, !contactNo.isEmpty {
            let digits = Model.shared.profileDict["emergency_contact"]!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            self.call(number: Int(digits)!)
        } else {
             Utility.showAlert(title: APPNAME, message: "Add emergency number", viewController: self)
        }
    }
    
    func cancelReq() {
        if Utility.isConnectedToNetwork() {
            
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.cancelRequest + String(requestID)
            networkManager.deleteMethod(url, params: nil, success: { (response) in
                
                print("response === \(response)")
                guard let result = response as? [String : Any], let msg = result["message"] as? String else {
                    Utility.showAlert(title: APPNAME, message: "Somrthing went wrong...try again!", viewController: self)
                    return
                }
                
                DispatchQueue.main.async {
                    Utility.showAlert(title: APPNAME, message: "Successfully cancelled the request", viewController: self)
                }
                
                self.navigationController?.popViewController(animated: true)
                
            }) { (error) in
                print("error *** \(error)")
            }
            
        } else {
            Utility.showAlert(message: internetConnectMsg, viewController: self)
        }
    }
    
    func call(number : Any) {
        
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
}
