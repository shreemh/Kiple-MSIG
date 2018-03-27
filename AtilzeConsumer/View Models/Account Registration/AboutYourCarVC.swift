//
//  AboutYourCarVC.swift
//  AtilzeConsumer
//
//  Created by Adarsh on 30/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

enum  AboutYourCar:String {
    case carModel = "Car Model is empty"
    case year = "Year is empty"
    case carPlateNo = "Car plate no is empty"
    case vinNo = "VIN No. is empty"
    case startMileage = "Starting mileage is empty"
    case empty = ""
}

class AboutYourCarVC: UIViewController {
    
    @IBOutlet weak var carModel: CustomTextField!
    @IBOutlet weak var year: CustomTextField!
    @IBOutlet weak var carPlateNo: CustomTextField!
    @IBOutlet weak var vinNo: CustomTextField!
    @IBOutlet weak var startingMileage: CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        
        if carModel.text == AboutYourCar.empty.rawValue {
            Utility.showAlert(title: APPNAME, message:AboutYourCar.carModel.rawValue, viewController: self)
            
        } else if year.text == AboutYourCar.empty.rawValue {
            Utility.showAlert(title: APPNAME, message:AboutYourCar.year.rawValue, viewController: self)
            
        } else if carPlateNo.text == AboutYourCar.empty.rawValue {
            Utility.showAlert(title: APPNAME, message:AboutYourCar.carPlateNo.rawValue, viewController: self)
            
        } else if vinNo.text == AboutYourCar.empty.rawValue {
            Utility.showAlert(title: APPNAME, message:AboutYourCar.vinNo.rawValue, viewController: self)
            
        } else if startingMileage.text == AboutYourCar.empty.rawValue {
            Utility.showAlert(title: APPNAME, message:AboutYourCar.startMileage.rawValue, viewController: self)
            
        } else {
            print("Next")
        }
        
    }
}
