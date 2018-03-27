//
//  ActivateAccountVC.swift
//  AtilzeCunsumer
//
//  Created by Shree on 24/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ActivateAccountVC: UIViewController, NVActivityIndicatorViewable{
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var existingUserLbl: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var email: CustomTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - SETUP
    func setUpView() {
        // NAV TITLE
        Utility.setTransparentNavigationBar(navigationController: navigationController)
        navigationItem.titleView = Utility.getKipleCarAttributedLabel()
        // TITLE
        titleLbl.text =  Model.shared.isFromForgotPW ? "Forgot Password" : "Activate Account"
    }
    override func viewWillLayoutSubviews() {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        if Model.shared.isFromForgotPW {
            existingUserLbl.isHidden = true
            loginBtn.isHidden = true
            navigationItem.hidesBackButton = false
            navigationController?.navigationBar.tintColor = UIColor.init(hexString: "00A3EA")
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func nextBtnCal(_ sender: Any) {
        do {
            try validations()
            UserDefaults.standard.set((self.email.text ?? ""), forKey: "VW.Consumer.Email")
            // NEXT SCREEN
        } catch SignUpError.emptyEmail {
            Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.enterEmail, viewController: self)
        } catch SignUpError.invalidEmail {
            Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.invalidEmail, viewController: self)
        } catch {
            print(error)
        }
    }
    // MARK: - VALIDATIONS
    func validations() throws {
        guard email.text?.characters.count != 0 else {
            throw SignUpError.emptyEmail
        }
        guard validateEmail(email: email.text) else {
            throw SignUpError.invalidEmail
        }
        apiCall()
    }
    
    func validateEmail(email: String?) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func apiCall() {
        if Utility.isConnectedToNetwork() {
                startAnimating(CGSize(width: 30, height: 30), message: "")
                // INTERNET CONNECTION AVAILABLE
                let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getActivationCode + email.text! + "?"
                networkManager.postMethod(url, params: nil, success: { (response) in
                    self.stopAnimating()
                    guard let result = response as? [String : Any], result["error"] == nil else {
                        if let result = response as? [String : Any], let resultData = result["error"] as? [String : Any], let errors = resultData["errors"] as? [String : Any], let firstError = errors.values.first as? [Any], let msg = firstError.first as? String {
                            Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                        } else {
                            Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.enterRegisteredEmail, viewController: self)
                        }
                        return
                    }
                    let activationCodeVC = secondSB.instantiateViewController(withIdentifier: "ActivationCodeVC")
                    self.navigationController?.pushViewController(activationCodeVC, animated: true)
                    
                }) { (error) in
                    print("error *** \(error)")
                    self.stopAnimating()
                    Utility.showAlert(title: APPNAME, message: SignUpErrorMsgs.serverError, viewController: self)
                }
            } else {
                Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
            }
    }
    
    @IBAction func loginBtnCal(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
