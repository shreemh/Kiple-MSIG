//
//  AccountRegistrationVC.swift
//  AtilzeConsumer
//
//  Created by Adarsh on 30/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
enum Validation:String {
    case emptyEmail = "Email is Empty"
    case emptyPassword = "Password is Empty"
    case emptyConfirmPassword = "Confirm Password Empty"
    case passwordNotMatch = "Password do not match"
    case secondStoryBoard = "SecondaryStoryboard"
    case identifier = "AboutYouVC"
    case empty = ""
}

class AccountRegistrationVC: UIViewController {
    
    @IBOutlet weak var yourEmail: CustomTextField!
    @IBOutlet weak var password: CustomTextField!
    @IBOutlet weak var confirmPassword: CustomTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var signMeUp: UIButton!
    @IBAction func signMeUp(_ sender: UIButton) {
        if yourEmail.text == Validation.empty.rawValue {
            Utility.showAlert(title: APPNAME, message: Validation.emptyEmail.rawValue, viewController: self)
        } else if  password.text == Validation.empty.rawValue {
            Utility.showAlert(title: APPNAME, message: Validation.emptyPassword.rawValue, viewController: self)
        } else if confirmPassword.text ==  Validation.empty.rawValue {
            
            Utility.showAlert(title: APPNAME, message:Validation.emptyConfirmPassword.rawValue, viewController: self)
            
        } else if password.text != confirmPassword.text {
            Utility.showAlert(title: APPNAME, message:Validation.passwordNotMatch.rawValue, viewController: self)
            
        } else {
            let storyBoard : UIStoryboard = UIStoryboard(name:Validation.secondStoryBoard.rawValue, bundle:nil)
            let nextViewController:UIViewController = (storyBoard.instantiateViewController(withIdentifier: Validation.identifier.rawValue) as? AboutYouVC)!
            self.present(nextViewController, animated: true, completion: nil)
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
