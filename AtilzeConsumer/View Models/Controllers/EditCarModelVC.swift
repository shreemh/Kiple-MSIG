//
//  EditCarModelVC.swift
//  AtilzeCunsumer
//
//  Created by Adarsh on 23/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
class EditCarModelVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var pickerArray = [String]()
    var carModelsDict = [String : String]()
    var carManufecturerDict = [String : String]()
    var selected : String = ""
    var carModelString : String = ""
    var manufacturerString : String = ""
    var selectedIndex : IndexPath = IndexPath()
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var barItem: UIBarButtonItem!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var carModel: UIButton!
    @IBOutlet weak var carManufacturer: UILabel!
    @IBOutlet weak var carModelPicker: UIPickerView!
    var isCarModelPicker : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - SETUP
    func setUpView() {
        carModelPicker.delegate = self
        carModelPicker.dataSource = self
        carModelPicker.isHidden = true
        carModel.setTitle(carModelString, for:UIControlState.normal)
        carManufacturer.text = manufacturerString
        fetchDataFromFile()
        getManufecturerList()
        
    }
    @IBAction func saveTapped(_ sender: Any) {
        if barItem.title == "Done" {
            carModelPicker.isHidden = true
            if !isCarModelPicker, carManufacturer.text != manufacturerString {
                carManufacturer.text = manufacturerString
                carModelString = "Select"
                carModel.setTitle(carModelString, for:UIControlState.normal)
            } else {
                carModel.setTitle(carModelString, for: .normal)
            }
            barItem.title = "Save"
            self.navigationItem.setHidesBackButton(false, animated: true)
            self.view.backgroundColor = UIColor.init(hexString: "EEEEEE").withAlphaComponent(1.0)
            firstView.alpha = 1.0
            middleView.alpha = 1.0
            secondView.alpha = 1.0
        } else {
            let keys1 = carManufecturerDict.allKeys(forValue: manufacturerString)
            let keys2 = carModelsDict.allKeys(forValue: carModelString)
            guard keys1.count > 0, keys2.count > 0 else {
                guard carModelString.lowercased() != "select", !manufacturerString.isEmpty, !carModelString.isEmpty else {
                    Utility.showAlert(title: APPNAME, message: "Select Manufacturer name to continue", viewController: self)
                    return
                }
                DispatchQueue.main.async {
                    Utility.showAlert(title: APPNAME, message: "Updated!", viewController: self)
                }
                self.navigationController?.popViewController(animated: true)
                return
            }
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.postVehicleInfo + "?"
            let params : [String:Any] = ["manufacturer" : keys1[0], "model": keys2[0]]
            networkManager.postMethod(url, params: params, success: { (resonse) in
                if let res = resonse as? [String : Any], res["error"] == nil {
                    DispatchQueue.main.async {
                        Utility.showAlert(title: APPNAME, message: "Updated!", viewController: self)
                    }
                    Model.shared.carModelDict[self.selectedIndex.row]["value"] = self.carModelString
                    Model.shared.carModelDict[5]["value"] = self.manufacturerString
                    self.navigationController?.popViewController(animated: true)
                } else if let res = resonse as? [String : Any], let responseData = res["error"] as? [String : Any], let msg = responseData["message"] as? String {
                   Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                } else {
                    Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                }
            }, failure: { (error) in
                print("Error *** \(error)")
                Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.serverError, viewController: self)
            })
            
        }
    }
    @IBAction func carModelTapped(_ sender: UIButton) {
        if sender.tag == 2 {
            isCarModelPicker = true
            guard carManufecturerDict.count > 0 else {
                getManufecturerList()
                Utility.showAlert(title: APPNAME, message: "Try Again!", viewController: self)
                return
            }
            getCarModelList()
        } else {
            isCarModelPicker = false
            getManufecturerList()
        }
    }

    func showPickerView(pickerDict : [String : String]) {
        self.pickerArray = pickerDict.flatMap{ $0.1}
        carModelPicker.reloadAllComponents()
        carModelPicker.isHidden = false
        barItem.title = "Done"
        navigationItem.setHidesBackButton(true, animated: true)
        self.view.backgroundColor = UIColor.init(hexString: "EEEEEE").withAlphaComponent(0.7)
        firstView.alpha = 0.4
        middleView.alpha = 0.4
        secondView.alpha = 0.4
        
        if isCarModelPicker {
            guard let index = pickerArray.index(of: carModelString) else {
                carModelPicker.selectRow(Int(pickerArray.count/2), inComponent: 0, animated: true)
                carModelString = pickerArray[pickerArray.count/2]
                return
            }
            carModelPicker.selectRow(index, inComponent: 0, animated: true)
        } else {
            guard let index = pickerArray.index(of: manufacturerString) else {
                carModelPicker.selectRow(Int(pickerArray.count/2), inComponent: 0, animated: true)
                return
            }
            carModelPicker.selectRow(index, inComponent: 0, animated: true)
          //  manufacturerString = pickerArray[carModelPicker.selectedRow(inComponent: 0)]
            
        }
      
    }
    
    func fetchDataFromFile() {
//        // FETCH CAR STATUS FROM FILE
//        let storedData = Utility.readFromFile(fileName: FileNames.carModelList.rawValue)
//        // CHECK TRIPS FOR THE SELECTED MONTH
//        if let status = storedData["status"] as? String, status == "OK", let carModelList = storedData["data"] as? [String : Any] {
//            self.carModelsArray = carModelList.flatMap(){ $0.1 as? String}
//        } else {
//            // STATUS == ERROR OR NO DATA - CALL API
//            getCarModelList()
//        }
    }
    
    func getManufecturerList() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getManufacturerList + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                guard let response = response as? [String : Any], let responseObj = response["data"] as? [String : String] else {
                    return
                }
                self.carManufecturerDict = responseObj
                if !self.isCarModelPicker {
                    self.showPickerView(pickerDict : self.carManufecturerDict)
                }
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }

    func getCarModelList() {
        let keys = carManufecturerDict.allKeys(forValue: manufacturerString)
        if keys.count > 0 {
            if Utility.isConnectedToNetwork() {
                let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getCarModelList + keys[0] + "?"
                networkManager.getMethod(url, params: nil, success: { (response) in
                   
                    guard let response = response as? [String : Any], let responseObj = response["data"] as? [String : String] else {
                        return
                    }
                    self.carModelsDict = responseObj
                    self.showPickerView(pickerDict: self.carModelsDict)
                }) { (error) in
                    print("error *** \(error)")
                }
            } else {
                Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
            }
        } else {
            Utility.showAlert(title: APPNAME, message: "Something went wrong!!", viewController: self)
        }
    }
    
