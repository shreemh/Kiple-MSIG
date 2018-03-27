//
//  ChangePasswordVC.swift
//  AtilzeCunsumer
//
//  Created by Adarsh on 23/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController, UITextFieldDelegate {
    let padding = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 5)
    let settingVC = SettingsVC ()
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var doneTapped: UIBarButtonItem!
    @IBOutlet weak var whiteLine: UIView!
    
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title2: UILabel!
    
    var selectedField : String = ""
    var currentValue : String = ""
    var currectValuesDict : [String : String]?
    var fieldToBeEdited : String = ""
    var selectedIndex : IndexPath = IndexPath()
    override func viewDidLoad() {
        super.viewDidLoad()
        doneTapped.isEnabled = false
        textField1.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        textField2.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        textField3.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        setUpView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        //        setUpView()
    }
    func setUpView() {
        textField1.isSecureTextEntry = false
        textField2.isSecureTextEntry = false
        textField3.isSecureTextEntry = false
        self.title = selectedField.capitalized
        textField1.placeholder = selectedField
        title1.text = selectedField
        
        textField1.setLeftPaddingPoints(15)
        
        textField2.isHidden = true
        textField3.isHidden = true
        title2.isHidden = true
        
        if currentValue.characters.count > 0 {
            textField1.text = currentValue
            doneTapped.isEnabled = true
        }
        
        switch selectedField {
        case EditProfile.name :
            if currectValuesDict != nil {
                textField1.text = currectValuesDict?["name"]
                doneTapped.isEnabled = true
            }
          //  addRightView(text: self.textField1, image: imageFromName(name: "name_icon"))
            return
        case EditProfile.phone :
            if currectValuesDict != nil {
                textField1.text = currectValuesDict?["phone"]
                doneTapped.isEnabled = true
            }
          //  addRightView(text: self.textField1, image: imageFromName(name: "contact_icon"))
            textField1.keyboardType = .numberPad
            return
        case EditProfile.password:
            textField1.isSecureTextEntry = true
            textField2.isSecureTextEntry = true
            textField3.isSecureTextEntry = true
            textField2.isHidden = false
            textField3.isHidden = false
            title2.isHidden = false
            textField1.placeholder = "Current Password"
            textField2.placeholder = "New Password"
            title1.text = "Current Password"
            title2.text = "New Password"
            addRightView(text: textField1, image: imageFromName(name: "lock"))
            addRightView(text: textField2, image: imageFromName(name: "lock"))
            addRightView(text: textField3, image: imageFromName(name: "lock"))
            textField3.placeholder = selectedField
            return
        case EditProfile.vinNo, EditProfile.carPlate :
            whiteLine.isHidden = true
            textField2.isHidden = true
            textField3.isHidden = true
            fieldToBeEdited = "vin"
          //  addRightView(text: self.textField1, image: imageFromName(name: "vin_icon"))
            if selectedField == EditProfile.carPlate {
                addRightView(text: self.textField1, image: imageFromName(name: "carPlate_icon"))
                fieldToBeEdited = "license_plate"
            }
            return
        case EditProfile.currentMileage, EditProfile.startingMileage:
            whiteLine.isHidden = true
            textField1.keyboardType = .numberPad
            textField2.isHidden = true
            textField3.isHidden = true
            fieldToBeEdited = "current_mileage"
            addLeftView()
          //  addRightView(text: self.textField1, image: imageFromName(name: "mileage_icon"))
            if selectedField == EditProfile.startingMileage {
                fieldToBeEdited = "start_mileage"
            }
            return
        default:
            textField1.keyboardType = .default
            return
        }
    }
    @IBAction func changePasswordTapped(_ sender: Any) {
        switch selectedField {
        case EditProfile.name, EditProfile.phone :
            //            if (textField2.text?.characters.count)! < 10 || (textField2.text?.characters.count)! > 10 {
            //                Utility.showAlert(title: APPNAME, message:Profile.phone, viewController: self)
            //            }
            //            if !validateEmail(email: textField3.text) {
            //                Utility.showAlert(title: APPNAME, message:Profile.Email, viewController: self)
            //            } else {
            
            //EDIT PROFILE
            updateUserInfo()
        //            }
        case EditProfile.password:
            if (textField1.text?.isEmpty)! {
                Utility.showAlert(title: APPNAME, message: ChangePassword.currentPassword, viewController: self)
            } else if (textField3.text?.characters.count)! < 6, (textField2.text?.characters.count)! < 6 {
                Utility.showAlert(title: APPNAME, message: ChangePassword.passwordLenght, viewController: self)
            } else if (textField2.text?.isEmpty)! {
                Utility.showAlert(title: APPNAME, message: ChangePassword.newPassword, viewController: self)
            } else if (textField3.text?.isEmpty)! {
                Utility.showAlert(title: APPNAME, message: ChangePassword.confirmPassword, viewController: self)
            } else if  textField3.text != textField2.text {
                Utility.showAlert(title: APPNAME, message: ChangePassword.passwordsMisMatch, viewController: self)
            } else if  textField1.text == textField2.text {
                Utility.showAlert(title: APPNAME, message: ChangePassword.newPassordSame, viewController: self)
            }
            else {
                // CHANGE PASSWORD
                changePasswordCall()
            }
        default:
            // EDIT CAR INFO
            updateVehicleInfo()
        }
    }
    func validateEmail(email: String?) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    func addRightView(text:UITextField, image:UIImage) {
        let paddingView  = UIImageView(frame: CGRect(x: 0, y: 0, width: 46, height:17))
        paddingView.image = image
        paddingView.contentMode = .center
        text.leftView =  paddingView
        text.leftViewMode = UITextFieldViewMode.always
        text.addSubview(paddingView)
    }
    
    func addLeftView() {
        let textPad = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 18))
        textPad.image = UIImage(named:"km")
        textPad.contentMode = .center
        self.textField1.rightView = textPad
        self.textField1.rightViewMode = UITextFieldViewMode.always
        self.textField1.addSubview(textPad)
    }
    
    func updateUserInfo() {
        
        let fieldToBeUpdated: String = selectedField == EditProfile.name ? "driver_name" : "driver_contact"
        var params : [String : Any] = [fieldToBeUpdated: textField1.text ?? "", "driver_email" : Model.shared.profileDict["email"] ?? ""]
        if fieldToBeUpdated == "driver_name" {
            params["driver_contact"] =  Model.shared.profileDict["phone"] ?? ""
        } else {
            params["driver_name"] = Model.shared.profileDict["name"] ?? ""
        }
        
//        let fieldToBeChanged = self.selectedField == EditProfile.name ? "name" : "phone"
//        Model.shared.profileDict[fieldToBeChanged] = self.textField1.text
//        DispatchQueue.main.async {
//            Utility.showAlert(title: APPNAME, message: "Updated!", viewController: self)
//        }
//        self.navigationController?.popViewController(animated: true)
        
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
            let fieldToBeChanged = self.selectedField == EditProfile.name ? "name" : "phone"
            Model.shared.profileDict[fieldToBeChanged] = self.textField1.text

            DispatchQueue.main.async {
                Utility.showAlert(title: APPNAME, message: "Updated!", viewController: self)
            }
            self.navigationController?.popViewController(animated: true)

        }, failure: { (error) in
            print("Error *** \(error)")
            Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.serverError, viewController: self)
        })
    }
    
    func updateVehicleInfo() {
        let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.postVehicleInfo + "?"
        let params : [String:Any] = [fieldToBeEdited: textField1.text ?? ""]
        networkManager.postMethod(url, params: params, success: { (response) in
            guard let result = response as? [String : Any], result["error"] == nil else {
                if let result = response as? [String : Any], let resultData = result["error"] as? [String : Any], let errors = resultData["errors"] as? [String : Any], let firstError = errors.values.first as? [Any], let msg = firstError.first as? String {
                    Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                } else {
                    Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                }
                return
            }
            DispatchQueue.main.async {
                Utility.showAlert(title: APPNAME, message: "Updated!", viewController: self)
            }
            Model.shared.carModelDict[self.selectedIndex.row]["value"] = self.textField1.text
            self.navigationController?.popViewController(animated: true)
            
        }, failure: { (error) in
            print("Error *** \(error)")
            Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.serverError, viewController: self)
        })
    }
    
    func changePasswordCall() {
        let passwordChangeAPI = Constants.ServerAddress.baseURL + Constants.APIEndPoints.changePassword + "?"
        let params:[String:Any] = ["current_password": textField1.text ?? "", "password" : textField2.text ?? "", "password_confirmation" : textField3.text ?? ""]
        networkManager.putMethod(passwordChangeAPI, params: params, success: { (response) in
            
            guard let result = response as? [String : Any], result["error"] == nil else {
                if let result = response as? [String : Any], let resultData = result["error"] as? [String : Any], let errors = resultData["errors"] as? [String : Any], let firstError = errors.values.first as? [Any], let msg = firstError.first as? String {
                    Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                } else {
                    Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                }
                return
            }
            DispatchQueue.main.async {
                Utility.showAlert(title: APPNAME, message: "Password changed successfully!", viewController: self)
            }
            self.navigationController?.popViewController(animated: true)
            
            
            
//            if let result = response as? [String : Any], result["errors"] != nil {
//                Utility.showAlert(title: APPNAME, message: "Current password is wrong!", viewController: self)
//                print("Response:\(String(describing: response))")
//            } else if let result = response as? [String : Any], let resultString = result["message"] as? String, resultString.lowercased().range(of:"unsuccessfully") == nil {
//                DispatchQueue.main.async {
//                    Utility.showAlert(title: APPNAME, message: "Password changed successfully!", viewController: self)
//                }
//                self.navigationController?.popViewController(animated: true)
//            } else {
//                Utility.showAlert(title: APPNAME, message: "Current password is wrong!", viewController: self)
//            }
        }, failure: { (error) in
            print("Error *** \(error)")
            Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.serverError, viewController: self)
        })
    }
    
    func editingChanged(_ textField: UITextField) {
        if textField.text?.characters.count == 1 {
            if textField.text?.characters.first == " " {
                textField.text = ""
                return
            }
        }
        switch selectedField {
        case EditProfile.password:
            guard
                let current = textField1.text, !current.isEmpty,
                let new = textField2.text, !new.isEmpty,
                let confirm = textField3.text, !confirm.isEmpty
                else {
                    doneTapped.isEnabled = false
                    return
            }
        default :
            guard
                let current = textField1.text, !current.isEmpty
                else {
                    doneTapped.isEnabled = false
                    return
            }
        }
        doneTapped.isEnabled = true
    }
    
    func imageFromName(name : String) -> UIImage {
      //  var image = UIImage()
        let image: UIImage! = UIImage(named: name)
        return image != nil ? image : UIImage()
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
