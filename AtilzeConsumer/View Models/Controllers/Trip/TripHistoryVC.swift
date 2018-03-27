//
//  TripHistoryVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 31/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import NVActivityIndicatorView
import DZNEmptyDataSet
import Moscapsule
import Firebase

class TripHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    var month = 07
    var year = 2017
    var currentMonth = 01
    var currentYear = 2017
    var monthString = ["Jan", "Feb", "March", "April", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]
    var startDate : String?, endDate : String?
    var selectedMonth : String?
    var trips: [TripModelView] = [TripModelView]()
    var refreshControl: UIRefreshControl!
    var isFromDashBoard : Bool = false
    var enableEmptyData : Bool = false
    var startDateString : String = ""
    var endDateString : String = ""
    
    var cornering = [Double]()
    var speeding = [Double]()
    var hardBreaking = [Double]()
    var hardAccel = [Double]()
    
    var menuBtn: UIBarButtonItem?
    var drivingStatusView: UIView?
    var drivingStatusButton: UIButton?
    
    var selectedIndex : IndexPath?
    
    struct Topics {
        var gpsData : String
        var tripSummary : String
        var alert : String
    }
    
    var topics : Topics = Topics(gpsData: "", tripSummary: "", alert: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fetchDataFromFile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        updateDrivingStatus()
        navigationItem.rightBarButtonItem?.image = UIImage(named: "emergency")
        if !isFromDashBoard {
        } else {
            // FROM DASHBOARD
            navigationController?.navigationItem.backBarButtonItem?.title = ""
            navigationItem.leftBarButtonItem = nil
            navigationItem.hidesBackButton = false
        }
         // LEFT MENU
        if revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        }
        
        if Model.shared.isFromManualTracking {
            Model.shared.isFromManualTracking = false
             // PULL TO REFRESH
            setStartAndEndDates()
            getTrips()
        }
        guard selectedIndex != nil else {
            return
        }
        if trips.count > 0 {
            let tempTripsArray: [TripModelView] = trips
            let tempEle : Trip = tempTripsArray[selectedIndex?.row ?? 0].tripObj
            tempEle.reviewed = true
            let tempTripModelView : TripModelView = TripModelView(trip: tempEle)
            trips.remove(at: (selectedIndex?.row)!)
            trips.insert(tempTripModelView, at: (selectedIndex?.row)!)
           // tempTripsArray[selectedIndex?.row ?? 0].reviewed = true
           
            
        //    trips[selectedIndex?.row ?? 0].reviewed = true
            tableView.reloadRows(at: [selectedIndex ?? IndexPath()], with: .fade)
        }
    }
    func updateDrivingStatus() {
        if drivingStatusView == nil {
            drivingStatusView = UIView()
            drivingStatusView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20)
            drivingStatusView?.backgroundColor = GREEN
            //            drivingStatusView?.backgroundColor = .clear
            drivingStatusButton = UIButton(frame: CGRect(x: 25, y: 0, width: (drivingStatusView?.frame.width)! - 50, height: 20))
            drivingStatusButton?.addTarget(self, action: #selector(toTripTrackScreen), for: .touchUpInside)
            drivingStatusButton?.titleLabel?.lineBreakMode = .byWordWrapping
            drivingStatusButton?.titleLabel?.textAlignment = .center
            drivingStatusButton?.backgroundColor = .clear
            drivingStatusButton?.setTitle("Currently Driving,Tap to see live tracking", for: .normal)
            drivingStatusButton?.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 13)
            drivingStatusButton?.setTitleColor(.white, for: .normal)
            drivingStatusView?.addSubview(drivingStatusButton!)
            drivingStatusView?.alpha = 0.0
            drivingStatusButton?.alpha = 0.0
            self.view.addSubview(drivingStatusView ?? UIView())
            self.view.addSubview(drivingStatusButton ?? UIView())
        }
        drivingStatusView?.alpha = 0.0
        drivingStatusButton?.alpha = 0.0
        if Model.shared.isOngoingTrip {
            drivingStatusView?.alpha = 1.0
            drivingStatusButton?.alpha = 1.0
        }
    }
    
    func toTripTrackScreen() {
        tabBarController?.selectedIndex = 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    // MARK: - SETUP
    func setUpView() {
        // ADD OBSERVER
        NotificationCenter.default.addObserver(self, selector: #selector(fetchDataFromFile), name: NSNotification.Name(rawValue: "refreshTrips"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDrivingStatus), name: NSNotification.Name(rawValue: "updateDrivingStatus"), object: nil)
        // TABLE VIEW
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        // DATE
        let date = Date()
        let calendar = Calendar.current
        year = calendar.component(.year, from: date)
        month = calendar.component(.month, from: date)
        nextButton.isHidden = true

        dateLbl.text = monthString[month-1] + " \(year)"
        // REFRESH CONTROL
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.tintColor = UIColor.init(hexString: "00A3EA")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh() {
        if Utility.isConnectedToNetwork() {
        // flushPendingData()
        }
        // PULL TO REFRESH
        setStartAndEndDates()
        getTrips()
    }
    
    func fetchDataFromFile() {
        setStartAndEndDates()
        if Utility.isConnectedToNetwork() {
            refresh()
        } else {
            // CLEAR ALL TRIPS
            self.trips.removeAll()
            // FETCH TRIP DATA FROM FILE
            let storedData = Utility.readFromFile(fileName: FileNames.trips.rawValue)
            // CHECK TRIPS FOR THE SELECTED MONTH
            guard let status = storedData["status"] as? String, status == "OK", let tripsArray = storedData[startDateString] as? [[String : Any]] else {
                // STATUS == ERROR OR NO DATA - CALL API
                DispatchQueue.main.async {
                    self.getTrips()
                }
                return
            }
            //MAP TRIP DATA AND RELOAD TABLEVIEW
            DispatchQueue.main.async {
                self.loadTrips(tripsArray: tripsArray)
            }
        }
    }
    
    func setStartAndEndDates() {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date : Date! = calendar.date(from: dateComponents)
        let range = calendar.range(of: .day, in: .month, for: date)
        let numDays: Int! = range?.count
        let monthString = String(month).characters.count == 1 ? "0" + String(month) : String(month)
        startDateString = String(year) + "-\(monthString)-"  + "01" + "%2000:00:00"
        endDateString = String(year) + "-\(monthString)-" + String(numDays) + "%2023:59:59"
    }
    
    func getTrips() {
        if Utility.isConnectedToNetwork() {
            startAnimating(CGSize(width: 30, height: 30), message: "")
            // INTERNET CONNECTION AVAILABLE
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getTrips + "?" + "from_datetime=\(startDateString)&to_datetime=\(endDateString)"
            networkManager.getMethod(url, params: nil, success: { (response) in
                /* STOP LOADER */
                self.refreshControl.endRefreshing()
                self.stopAnimating()
                // CLEAR ALL TRIPS
                self.trips.removeAll()
                if let responseObj = response as? [String : Any], let tripsArray = responseObj["data"] as? [[String : Any]] {
                    guard tripsArray.count > 0 else {
                        // NO TRIPS AVAILABLE FOR THE SELECTED MONTH
                        DispatchQueue.global(qos: .background).async {
                            // UPDATE AN EMPTY ARRAY TO DB
                            Utility.storeToFile(fileName: FileNames.trips.rawValue, updateStatus: false, trips: tripsArray, date : self.startDateString)
                            
                        }
                        //RELOAD TABLEVIEW
                        self.enableEmptyData = true
                        self.tableView.reloadData()
                        return
                    }
                    // STORE TRIPS BASED ON SELECTED MONTH
                    DispatchQueue.global(qos: .background).async {
                        // UPDATE TRIPS ARRAY TO DB
                        Utility.storeToFile(fileName: FileNames.trips.rawValue, updateStatus: true, trips: tripsArray, date : self.startDateString)
                    }
                    //MAP TRIP DATA AND RELOAD TABLEVIEW
                    self.loadTrips(tripsArray: tripsArray)
                } else if let response = response as? [String : Any], let responseObj = response["error"] as? [String : Any], let error =  responseObj["error"] as? String {
                    if error == ErrorsFromAPI.tokenError.rawValue {
                        // CALL SUBSCRIPTION API
                        Utility.checkSubscription(viewController: self)
                    } else {
                        Utility.storeStaticDataToFile(fileName: ErrorMsgs.serverError, rawData: responseObj)
                    }
                } else {
                }
            }) { (error) in
                if self.refreshControl != nil{
                    self.refreshControl.endRefreshing()
                }
                self.stopAnimating()
                Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
            }
        } else {
            // NO INTERNET CONNECTION
            /* STOP LOADER */
            if self.refreshControl != nil {
                self.refreshControl.endRefreshing()
            }
            // CLEAR ALL TRIPS
            self.trips.removeAll()
            // FETCH TRIP DATA FROM FILE
            let storedData = Utility.readFromFile(fileName: FileNames.trips.rawValue)
            // CHECK TRIPS FOR THE SELECTED MONTH
            guard let status = storedData["status"] as? String, status == "OK", let tripsArray = storedData[startDateString] as? [[String : Any]] else {
                self.tableView.reloadData()
                return
            }
            //MAP TRIP DATA AND RELOAD TABLEVIEW
            loadTrips(tripsArray: tripsArray)
        }
    }
    
    func loadTrips(tripsArray : [[String : Any]]) {
        // USING FOR
        //                for index in 0...trips.count - 1 {
        //                    let item = Trip(data: trips[index])
        //                    self.trips.append(TripModelView(trip: item))
        //                }
        // USING MAP
        enableEmptyData = true
        self.trips = tripsArray.map {TripModelView(trip: Trip(data: $0))}
        //SCROL TO TOP AND RELOAD TABLE VIEW
        self.tableView.setContentOffset(.zero, animated: true)
        self.tableView.reloadData()
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
    
    @IBAction func nextMonthPressed(_ sender: Any) {
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
    
        year = month == 12 ? year + 1 : year
        month = month == 12 ? 0 : month
        month += 1
        
        if currentYear == year, currentMonth == month {
            nextButton.isHidden = true
        } else {
            nextButton.isHidden = false
        }
        
        dateLbl.text = monthString[month-1] + " \(year)"
        fetchDataFromFile()
    }
    
    @IBAction func prevMonthPressed(_ sender: Any) {
        nextButton.isHidden = false
        year = month == 1 ? year - 1 : year
        month = month == 1 ? 13 : month
        month -= 1
        dateLbl.text = monthString[month-1] + " \(year)"
        fetchDataFromFile()
    }
    
    // MARK: - TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tripCell = tableView.dequeueReusableCell(withIdentifier: "TripCell") as? TripCell else {
            print("ERROR")
            fatalError()
        }
        tripCell.selectionStyle = .none
        tripCell.startDate.text = trips[indexPath.row].startDate
//        tripCell.startAddress.text = trips[indexPath.row].startAddress
//        tripCell.endAddress.text = trips[indexPath.row].endAddress
        tripCell.distance.text = trips[indexPath.row].distance
        tripCell.duration.text = trips[indexPath.row].duration
        tripCell.fuel.text = (trips[indexPath.row].maxSpeed) + " " + "KM/H"
        tripCell.safetyScore.value = trips[indexPath.row].safetyScore
    
        tripCell.hardAccel.text = String(Int(trips[indexPath.row].otherScores[3]))
        tripCell.speeding.text = String(trips[indexPath.row].otherScores[2])
        tripCell.hardBraking.text = String(Int(trips[indexPath.row].otherScores[1]))
        tripCell.hardCornering.text = String(Int(trips[indexPath.row].otherScores[0]))
        
        tripCell.hardAccel.textColor = trips[indexPath.row].otherScores[3] > 0 ?  RED : .black
        tripCell.speeding.textColor = trips[indexPath.row].otherScores[2] > 0 ?  RED : .black
        tripCell.hardBraking.textColor = trips[indexPath.row].otherScores[1] > 0 ?  RED : .black
        tripCell.hardCornering.textColor = trips[indexPath.row].otherScores[0] > 0 ?  RED : .black
        
        tripCell.reviewBtn.isHidden = true
        if !trips[indexPath.row].reviewed {
            tripCell.reviewBtn.isHidden = false
        }
        
//        tripCell.backgroundColor = .red
//        if trips[indexPath.row].trackingMode.lowercased().contains("less") {
//             tripCell.backgroundColor = .white
//        }
        return tripCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // PHASE 2
        if !trips[indexPath.row].reviewed, Utility.isConnectedToNetwork() {
            selectedIndex = indexPath
        } else {
            selectedIndex = nil
        }
        
        Analytics.logEvent("Review_needed", parameters:nil)
        guard let tripSummaryVC  = mainSB.instantiateViewController(withIdentifier: "CurrentTripDetailsVC") as? TripSummaryVC else {
            return
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        // PASS SELECTED TRIP OBJECT TO DETAIL SCREEN
        tripSummaryVC.tripDetails = trips[indexPath.row]
        navigationController?.pushViewController(tripSummaryVC, animated: true)
    }
    
    // MARK: - DZN VIEW
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return nil
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String!
        text = "No Trips"
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

class TripCell: UITableViewCell {
     @IBOutlet weak var startDate: UILabel!
//    @IBOutlet weak var startAddress: UILabel!
//    @IBOutlet weak var endAddress: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var fuel: UILabel!
    @IBOutlet weak var safetyScore: MBCircularProgressBarView!
    @IBOutlet weak var speeding: UILabel!
    @IBOutlet weak var hardBraking: UILabel!
    @IBOutlet weak var hardCornering: UILabel!
    @IBOutlet weak var hardAccel: UILabel!
   @IBOutlet weak var reviewBtn: UIButton!
}