//    func getCarModelList() {
//        if Utility.isConnectedToNetwork() {
//            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getCarModelList + "?"
//            networkManager.getMethod(url, params: nil, success: { (response) in
//                print("response car models == \(response)")
//                guard let responseObj = response as? [String : Any] else {
//                    return
//                }
//                // STORE TRIPS BASED ON SELECTED MONTH
//                DispatchQueue.global(qos: .background).async {
//                    
//                    // UPDATE TRIPS ARRAY TO DB
//                    Utility.storeStaticDataToFile(fileName: FileNames.carModelList.rawValue, rawData: responseObj)
//                }
//                self.carModelsArray = responseObj.flatMap(){ $0.1 as? String}
//                
//            }) { (error) in
//                print("error *** \(error)")
//            }
//        } else {
//            // NO INTERNET CONNECTION
//            // FETCH CAR STATUS FROM FILE
//            let storedData = Utility.readFromFile(fileName: FileNames.carModelList.rawValue)
//            // CHECK TRIPS FOR THE SELECTED MONTH
//            guard let status = storedData["status"] as? String, status == "OK", let carModelList = storedData["data"] as? [String : Any] else {
//                return
//            }
//            self.carModelsArray = carModelList.flatMap(){ $0.1 as? String }
//        }
//    }
    
    // MARK: - PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //  let defaults = UserDefaults.standard
        if isCarModelPicker {
            carModelString = pickerArray[row]
        } else {
            manufacturerString = pickerArray[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        pickerView.backgroundColor = .white
        pickerView.layer.cornerRadius = 7.0
        pickerView.layer.masksToBounds = true
        
        var pickerLabel = view as? UILabel
        if (pickerLabel == nil) {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Montserrat-Regular", size: 17)
            pickerLabel?.text = pickerArray[row]
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        pickerLabel?.backgroundColor = .gray
   //     pickerLabel?.backgroundColor = (row == pickerView.selectedRow(inComponent: component)) ? UIColor.white : UIColor.gray
        pickerLabel?.text = pickerArray[row]
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
}
extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}
