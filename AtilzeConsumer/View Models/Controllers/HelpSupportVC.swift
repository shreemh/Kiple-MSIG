//
//  HelpSupportVC.swift
//  AtilzeCunsumer
//
//  Created by Adarsh on 22/09/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class HelpSupportVC: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var callUsTapped: UIButton!
    
    var popularIssues = ["Inaccurate location of my car","Trips are not recorded","App is freezing/Crashing"]
    var helpTopics = ["Account and setup","trobleshoot app","A guide to KipleCar","Report an issue"]
    let topic = ["Popular Issues","Helper Topics"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func callUsTapped(_ sender: Any) {
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return topic.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 3
            break
        case 1:
            return 4
            break
            
        default:
            print("Do nothing")
        }
        return 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let inAccurateCell = tableView.dequeueReusableCell(withIdentifier: "InaccurateCell") else {
            print("ERROR")
            fatalError()
        }
        guard let accountCell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") else {
            print("ERROR")
            fatalError()
        }
        accountCell.selectionStyle = .none
        inAccurateCell.selectionStyle = .none
        
        //  let selectSection = topic[indexPath.section]
        
        switch indexPath.section {
        case 0:
            let name = inAccurateCell.viewWithTag(1) as? UILabel
            
            name?.text = popularIssues[indexPath.row]
            
            return inAccurateCell
            
        case 1:
            let  helpTopic = accountCell.viewWithTag(2) as? UILabel
            helpTopic?.text = helpTopics[indexPath.row]
            
            return accountCell
            
        default:
            print("Do nothing")
            
        }
        
        return inAccurateCell

    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            guard let  tripsAreNotRecorder  = secondSB.instantiateViewController(withIdentifier: "TripsNotVC") as? TripsNotVC else {
                return
            }
            self.navigationController?.pushViewController(tripsAreNotRecorder, animated: true)
        case 1:
            guard let  tripsAreNotRecorder  = secondSB.instantiateViewController(withIdentifier: "TripsNotVC") as? TripsNotVC else {
                return
            }
            self.navigationController?.pushViewController(tripsAreNotRecorder, animated: true)
            
        default:
            print("Nothing")
        }
 
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view  = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        view.backgroundColor = UIColor.white
        
        let sectionLabel = UILabel.init(frame: CGRect(x: 15, y: 20, width: tableView.bounds.width, height: 30))
        sectionLabel.font = UIFont(name: "Montserrat-Bold", size: 14)
        sectionLabel.textAlignment = .left
        sectionLabel.textColor = UIColor(hexString: "#0073A4")
        
        // Get Section Name
        
        sectionLabel.text = topic[section]
        
        view.addSubview(sectionLabel)
        
        return view
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
