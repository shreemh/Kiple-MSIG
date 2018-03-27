//
//  NotificationsVCNew.swift
//  AtilzeConsumer
//
//  Created by Shree on 09/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import DZNEmptyDataSet

class NotificationsVCNew: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    @IBOutlet weak var notificationsTableView: UITableView!
    var notificationsArray = [NotificationModelView]()
    var timestampString: String?
    var refreshControl: UIRefreshControl!
    var retryCount: Int = 0
    var enableEmptyData : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fetchDataFromFile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        // MENU
        if revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        }
    }
    
    // MARK: - SETUP
    func setUpView() {
        // TABLE VIEW
        notificationsTableView.estimatedRowHeight = 100.0
        notificationsTableView.rowHeight = UITableViewAutomaticDimension
        notificationsTableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem?.image = UIImage(named: "emergency")
//        // MENU
//        if revealViewController() != nil {
//            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
//        }
        // ADD OBSERVER
        NotificationCenter.default.addObserver(self, selector: #selector(fetchDataFromFile), name: NSNotification.Name(rawValue: "refreshNotifications"), object: nil)
        
        // REFRESH CONTROL
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.tintColor = UIColor.init(hexString: "00A3EA")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        notificationsTableView.addSubview(refreshControl)
    }
    func refresh(sender:AnyObject) {
        // PULL TO REFRESH
        getNotifications()
    }
    
    func fetchDataFromFile() {
        // FETCH ALERTS FROM FILE
        let storedData = Utility.readFromFile(fileName: FileNames.notifications.rawValue)
        // CHECK TRIPS FOR THE SELECTED MONTH
        if let status = storedData["status"] as? String, status == "OK", let alertsDict = storedData["data"] as? [String : Any], let notificationsArray = alertsDict["notifications"] as? [[String : Any]] {
            loadNotifications(notifications : notificationsArray)
        } else {
            // STATUS == ERROR OR NO DATA - CALL API
            getNotifications()
        }
    }
    
    // MARK: - Get Notification
    func getNotifications() {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getNotifications + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                /* STOP LOADER */
                self.refreshControl.endRefreshing()
                if let responseObj = response as? [String : Any], let result = responseObj["data"] as? [ String : Any], let notificationsArray = result["notifications"] as? [[String : Any]], let count = result["unread_count"] as? Int {
                    DispatchQueue.global(qos: .background).async {
                        // UPDATE TO DB
                        Utility.storeStaticDataToFile(fileName: FileNames.notifications.rawValue, rawData: result)
                    }
                    self.loadNotifications(notifications: notificationsArray)
                    guard count > 0 else {
                        return
                    }
                    self.markAsRead()
                } else if let response = response as? [String : Any], let responseObj = response["error"] as? [String : Any], let error =  responseObj["error"] as? String {
                    if error == ErrorsFromAPI.tokenError.rawValue {
                        // CALL SUBSCRIPTION API
                        Utility.checkSubscription(viewController: self)
                    } else {
                        Utility.storeStaticDataToFile(fileName: ErrorMsgs.serverError, rawData: responseObj)
                    }
                }
            }) { (error) in
                print("error *** \(error)")
            }
        } else {
            if self.refreshControl != nil{
                self.refreshControl.endRefreshing()
            }
            // FETCH ALERTS FROM FILE
            let storedData = Utility.readFromFile(fileName: FileNames.notifications.rawValue)
            // CHECK TRIPS FOR THE SELECTED MONTH
            guard let status = storedData["status"] as? String, status == "OK", let alertsDict = storedData["data"] as? [String : Any], let notificationsArray = alertsDict["notifications"] as? [[String : Any]] else {
                return
            }
            self.loadNotifications(notifications : notificationsArray)
           // Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }
    
    func loadNotifications(notifications : [[String : Any]]) {
        enableEmptyData = true
        self.notificationsArray.removeAll()
        guard notifications.count > 0 else {
            self.notificationsTableView.reloadData()
            return
        }
        for index in 0...notifications.count - 1 {
            let notification = Notification(data: notifications[index])
            self.notificationsArray.append(NotificationModelView(notification: notification))
        }
        self.notificationsTableView.reloadData()
    }
    
    func markAsRead() {
        guard retryCount <= 1 else {
            return
        }
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.markNotificationsAsRead + "?"
            networkManager.putMethod(url, params: nil, success: { (response) in
                self.stopAnimating()
                guard let res = response as? [String : Any], res["error"] == nil else {
                    self.retryCount = self.retryCount + 1
                    self.markAsRead()
                    return
                }
                Model.shared.unreadNotificationsCount = 0
                self.getNotifications()
            }) { (error) in
                print("error *** \(error)")
                self.stopAnimating()
                self.retryCount =  self.retryCount + 1
                self.markAsRead()
            }
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func menuBtnCall(_ sender: Any) {
        if revealViewController() != nil {
            revealViewController().revealToggle(animated: true)
        }
    }
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
    // MARK: - TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell") as? NotificationsCell else {
            print("ERROR")
            fatalError()
        }
        cell.selectionStyle = .none
        //        let timeAgo = cell.viewWithTag(1) as? UILabel
        //        let message = cell.viewWithTag(2) as? UILabel
        //        let redDotImageView = cell.viewWithTag(3) as? UIImageView
        //        timeAgo?.text = notificationsArray[indexPath.row].dateSent
        //        message?.text = notificationsArray[indexPath.row].message
        //        redDotImageView?.isHidden = false
        //        if notificationsArray[indexPath.row].status.lowercased() == "read" {
        //            redDotImageView?.isHidden = true
        //        }
        cell.title.text = notificationsArray[indexPath.row].dateSent
        cell.message.text = notificationsArray[indexPath.row].message
        
        if notificationsArray[indexPath.row].status.lowercased() == "read" {
            cell.redDot.isHidden = true
            cell.leadingSpaceConstraint.constant = 15.0
        } else {
            cell.redDot.isHidden = false
            cell.leadingSpaceConstraint.constant = 24.0
        }
        return cell
    }
    
    // MARK: - DZN VIEW
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return nil
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String!
        text = "No Notifications"
        let attributed = NSAttributedString(string: text)
        return attributed
    }
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    // MARK: - DZNEmptyDataSetDelegate Methods
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if enableEmptyData {
            return true
        }
        return false
    }
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
class NotificationsCell: UITableViewCell {
    @IBOutlet weak var redDot: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var leadingSpaceConstraint: NSLayoutConstraint!
}
