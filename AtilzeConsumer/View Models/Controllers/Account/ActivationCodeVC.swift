//
//  ActivationCodeVC.swift
//  AtilzeCunsumer
//
//  Created by Shree on 23/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ActivationCodeVC: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {
    @IBOutlet var activationCodeCollection: [UITextField]!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var activationCodeSentMsg: UILabel!
    @IBOutlet weak var didNotreceive: UILabel!
    @IBOutlet weak var resendBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - SETUP
    func setUpView() {
        titleLbl.text =  Model.shared.isFromForgotPW ? "Forgot Password" : "Activate Account"
        activationCodeSentMsg.text = "Activation email has been resent to \(Utility.getEmail()). Should you fail to receive the code. kindly seek assistance from your dealer."
        activationCodeCollection[0].becomeFirstResponder()
        let email : String = Utility.getEmail()
        let message : String = "An email with the activation code has been sent to "
        let completeText: String = message + email
        messageText.attributedText = getAttrrbutedString(completeText: completeText, primaryText: message, secondaryText: email)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = false
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "00A3EA")
        // NAV TITLE
        Utility.setTransparentNavigationBar(navigationController: navigationController)
        navigationItem.titleView = Utility.getKipleCarAttributedLabel()
    }
    override func viewWillLayoutSubviews() {
    }
    
    func getAttrrbutedString(completeText: String, primaryText: String, secondaryText: String) -> NSMutableAttributedString {
        let attributed = NSMutableAttributedString(string: completeText)
        attributed.addAttributes([NSForegroundColorAttributeName : UIColor(hexString: "#00A3EA")], range: NSRange(location: primaryText.characters.count, length: attributed.length - primaryText.characters.count))
        return attributed
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func nextBtnCal(_ sender: Any) {
        do {
            try validations()
            // NEXT SCREEN
        } catch SignUpError.activationCode {
            Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.activationCode, viewController: self)
        } catch {
            print(error)
        }
    }
    
    // MARK: - VALIDATIONS
    func validations() throws {
        let testArray = activationCodeCollection.filter {$0.text?.characters.count == 0}
        guard testArray.count == 0 else {
            throw SignUpError.activationCode
        }
        apiCall()
    }
    
    func apiCall() {
        if Utility.isConnectedToNetwork() {
            // INTERNET CONNECTION AVAILABLE
            startAnimating(CGSize(width: 30, height: 30), message: "")
            var activationCode = ""
            for i in 0...activationCodeCollection.count - 1 {
                activationCode = activationCode + activationCodeCollection[i].text!
            }
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.validatActivationCode + Utility.getEmail() + "?" + "activation_code=\(activationCode)"
            networkManager.postMethod(url, params: nil, success: { (response) in
                self.stopAnimating()
                guard let result = response as? [String : Any], result["error"] == nil else {
                    if let result = response as? [String : Any], let resultData = result["error"] as? [String : Any], let errors = resultData["errors"] as? [String : Any], let firstError = errors.values.first as? [Any], let msg = firstError.first as? String {
                        Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                    } else {
                        Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.activationCode, viewController: self)
                    }
                    return
                }
                if let accountSetUpVC = secondSB.instantiateViewController(withIdentifier: "AccountSetUpVC") as? AccountSetUpVC {
                    accountSetUpVC.activationCode = activationCode
                    self.navigationController?.pushViewController(accountSetUpVC, animated: true)
                }
            }) { (error) in
                print("error *** \(error)")
                self.stopAnimating()
                Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.serverError, viewController: self)
            }
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }
    
    @IBAction func resendCode(_ sender: Any) {
        if Utility.isConnectedToNetwork() {
            // INTERNET CONNECTION AVAILABLE
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getActivationCode + Utility.getEmail() + "?"
            networkManager.postMethod(url, params: nil, success: { (response) in
                guard let result = response as? [String : Any], result["error"] == nil else {
                    if let result = response as? [String : Any], let resultData = result["error"] as? [String : Any], let errors = resultData["errors"] as? [String : Any], let firstError = errors.values.first as? [Any], let msg = firstError.first as? String {
                        Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                    } else {
                        Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.invalidEmail, viewController: self)
                    }
                    return
                }
                self.activationCodeSentMsg.isHidden = false
                self.didNotreceive.isHidden = true
                self.resendBtn.isHidden = true
            }) { (error) in
                print("error *** \(error)")
                Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.serverError, viewController: self)
            }
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        
        guard newString.length >= maxLength else {
            textField.text = " "
            switch textField {
            case activationCodeCollection[1]:
                activationCodeCollection[0].becomeFirstResponder()
                
            case activationCodeCollection[2]:
                activationCodeCollection[1].becomeFirstResponder()
                
            case activationCodeCollection[3]:
                activationCodeCollection[2].becomeFirstResponder()
                
            case activationCodeCollection[4]:
                activationCodeCollection[3].becomeFirstResponder()
                
            default:
                activationCodeCollection[0].becomeFirstResponder()
            }
            // textField.text = newString as String
            return false
        }
        
        switch textField {
        case activationCodeCollection[0]:
            activationCodeCollection[0].text = string
            self.activationCodeCollection[1].becomeFirstResponder()
            
        case activationCodeCollection[1]:
            activationCodeCollection[1].text = string
            activationCodeCollection[2].becomeFirstResponder()
            
        case activationCodeCollection[2]:
            activationCodeCollection[2].text = string
            activationCodeCollection[3].becomeFirstResponder()
            
        case activationCodeCollection[3]:
            activationCodeCollection[3].text = string
            activationCodeCollection[4].becomeFirstResponder()
            
        case activationCodeCollection[4]:
            activationCodeCollection[4].text = string
            activationCodeCollection[4].resignFirstResponder()
            
        default:
            activationCodeCollection[0].becomeFirstResponder()
        }
        return false
    }
    
    //    func textFieldDidBeginEditing(_ textField: UITextField) {
    //        textField.text = ""
    //
    //    }
    //
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //
    //        let maxLength = 1
    //        let currentString: NSString = textField.text! as NSString
    //        let newString: NSString =
    //            currentString.replacingCharacters(in: range, with: string) as NSString
    //
    //        guard newString.length >= maxLength else {
    //            textField.text = newString as String
    //            return false
    //        }
    //
    //        switch textField {
    //        case activationCodeCollection[0]:
    //            print("0 ==== \(activationCodeCollection[0].text)")
    //            activationCodeCollection[0].text = activationCodeCollection[0].text! + string
    //            self.activationCodeCollection[1].becomeFirstResponder()
    //        case activationCodeCollection[1]:
    //            print("1 ==== \(activationCodeCollection[1].text)")
    //            activationCodeCollection[1].text = activationCodeCollection[1].text! + string
    //            activationCodeCollection[2].becomeFirstResponder()
    //        case activationCodeCollection[2]:
    //            print("3 ==== \(activationCodeCollection[2].text)")
    //            activationCodeCollection[2].text = activationCodeCollection[2].text! + string
    //            activationCodeCollection[2].resignFirstResponder()
    //        default:
    //            activationCodeCollection[0].becomeFirstResponder()
    //        }
    //        return false
    //    }
    
    
}
