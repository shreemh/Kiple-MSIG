//
//  UserLocation.swift
//  AtilzeConsumer
//
//  Created by Shree on 26/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationServiceDelegate {
    func tracingLocation(currentLocation: CLLocation, GPSSignal: String)
    func tracingLocationDidFailWithError(error: NSError)
}

class UserLocation: NSObject, CLLocationManagerDelegate {
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
    var signalStrength: String = ""
    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var delegate: LocationServiceDelegate?
    
    static let sharedInstance: UserLocation = UserLocation()
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        
        //        guard let locationManagers = self.locationManager else {
        //            return
        //        }
        
        //        if CLLocationManager.authorizationStatus() == .notDetermined {
        //           // locationManagers.requestAlwaysAuthorization()
        //            locationManagers.requestWhenInUseAuthorization()
        //        }
        //        locationManagers.allowsBackgroundLocationUpdates = true
//        locationManagers.desiredAccuracy = kCLLocationAccuracyBest
//        locationManagers.distanceFilter = CLDistanceFilterNone
        //        locationManagers.pausesLocationUpdatesAutomatically = false
        //        locationManagers.distanceFilter = 50
        
        self.locationManager?.delegate = self
//        self.locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.distanceFilter = kCLDistanceFilterNone
        //locationManager?.startMonitoringSignificantLocationChanges()
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        self.locationManager?.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) {
            self.locationManager?.showsBackgroundLocationIndicator = false
        } else {
            // Fallback on earlier versions
        }
        self.startUpdatingLocation()
      //   locationManager?.startUpdatingLocation()
    }
    
    //    //MARK:- SHREEEE
    //    func locationSetUp() {
    //        let locationManager = CLLocationManager()
    //        if CLLocationManager.locationServicesEnabled() {
    
    //            locationManager.startUpdatingLocation()
    //            switch(CLLocationManager.authorizationStatus()) {
    //
    //            case .notDetermined, .restricted, .denied:
    //                print("No access") // Location services are Disabled -- for this APP
    //                enableLocationService()
    //
    //            case .authorizedAlways, .authorizedWhenInUse:
    //                print("Access")
    //            }
    //        } else {
    //            // Location services are Disabled -- iPhone // prefs URL Scheme not working ON iOS 10
    //            let alertController = UIAlertController (title: "Location Sevices Disabled", message: "Please enable location services on settings screen.", preferredStyle: .alert)
    //            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    //            alertController.addAction(okAction)
    //            present(alertController, animated: true, completion: nil)
    //        }
    //
    //        if CLLocationManager.locationServicesEnabled() {
    //            locationManager.delegate = self
    //            locationManager.desiredAccuracy = kCLLocationAccuracyBest
    //            locationManager.startUpdatingLocation()
    //
    //            // Ask for Authorisation from the User.
    //            locationManager.requestAlwaysAuthorization()
    //            // For use in foreground
    //            locationManager.requestWhenInUseAuthorization()
    //
    //            let latitude = locationManager.location?.coordinate.latitude
    //            let longitude = locationManager.location?.coordinate.longitude
    //
    //            if(latitude != nil && longitude != nil){
    //                currentLocation = "\(latitude!),\(longitude!)"
    //            }else
    //            {
    //                currentLocation = ""
    //            }
    //            /* API CALL */
    //            self.getQuestions()
    //        }
    //    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if Model.shared.isinBackgroundState {
            self.locationManager?.allowDeferredLocationUpdates(untilTraveled: deferredLocationsDistance, timeout: deferredLocationsDuration)
        }
      //  print("didUpdateLocations.....")
        guard let location = locations.last else {
            return
        }
        self.lastLocation = location
        self.signalStrength = self.checkSignalStregth()
        self.updateLocation(currentLocation: location, GPSStatus : self.signalStrength)
    }
    
    func checkSignalStregth() -> String {
        // shreeee
        // PDOP, HDOP, VDOP
        //        3m is very  good
        //        6m is good
        //        10m not so good
        //        > 20m bad
        let locAccuracy: Double = self.lastLocation?.horizontalAccuracy ?? -1
        if locAccuracy < 0.0 {
            return GPSSignalStatus.low.rawValue
            // No Signal
        } else if locAccuracy > 48.0 {
            return GPSSignalStatus.weak.rawValue
            // Average Signal
        } else {
            return GPSSignalStatus.accurate.rawValue
            // Full Signal
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print("didFinishDeferredUpdatesWithError called")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self.locationManager?.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            //locationManager?.startUpdatingLocation()
            self.locationManager?.startUpdatingLocation()
            break
        case .authorizedAlways:
            self.locationManager?.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            openSettings()
            break
        }
    }
    
//    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        switch status {
//        case .notDetermined:
//            self.locationManager?.requestWhenInUseAuthorization()
//            break
//        case .authorizedWhenInUse:
//            //locationManager?.startUpdatingLocation()
//            self.locationManager?.startUpdatingLocation()
//            break
//        case .authorizedAlways:
//            self.locationManager?.startUpdatingLocation()
//            break
//        case .restricted:
//            // restricted by e.g. parental controls. User can't enable Location Services
//            break
//        case .denied:
//            // user denied your app access to Location Services, but can grant access from Settings.app
//            openSettings()
//            break
//        }
//    }
    
    func openSettings() {
        let uiAlert = UIAlertController(title: "Location not authorised", message: "Looks like you have turned off your location. We need this to show you the closest offers", preferredStyle: .alert)
        //  self.presentViewController(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler: { action in
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl as? URL {
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    print("open URL ---- success")
                })
            }
        }))
        
        uiAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            print("Click of cancel button")
        }))
        
    }
    
    // Private function
    private func updateLocation(currentLocation: CLLocation, GPSStatus : String) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocation(currentLocation: currentLocation, GPSSignal : GPSStatus)
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error: error)
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        self.locationManager?.startMonitoringSignificantLocationChanges()
    }
}

