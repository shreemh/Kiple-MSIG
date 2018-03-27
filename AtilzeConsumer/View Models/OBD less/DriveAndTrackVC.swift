//
//  DriveAndTrackVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 17/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AFNetworking

class DriveAndTrackVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var GPSSignalLbl: UILabel!
  // shreeee  let locationManager = CLLocationManager()
    var signalStrength: String = ""
    var lastSignalStrength: String = ""
    var menuBtn: UIBarButtonItem?
    var flag : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem?.image = UIImage(named: "emergency")
        setUp()
    }
    
    enum GPSSignalStatus: String {
        case low = "Low"
        case weak = "Weak"
        case accurate = "Accurate"
    }
    enum GPSSignalMsgs: String {
        case low = "No GPS Signal\n GPS signal is required to start the tracking. Try moving to a location with better reception."
        case weak = "Weak GPS Signal\n Weak signal might affect accuracy of the tracking. Try moving to a location with better reception."
        case accurate = "GPS Signal Acquired"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Model.shared.isOngoingTrip = false
    }
    override func viewWillAppear(_ animated: Bool) {
//        let accountType = Utility.getLoginMode()
//        if accountType == "OBDless" {
//            menuBtn = self.navigationItem.leftBarButtonItem
//            self.navigationItem.leftBarButtonItem = nil
//        } else {
//            if self.navigationItem.leftBarButtonItem == nil { self.navigationItem.leftBarButtonItem = menuBtn }
//        }
        // MENU
        if revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        }
    }
    
    // MARK: - SETUP
    func setUp() {
        startBtn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
       // locationManager.delegate = self
//        UserLocation.sharedInstance.locationManager?.delegate = self
//        UserLocation.sharedInstance.locationManager?.startUpdatingLocation()
//        mapView.showsUserLocation = true
//
//        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//            // mapView.showsUserLocation = true
//        } else {
//            UserLocation.sharedInstance.locationManager?.requestWhenInUseAuthorization()
////            UserLocation.sharedInstance.locationManager?.requestAlwaysAuthorization()
//        }
//
      
    }
    
    // MARK: - USER LOCATION
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            UserLocation.sharedInstance.locationManager?.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            UserLocation.sharedInstance.locationManager?.startUpdatingLocation()
            break
        case .authorizedAlways:
            UserLocation.sharedInstance.locationManager?.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            startBtn.isEnabled = false
            startBtn.backgroundColor = GRAY
            // user denied your app access to Location Services, but can grant access from Settings.app
            if CLLocationManager.locationServicesEnabled() {
                // Location services are Disabled -- for this APP
                if self.presentedViewController == nil {
                    openSettings()
                }
            } else {
                // Location services are Disabled -- iPhone // prefs URL Scheme not working ON iOS 10
                let alertController = UIAlertController (title: "Location Sevices Disabled", message: "Please enable location services on settings screen.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
            break
        }
    }
    
    func openSettings() {
        let uiAlert = UIAlertController(title: "Location not authorised", message: "Looks like you have turned off your location. Please turn on the location", preferredStyle: .alert)
        uiAlert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler: { action in
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    print("open URL ---- success")
                })
            }
        }))
        
        uiAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            print("Click of cancel button")
        }))
        self.present(uiAlert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if flag {
//            let span = MKCoordinateSpanMake(0.01, 0.01)
//            let region1 = MKCoordinateRegion(center: (UserLocation.sharedInstance.locationManager?.location?.coordinate)!, span: span)
//            self.mapView.setRegion(region1, animated: true)
//            flag = false
//        }
        
        mapView.setUserTrackingMode(.follow, animated:true)
        
        let signalStrength = checkSignalStregth()
        guard lastSignalStrength != signalStrength else {
            return
        }

        GPSSignalLbl.alpha = 1.0
        
        switch signalStrength {
        case GPSSignalStatus.low.rawValue:
            startBtn.isEnabled = false
            startBtn.backgroundColor = GRAY
            GPSSignalLbl.text = GPSSignalMsgs.low.rawValue
            GPSSignalLbl.backgroundColor = BLUE
            return
        case GPSSignalStatus.weak.rawValue:
            startBtn.isEnabled = true
            startBtn.backgroundColor = BLUE
            GPSSignalLbl.text = GPSSignalMsgs.weak.rawValue
            GPSSignalLbl.backgroundColor = ORANGE
            return
        default:
            startBtn.isEnabled = true
            startBtn.backgroundColor = BLUE
            GPSSignalLbl.text = GPSSignalMsgs.accurate.rawValue
            GPSSignalLbl.backgroundColor = GREEN
            UIView.animate(withDuration: 2.0, animations: {
                self.GPSSignalLbl.alpha = 0.0
            })
            return
        }
    }
    
    func checkSignalStregth() -> String {
        // shreeee
        // PDOP, HDOP, VDOP
        //        3m is very  good
        //        6m is good
        //        10m not so good
        //        > 20m bad
        let locAccuracy: Double = UserLocation.sharedInstance.locationManager?.location?.horizontalAccuracy ?? -1
        lastSignalStrength = signalStrength
        if locAccuracy < 0.0 {
            signalStrength = GPSSignalStatus.low.rawValue
            return signalStrength
            // No Signal
        } else if locAccuracy > 48.0 {
            signalStrength = GPSSignalStatus.weak.rawValue
            return signalStrength
            // Average Signal
        } else {
            signalStrength = GPSSignalStatus.accurate.rawValue
            return signalStrength
            // Full Signal
        }
    }
    
    // MARK: - UIBUTTON ACTIONS
    @IBAction func startBtnCall(_ sender: Any) {
        Model.shared.isOngoingTrip = true
        if let tripTrackingVC = mainSB.instantiateViewController(withIdentifier: StoryBoardVC.tripTracking) as? TripTrackingVC {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            backItem.image = UIImage()
            self.navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(tripTrackingVC, animated: true)
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
}
