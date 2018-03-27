//
//  FAQDetailVC.swift
//  AtilzeConsumer
//
//  Created by Cognitive on 30/12/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class FAQDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var selectedIndex : Int?
    var titleText : String?
    let accManagementQuestionArray : [String] = ["1.Can I have multiple users on one account?","2.How do I set/change my emergency contact information?","3.How do I edit my account information?", "4.How do I change my password?", "5.I forgot my password! Where can I change it?"]
    let accManagementAnswerArray : [String] = ["Unfortunately, no. ConnectedCar currently only supports one user per account.", "In the app, head over to the Settings section and tap on the Emergency Contact tab to edit the emergency contact information.","In the app, head over to the Settings section and tap on the information you would like to change. You will be brought to a page that allows you to edit that information.", "In the app, head over to the Settings section and tap on the password tab. You will be brought to a page to change your password. Enter your current password as well as your new password and click “Save” to change the password.", "In the login section of the ConnectedCar app, click on the “Forgot Password” to be redirected to the “forgot password” section. Key in your registered e-mail and click “Next”. An activation code will be sent to your registered e-mail which you will need to key into the app. You will then be asked to enter your new password and confirm it."]
    
    let driveTrackQuestionsArray : [String] = ["1.Do I need to turn on ConnectedCar every time I want to track my trip?", "2.Does ConnectedCar require my phone’s GPS to be switched on?", "3.How do I start/end a trip?", "4.How is my driver score calculated?"]
    let driveTrackAnswersarray : [String] = ["Yes, in order to completely track your trip, ConnectedCar has to remain active for the entire trip duration (either in the foreground/background).", "Yes, ConnectedCar requires your GPS to be active at all times while using the app.", "ConnectedCar will automatically detect if a trip is taking place and begin a new trip as well as end the trip when it detects the trip has ended (ex: no movement detected for 5 minutes).\n Note: In order for ConnectedCar to automatically track your trips, the app has to be active at all times (either in the foreground/background).", "The driver score is calculated using our own algorithm that assesses your driving behaviour based on the following criterias: Speeding, Hard Breaking, Hard Acceleration, Hard Cornering and Duration of the Trip."]
    
    let obdQuestionArray : [String] = ["1.What is OBD II?", "2.Can I switch my OBD device to another car?", "3.'Locate My' Car location is inaccurate/not working", "4.My last trip is not showing (even after I switched off my car’s engine)", "5.What does the “Warning” signs mean on my car status?"]
    let obdAnswersArray : [String] = ["OBD stands for On-Board Diagnostics. The OBD device is used to control engine functions and diagnose engine problems. OBD II is the new standard introduced in mid-‘90s, which provides almost complete engine control and monitors part of the chassis, body and accessory devices as well as the diagnostic control network of the car.", "No, an OBD device cannot be transferred to another user’s car", "The “Locate My Car” feature relies on having a strong GPS signal in order to provide an accurate location of your car. Poor GPS signal areas such as a basement parking or multi-storey building may be the cause of inaccuracy in the detected location", "ConnectedCar's OBD tracking relies on a strong GPS signal as well as a stable mobile internet connectivity. This is especially important during the start and end points of a trip in order to properly log the completed trips. If there is ever poor signal connectivity, the trip will be updated as soon as the device can establish a stable connection again.", "The warning signs are displayed in the car status section if the temperature/battery/engine’s value has exceeded the threshold of the car within the past 7 days. We strongly advise you to get your car checked as soon as possible to prevent any unwanted malfunctions. Once your issue has been resolved, you can clear the warning sign for that issue by clicking the “Resolved” button in the car status"]
    
    let othersQuestionsArray : [String] = ["1.How does the Emergency Assistance feature work?", "2.Where can I submit an issue/feedback?"]
    let otherAnswersArray : [String] = ["Basically, the Emergency Assistance contains several assistance options for you to use. After selecting an option, a request will be sent to our support team along with your coordinates. A representative will then contact and assist you in your matters.", "All comments/issues/feedback can be sent to 'support@atilze.com' and a representative will respond to your request as soon as possible."]
    
    var questionsArray : [String] = [String]()
    var answersArray : [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    // MARK: - SETUP
    func setUp() {
        tableView.tableFooterView = UIView()
        if selectedIndex == 0 {
            questionsArray = accManagementQuestionArray
            answersArray = accManagementAnswerArray
            self.title = titleText
        } else if selectedIndex == 1 {
            questionsArray = driveTrackQuestionsArray
            answersArray = driveTrackAnswersarray
            self.title = titleText
        } else if selectedIndex == 2 {
            questionsArray = obdQuestionArray
            answersArray = obdAnswersArray
            self.title = titleText
        } else {
            questionsArray = othersQuestionsArray
            answersArray = otherAnswersArray
            self.title = titleText
        }
    }
    
    // MARK: - TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell") else {
            print("ERROR")
            fatalError()
        }
        cell.selectionStyle = .none
        let question = cell.viewWithTag(1) as? UILabel
        let answer = cell.viewWithTag(2) as? UILabel
        question?.text = questionsArray[indexPath.row]
        answer?.text = answersArray[indexPath.row]
        return cell
    }
}
