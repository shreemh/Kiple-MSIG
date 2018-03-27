//
//  DashboardViewController.swift
//  AtilzeConsumer
//
//  Created by Sreejith on 24/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import SWRevealViewController

class DashboardViewController: UIViewController {
    @IBOutlet weak var activeIcon: UIView!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var lastDetectedLabel: UILabel!
    @IBOutlet var statusLabelCollection: [UILabel]!
    @IBOutlet var lastTripsButtonColletction: [UIButton]!
    @IBOutlet weak var todayDateLabel: UILabel!
    @IBOutlet weak var safetyScoreChart: MBCircularProgressBarView!
    @IBOutlet var otherChartViewCollection: [MBCircularProgressBarView]!
    @IBOutlet var averageLabelCollection: [UILabel]!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentTripData: [[String: Any]] = [[String: Any]]()
    var lastWeekTripData: [[String: Any]] = [[String: Any]]()
    var lastMonthTripData: [[String: Any]] = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        setUpView()
        
        fetchLastTripData()
        fetchLast7DaysTripData()
        fetchLast30DaysTripData()
    }
    override func viewWillAppear(_ animated: Bool) {
    UINavigationBar.appearance().tintColor = UIColor.white
    }
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationItem.hidesBackButton = true
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: - SETUP
    func setUpView() {
        //MENU
        if revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        // TRIP BUTTONS
        for (index, button) in lastTripsButtonColletction.enumerated() {
            let buttonView = UIView()
            buttonView.backgroundColor = UIColor.init(hexString: "00A2ED")
            buttonView.tag = index + 100
            if index == 0 {
                buttonView.alpha = 1
            } else {
                buttonView.alpha = 0
            }
            buttonView.frame = CGRect(x: 15, y: button.frame.height - 4, width: button.frame.width - 30, height: 4)
            button.addSubview(buttonView)
        }
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    // MARK: - API Calls
    
    func getVehicleStatus() {
        //        let getVehicleStatusURL = Constants.ServerAddress.baseURL + Constants.APIEndPoints.status + "?token=\(Utility().getToken())&user_id=\(Utility().getEmail())"
        //        networkManager.getMethod(getVehicleStatusURL, params: nil, success: { (response) in
        //            print("getVehicleStatus *** \(String(describing: response))")
        //        }) { (error) in
        //            print("error *** \(error)")
        //        }
    }
    
    func fetchLastTripData() {
        let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getTripSummary + Utility().getEmail() + "?"
        networkManager.getMethod(url, params: nil, success: { (response) in
            print("response *** \(String(describing: response)) \n \n \n")
            if let responseData = response as? [String: Any], let lastTrip = responseData["range_last_trip"] as? [String : Any] {
                self.currentTripData = [lastTrip]
                self.setCircularProgressBar(tripData: self.currentTripData)
            }
        }) { (error) in
            print("error *** \(error)")
        }
    }
    
    func fetchLast7DaysTripData() {
        // shreeee
        let from7DaysCal: Date! = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let today = Date()
        let toDateTime = getTripDate(date: today)
        let fromDateTime = getTripDate(date: from7DaysCal)
        
        let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getTrips + Utility().getEmail() + "?" + "from_datetime=\(fromDateTime)&to_datetime=\(toDateTime)"
        
        networkManager.getMethod(url, params: nil, success: { (response) in
            print("fetchLast7DaysTripData *** \(String(describing: response)) \n \n \n")
            if let responseData = response as? [[String: Any]] {
                self.lastWeekTripData = responseData
            }
        }) { (error) in
            print("error *** \(error)")
        }
    }
    
    func fetchLast30DaysTripData() {
        let from7DaysCal: Date! = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        let today = Date()
        let toDateTime = getTripDate(date: today)
        let fromDateTime = getTripDate(date: from7DaysCal)
        let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getTrips + Utility().getEmail() + "?" + "from_datetime=\(fromDateTime)&to_datetime=\(toDateTime)"
        networkManager.getMethod(url, params: nil, success: { (response) in
            print("lastMonthTripData *** \(String(describing: response)) \n \n \n")
            if let responseData = response as? [[String: Any]] {
                self.lastMonthTripData = responseData
            }
        }) { (error) in
            print("error *** \(error)")
        }
    }
    func getTripDate(date : Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd%20HH:mm:ss"
        let formattedDate:String = formatter.string(from: date)
        return formattedDate
    }
    // MARK: - UIBUTTON ACTIONS
    @IBAction func menuBtnCall(_ sender: Any) {
        if revealViewController() != nil {
            revealViewController().revealToggle(animated: true)
        }
    }
    
    // MARK: - Set ProgressBar
    func setCircularProgressBar(tripData: [[String: Any]]) {
        revealViewController().rearViewRevealWidth = (2 * UIScreen.main.bounds.width) / 3
        
        /// Safety Score
        if let safetyScoreArray = tripData.flatMap({ $0["safety_score"] }) as? [NSNumber] {
            let safetyDoubleArray = safetyScoreArray.map({ Double($0) })
            if safetyScoreArray.count > 0 {
                let average = Double(safetyDoubleArray.reduce(0, +)) / Double(safetyDoubleArray.count)
                safetyScoreChart.value = CGFloat(average)
            } else {
                safetyScoreChart.value = 0
            }
        }
        
        /// Hard Accel
        if let harshAccDoubleArray = tripData.flatMap({ $0["harsh_accel"] }) as? [Double] {
            let average = Double(harshAccDoubleArray.reduce(0, +)) / Double(harshAccDoubleArray.count)
            if let view = otherChartViewCollection.filter({ $0.tag == 10 }).first {
                view.value = CGFloat(average) > 0 ? CGFloat(average) : 0
            }
        }
        
        /// Hard Braking
        if let hardBrakingDoubleArray = tripData.flatMap({ $0["harsh_break"] }) as? [Double] {
            let average = Double(hardBrakingDoubleArray.reduce(0, +)) / Double(hardBrakingDoubleArray.count)
            if let view = otherChartViewCollection.filter({ $0.tag == 8 }).first {
                view.value = CGFloat(average) > 0 ? CGFloat(average) : 0
            }
        }
        
        /// Speeding Count
        if let speedingCountDoubleArray = tripData.flatMap({ $0["speeding_count"] }) as? [Double] {
            let average = Double(speedingCountDoubleArray.reduce(0, +)) / Double(speedingCountDoubleArray.count)
            if let view = otherChartViewCollection.filter({ $0.tag == 9 }).first {
                view.value = CGFloat(average) > 0 ? CGFloat(average) : 0
            }
        }
        
        /// Total Distance
        var totalDistance = 0.0
        if let totalDistanceArray = tripData.flatMap({ $0["distance"] }) as? [NSNumber] {
            let totalDistanceDoubleArray = totalDistanceArray.map({ Double($0) })
            totalDistance = Double(totalDistanceDoubleArray.reduce(0, +))
            if let label = averageLabelCollection.filter({ $0.tag == 11 }).first {
                label.text = String(describing: totalDistance) + " km"
            }
        }
        
        /// Total Fuel Consumption/ Efficiency
        if let totalFuelConsumption = tripData.flatMap({ $0["driving_fuel_consumption"] }) as? [NSNumber] {
            let totalFuelConsumptionDoubleArray = totalFuelConsumption.map({ Double($0) })
            let totalFuel = Double(totalFuelConsumptionDoubleArray.reduce(0, +))
            let efficiencyAvg = totalFuel > 0 ? (100 / totalDistance) * totalFuel : 0
            if let label = averageLabelCollection.filter({ $0.tag == 13 }).first {
                label.text = String(format: "%.2f", efficiencyAvg) + "/100"
            }
            let average = totalFuel > 0 ? totalFuel / Double(totalFuelConsumption.count) : 0
            if let avgLabel = averageLabelCollection.filter({ $0.tag == 12 }).first {
                avgLabel.text = String(format:"%.2f", average) + " min"
            }
        }
    }
    
    // MARK: - Button Presses
    
    @IBAction func locateMyCarPressed(_ sender: Any) {
    }
    
    @IBAction func seeTripHistoryPressed(_ sender: Any) {
        // GO TO TripHistoryVC
        if let tripsVC = mainSB.instantiateViewController(withIdentifier: StoryBoardVC.trip) as? TripHistoryVC {
            navigationController?.pushViewController(tripsVC, animated: true)
        }
    }
    
    @IBAction func lastTripBtnCall(_ sender: Any) {
        
        /// Set Progressbar Data
        self.setCircularProgressBar(tripData: currentTripData)
        
        for (index, button) in lastTripsButtonColletction.enumerated() {
            if index == 0 {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "80888B"), for: .normal)
            } else {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "A7ACAE"), for: .normal)
            }
            for view in button.subviews {
                if view.tag == 100 {
                    view.alpha = 1
                } else if view.tag == 101 || view.tag == 102 {
                    view.alpha = 0
                }
            }
        }
    }
    @IBAction func last7daysBtnCall(_ sender: Any) {
        
        /// Set Progressbar Data
        self.setCircularProgressBar(tripData: lastWeekTripData)
        
        for (index, button) in lastTripsButtonColletction.enumerated() {
            if index == 1 {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "80888B"), for: .normal)
            } else {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "A7ACAE"), for: .normal)
            }
            for view in button.subviews {
                if view.tag == 101 {
                    view.alpha = 1
                } else if view.tag == 100 || view.tag == 102 {
                    view.alpha = 0
                }
            }
        }
    }
    @IBAction func last30daysBtnCall(_ sender: Any) {
        
        /// Set Progressbar Data
        self.setCircularProgressBar(tripData: lastMonthTripData)
        
        for (index, button) in lastTripsButtonColletction.enumerated() {
            if index == 2 {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "80888B"), for: .normal)
            } else {
                lastTripsButtonColletction[index].setTitleColor(UIColor.init(hexString: "A7ACAE"), for: .normal)
            }
            for view in button.subviews {
                if view.tag == 102 {
                    view.alpha = 1
                } else if view.tag == 101 || view.tag == 100 {
                    view.alpha = 0
                }
            }
        }
    }
}

extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let speedLimit = cell.viewWithTag(4) as? UILabel
        speedLimit?.attributedText = Utility().attributedText(completeText: "100KM/H", primaryText: "100", secondaryText: "KM/H")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 165, height: 160)
    }
}

class DashboardAlertsCell: UICollectionViewCell {
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var speedLimitLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
}
