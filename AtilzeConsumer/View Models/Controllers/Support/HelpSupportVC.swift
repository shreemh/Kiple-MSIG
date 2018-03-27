//
//  HelpSupportVC.swift
//  AtilzeCunsumer
//
//  Created by Adarsh on 22/09/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class HelpSupportVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
//    var popularIssues = ["Inaccurate location of my car", "Trips are not recorded", "App is freezing/Crashing"]
//    var helpTopics = ["Account and setup", "Trobleshoot app","A guide to KipleCar", "Report an issue"]

//    var popularIssues = ["“Find My Car” Location is inaccurater", "My latest trip is not being shown"]
//    let sectionNames = ["Popular Issues", "Helper Topics"]
//
    
    var titles = ["Account Management", "Drive and Track", "OBD II", "Others"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem?.image = UIImage(named: "emergency")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - UIBUTTON ACTIONS
    @IBAction func emergencyBtnCall(_ sender: Any) {
        // NAVIGATE TO EMERGENCY SCREEN
        if let emergencyVC = mainSB.instantiateViewController(withIdentifier: StoryBoardVC.emergency) as? EmergencyVC {
            emergencyVC.isFromDashBoard = true
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(emergencyVC, animated: true)
        }
    }
    
//    // MARK: - TABLEVIEW
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return topic.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0:
//            return 3
//        case 1:
//            return 4
//        default:
//            print("Do nothing")
//        }
//        return 0
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let inAccurateCell = tableView.dequeueReusableCell(withIdentifier: "InaccurateCell") else {
//            print("ERROR")
//            fatalError()
//        }
//        guard let accountCell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") else {
//            print("ERROR")
//            fatalError()
//        }
//        accountCell.selectionStyle = .none
//        inAccurateCell.selectionStyle = .none
//        switch indexPath.section {
//        case 0:
//            let name = inAccurateCell.viewWithTag(1) as? UILabel
//            name?.text = popularIssues[indexPath.row]
//            return inAccurateCell
//        case 1:
//            let  helpTopic = accountCell.viewWithTag(2) as? UILabel
//            helpTopic?.text = helpTopics[indexPath.row]
//            return accountCell
//        default:
//            print("Do nothing")
//        }
//        return inAccurateCell
//    }
    
    // MARK: - TABLEVIEW
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let inAccurateCell = tableView.dequeueReusableCell(withIdentifier: "InaccurateCell") else {
            print("ERROR")
            fatalError()
        }
//        guard let accountCell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") else {
//            print("ERROR")
//            fatalError()
//        }
        
//        accountCell.selectionStyle = .none
        inAccurateCell.selectionStyle = .none
        let name = inAccurateCell.viewWithTag(1) as? UILabel
        name?.text = titles[indexPath.row]
        return inAccurateCell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem

        guard let supportDetailVC  = mainSB.instantiateViewController(withIdentifier: "FAQDetailVC") as? FAQDetailVC else {
            return
        }
        supportDetailVC.selectedIndex = Int(indexPath.row)
        supportDetailVC.titleText = titles[indexPath.row]
        self.navigationController?.pushViewController(supportDetailVC, animated: true)
        
//        switch indexPath.row {
//        case 0:
//            supportDetailVC.titleText = popularIssues[indexPath.row]
//            supportDetailVC.details = "The “Find My Car” feature relies on good GPS signal to provide accurate location of your car. Areas with poor GPS signal such as multi-storey or basement parking lots may affect the accuracy of the detected location"
//            self.navigationController?.pushViewController(supportDetailVC, animated: true)
//        case 1:
//            supportDetailVC.titleText = popularIssues[indexPath.row]
//            supportDetailVC.details = "MY VWDrive trips tracking relies on stable mobile internet connectivity, especially during trip start and trip end to properly log completed trips. In the event there is poor mobile internet connectivity, the trips will be updated as soon as there is stable connectivity"
//            self.navigationController?.pushViewController(supportDetailVC, animated: true)
//        default:
//            print("Nothing")
//        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view  = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
//        view.backgroundColor = UIColor.white
//        let sectionLabel = UILabel.init(frame: CGRect(x: 15, y: 20, width: tableView.bounds.width, height: 30))
//        sectionLabel.font = UIFont(name: "Montserrat-Bold", size: 14)
//        sectionLabel.textAlignment = .left
//        sectionLabel.textColor = UIColor(hexString: "#0073A4")
//        // Get Section Name
//        sectionLabel.text = sectionNames[section]
//
//        view.addSubview(sectionLabel)
        return view
    }
}
