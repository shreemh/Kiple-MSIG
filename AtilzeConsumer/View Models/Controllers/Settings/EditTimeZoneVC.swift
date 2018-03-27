//
//  EditTimeZoneVC.swift
//  AtilzeCunsumer
//
//  Created by Shree on 15/09/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class EditTimeZoneVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var timeZonesArray : [String] = [String]()
    var searchActive : Bool = false
    var filtered:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - SETUP
    func setUpView() {
        // TABLE VIEW
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        fetchDataFromFile()
    }
    
    func fetchDataFromFile() {
        self.timeZonesArray.removeAll()
        let storedData = Utility.readFromFile(fileName: FileNames.timeZones.rawValue)
        if let status = storedData["status"] as? String, status == "OK", let timeZonesDict = storedData["data"] as? [String : Any], let array = timeZonesDict["timezones"] as? [String] {
            timeZonesArray = array
            filtered = timeZonesArray
            tableView.reloadData()
        } else {
            // STATUS == ERROR OR NO DATA - CALL API
            getTimeZones()
        }
    }
    
    func getTimeZones() {
        if Utility.isConnectedToNetwork() {
            // INTERNET CONNECTION AVAILABLE
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getTimeZones + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                self.timeZonesArray.removeAll()
                self.filtered.removeAll()
                if let response = response as? [String : Any], let resultArray = response["data"] as? [String] {
                    print("SUCCESS")
                    // STORE TIMEZONES TO LOCAL DB
                    DispatchQueue.global(qos: .background).async {
                        Utility.storeStaticDataToFile(fileName: FileNames.timeZones.rawValue, rawData: ["timezones" : resultArray])
                    }
                    self.timeZonesArray = resultArray
                    self.filtered = self.timeZonesArray
                    self.tableView.reloadData()
                } else {
                    print("FAILED")
                    Utility.showAlert(title: APPNAME, message: "Try Again!!", viewController: self)
                }
                
            }) { (error) in
               print("error *** \(error)")
               Utility.showAlert(title: APPNAME, message: "Try Again!!", viewController: self)
            }
        } else {
            print(internetConnectMsg)
        }
    }

    // MARK: - TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  filtered.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            print("ERROR")
            fatalError()
        }
        cell.selectionStyle = .none
        let name = cell.viewWithTag(1) as? UILabel
        name?.text = filtered[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.updateTimeZone(index: indexPath.row)
    }
    
    func updateTimeZone(index : Int) {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.postAccountInfo + "?"
            let params : [String:Any] = ["driver_email" : Model.shared.profileDict["email"] ?? "", "driver_name" : Model.shared.profileDict["name"] ?? "", "driver_contact" : Model.shared.profileDict["phone"] ?? "", "driver_timezone" : filtered[index]]
            networkManager.postMethod(url, params: params, success: { (response) in
                guard let res = response as? [String : Any], res["error"] == nil else {
                    Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                    return
                }
                // DELETE ALL FILES FROM DOC DIR
                let fileManager = FileManager.default
                let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
                let documentsPath = documentsUrl.path
                do {
                    let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
                    print("All files in doc: \(fileNames)")
                    for fileName in fileNames {
                        if (fileName.hasSuffix(".dat")) {
                            let filePathName = "\(documentsPath)/\(fileName)"
                            try fileManager.removeItem(atPath: filePathName)
                        }
                    }
                    let files = try fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
                    print("Files in doc after deleting: \(files)")
                    // RETAIN ONLY TIMEZONE FILE
                    Utility.storeStaticDataToFile(fileName: FileNames.timeZones.rawValue, rawData: ["timezones" : self.timeZonesArray])
                } catch {
                    print("Could not clear temp folder: \(error)")
                }
                Model.shared.timeZone = self.filtered[index]
                Utility.storeStaticDataToFile(fileName: FileNames.selectedTimeZone.rawValue, rawData: ["timezone" : Model.shared.timeZone])
                DispatchQueue.main.async {
                    Utility.showAlert(title: APPNAME, message: "Updated!", viewController: self)
                }
                self.navigationController?.popViewController(animated: true)
                
            }, failure: { (error) in
                print("Error *** \(error)")
                Utility.showAlert(title: APPNAME, message: SignInErrorMsgs.serverError, viewController: self)
            })
      
    }
    
    // MARK: - SEARCH BAR
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered.removeAll()
        filtered = timeZonesArray.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if (searchBar.text?.isEmpty)! {
            filtered = timeZonesArray
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
}
