//
//  CarStatusAlertsVC.swift
//  AtilzeConsumer
//
//  Created by Cognitive on 09/01/18.
//  Copyright © 2018 Cognitive. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class CarStatusAlertsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    @IBOutlet weak var tableView: UITableView!
    var alertsArray: [AlertsViewModel] = [AlertsViewModel]()
    var islast7DaysAlerts : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    // MARK: - SETUP
    func setUpView() {
        var titleText: String = "Car System Alerts Log"
        if islast7DaysAlerts {
            titleText = "Engine Alerts"
        }
        self.title = titleText
            
        // TABLE VIEW
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.islast7DaysAlerts, alertsArray.count > 0 {
                return alertsArray.count + 1
        }
        return alertsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let alertCell = tableView.dequeueReusableCell(withIdentifier: "EngineCell") else {
            print("ERROR")
            fatalError()
        }
        
        guard let last7DaysLabelCell = tableView.dequeueReusableCell(withIdentifier: "last7DaysAlerts") else {
            print("ERROR")
            fatalError()
        }
        
        alertCell.selectionStyle = .none
        last7DaysLabelCell.selectionStyle = .none
        let image = alertCell.viewWithTag(1) as? UIImageView
        let time = alertCell.viewWithTag(2) as? UILabel
        let message = alertCell.viewWithTag(3) as? UILabel
        let status = alertCell.viewWithTag(4) as? UIImageView
        
        if islast7DaysAlerts {
            if indexPath.row == 0 {
                return last7DaysLabelCell
            } else {
                image?.image = UIImage(named: alertsArray[indexPath.row - 1].image)
                time?.text = alertsArray[indexPath.row - 1].date
                message?.text = alertsArray[indexPath.row - 1].message
                status?.isHidden = true
                if alertsArray[indexPath.row - 1].status.lowercased() == "unread" {
                    status?.isHidden = false
                }
                return alertCell
            }
        } else {
            image?.image = UIImage(named: alertsArray[indexPath.row].image)
            time?.text = alertsArray[indexPath.row].date
            message?.text = alertsArray[indexPath.row].message
            status?.isHidden = true
            if alertsArray[indexPath.row].status.lowercased() == "unread" {
                status?.isHidden = false
            }
        }
        return alertCell
    }
    
    // MARK: - DZN VIEW
  //  - (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView;
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "noAlert")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String!
        text = "No alert right now"
        let attributed = NSMutableAttributedString(string: text)
        let font = UIFont(name: "Montserrat-Bold", size: 16)
        attributed.addAttributes([NSForegroundColorAttributeName: UIColor.black], range: NSRange(location: 0, length: attributed.length))
        attributed.addAttributes([NSFontAttributeName : font ?? UIFont()], range: NSRange(location: 0, length: attributed.length))
        return attributed
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String!
        if islast7DaysAlerts {
            text = "Everything is looking good!\nThere’s no alert for the past 7 days.\n\n\n\nTap Car System Alerts Log\nto view past alerts."
            
            let attributed = NSMutableAttributedString(string: text)
            let font = UIFont(name: "Montserrat-Regular", size: 14)
            attributed.addAttributes([NSFontAttributeName : font ?? UIFont()], range: NSRange(location: 0, length: attributed.length))
            
            attributed.addAttributes([NSForegroundColorAttributeName: UIColor.gray], range: NSRange(location: 0, length: attributed.length-42))
            
            attributed.addAttributes([NSForegroundColorAttributeName: BLUE], range: NSRange(location: attributed.length-42, length: 17))
            return attributed
        } else {
            text = "Everything is looking good"
            let attributed = NSMutableAttributedString(string: text)
            let font = UIFont(name: "Montserrat-Regular", size: 14)
            attributed.addAttributes([NSFontAttributeName : font ?? UIFont()], range: NSRange(location: 0, length: attributed.length))
            return attributed
        }
    
        
    }
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor(hexString: "F3F3F3")
    }
    // MARK: - DZNEmptyDataSetDelegate Methods
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

}
