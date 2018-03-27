
//  AboutYouVC.swift
//  AtilzeConsumer
//
//  Created by Adarsh on 30/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.

import UIKit
enum AboutYou:String {
    case empty = ""
    case fullName = "Full name is empty."
    case name = "Name is empty."
    case comtactNo = "Conatct number is empty"
    case identifier = "AboutYourCarVC"
    case  storyboard = "SecondaryStoryboard"
    case invalidContact = "Invalid contact number"
}

class AboutYouVC: UIViewController {
    @IBOutlet weak var fullName: CustomTextField!
    @IBOutlet weak var emergencyContact: CustomTextField!
    @IBOutlet weak var contactNo: CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        if fullName.text == AboutYou.empty.rawValue {
            Utility.showAlert(title: APPNAME, message: AboutYou.fullName.rawValue, viewController: self)
        } else if emergencyContact.text == AboutYou.empty.rawValue {
            Utility.showAlert(title: APPNAME, message: AboutYou.name.rawValue, viewController: self)
        } else if contactNo.text == AboutYou.empty.rawValue {
            Utility.showAlert(title: APPNAME, message: AboutYou.comtactNo.rawValue, viewController: self)
        } else {
            let storyBoard : UIStoryboard = UIStoryboard(name:AboutYou.storyboard.rawValue, bundle:nil)
            let aboutYourCarVC:UIViewController = (storyBoard.instantiateViewController(withIdentifier: AboutYou.identifier.rawValue) as? AboutYourCarVC)!
            self.present(aboutYourCarVC, animated: true, completion: nil)
        }
    }
}
