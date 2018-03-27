//
//  AccountSetUpVC.swift
//  AtilzeCunsumer
//
//  Created by Shree on 24/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class AccountSetUpVC: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var passwordMsg: UILabel!
    @IBOutlet weak var password: CustomTextField!
    @IBOutlet weak var confirmPassword: CustomTextField!
    var activationCode : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    // MARK: - SETUP
    func setUpView() {
        // TITLE
        titleLbl.text =  Model.shared.isFromForgotPW ? "Reset Password" : "Account Setup"
        passwordMsg.text = Model.shared.isFromForgotPW ? "Please set a new password for your account" : "Please set a password for your account"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        // NAV TITLE
        Utility.setTransparentNavigationBar(navigationController: navigationController)
        navigationItem.titleView = Utility.getKipleCarAttributedLabel()
    }
    override func viewWillLayoutSubviews() {
    }
    @IBAction func nextBtnCall(_ sender: Any) {
        do {
            try validation()
            // NEXT SCREEN
        } catch SignUpError.emptyPassword {
            Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.enterPassword, viewController: self)
        } catch SignUpError.emptyConfirmPassword {
            Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.enterConfirmPAssword, viewController: self)
        } catch SignUpError.passwordLenght {
            Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.passwordLenght, viewController: self)
        } catch SignUpError.matchPasswords {
            Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.passwordMisMatch, viewController: self)
        } catch {
            print(error)
        }
    }
    
    // MARK: - VALIDATIONS
    func validation() throws {
        
        var passwordText: String = password.text ?? ""
        var confirmPasswordText: String = confirmPassword.text ?? ""
        guard password.text?.characters.count != 0 else {
            throw SignUpError.emptyPassword
        }
        guard passwordText.characters.count >= 6, confirmPasswordText.characters.count >= 6 else {
            throw SignUpError.passwordLenght
        }
        guard confirmPassword.text?.characters.count != 0 else {
            throw SignUpError.emptyConfirmPassword
        }
        guard passwordValidation() else {
            throw SignUpError.matchPasswords
        }
        apiCall()
    }
    func passwordValidation() -> Bool {
        if password.text == confirmPassword.text {
            return true
        }
        return false
    }
    func apiCall() {
        if Utility.isConnectedToNetwork() {
            startAnimating(CGSize(width: 30, height: 30), message: "")
            // INTERNET CONNECTION AVAILABLE
            let wizAPI = Model.shared.isFromForgotPW ? Constants.APIEndPoints.resetPassword : Constants.APIEndPoints.setPassword
            let url = Constants.ServerAddress.baseURL + wizAPI + Utility.getEmail() + "?"
            let params: [String : Any] = ["activation_code" : activationCode, "password" : password.text ?? "", "password_confirmation" : confirmPassword.text ?? ""]
            if Model.shared.isFromForgotPW {
                // FORGOT PASSWORD
                networkManager.putMethod(url, params: params, success: { (response) in
                    self.stopAnimating()
                    guard let result = response as? [String : Any], result["error"] == nil else {
                        if let result = response as? [String : Any], let resultData = result["error"] as? [String : Any], let errors = resultData["errors"] as? [String : Any], let firstError = errors.values.first as? [Any], let msg = firstError.first as? String {
                            Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                        } else {
                            Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                        }
                        return
                    }
                    let welcomeVC = secondSB.instantiateViewController(withIdentifier: "WelcomeVC")
                    self.navigationController?.pushViewController(welcomeVC, animated: true)
                    
                }) { (error) in
                    print("error *** \(error)")
                    self.stopAnimating()
                    Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.serverError, viewController: self)
                }
            } else {
                // SET PASSWORD FIRST TIME
                networkManager.postMethod(url, params: params, success: { (response) in
                    self.stopAnimating()
                    guard let result = response as? [String : Any], result["error"] == nil else {
                        if let result = response as? [String : Any], let resultData = result["error"] as? [String : Any], let errors = resultData["errors"] as? [String : Any], let firstError = errors.values.first as? [Any], let msg = firstError.first as? String {
                            Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                        } else {
                            Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.serverError, viewController: self)
                        }
                        return
                    }
                    let welcomeVC = secondSB.instantiateViewController(withIdentifier: "WelcomeVC")
                    self.navigationController?.pushViewController(welcomeVC, animated: true)
                    
                }) { (error) in
                    self.stopAnimating()
                    print("error *** \(error)")
                    Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.serverError, viewController: self)
                }
            }
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }
}
