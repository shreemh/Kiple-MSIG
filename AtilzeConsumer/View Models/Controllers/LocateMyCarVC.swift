//
//  LocateMyCarVC.swift
//  AtilzeCunsumer
//
//  Created by Adarsh on 01/09/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

import MapKit

import CoreLocation

class LocateMyCarVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var carMapView: MKMapView!
    
    @IBOutlet weak var lastDetectedTime: UILabel!
    
    @IBOutlet weak var locationAddressText: UILabel!
    
    lazy var geocoder               =   CLGeocoder()
    
    var locationTest : String       =   String()
    
    var lastDetectedDate : String   =   String()
    
    var longitude:Float             =   Float()
    
    var latitude:Float              =   Float()
    
    enum LocateMyCarData:String {
        case positionTime   =   "position_time"
        case longitude      =   "longitude"
        case latitude       =   "latitude"
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        getCarLocation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func getDirection(_ sender: Any) {
        
        let alert = UIAlertController(title: "Select Navigation App", message: nil, preferredStyle: .actionSheet)
        
        var installedNavigationApps : [String] = ["Apple Maps"]
        
        let map1 = UIAlertAction(title: "Apple Maps", style: .default, handler: openAppleMap)
        alert.addAction(map1)
        
        if UIApplication.shared.canOpenURL(URL.init(string: "comgooglemaps://")!) {
            installedNavigationApps.append("Google Maps")
            let map2 = UIAlertAction(title: "Google Maps", style: .default, handler: openGoogleMap)
            alert.addAction(map2)
        } else {
            // do nothing
        }
        
        // WAZE NAVIGATION
        if UIApplication.shared.canOpenURL(URL.init(string: "waze://")!) {
            installedNavigationApps.append("Waze")
            let map3 = UIAlertAction(title: "Waze", style: .default, handler: openWazeMap)
            alert.addAction(map3)
        } else {
            // do nothing
        }
        
        self.present(alert, animated: true, completion: nil)
    }
   
    func openAppleMap(action: UIAlertAction) {
        // APPLE MAPS

        //The minimum distance (measured in meters) a device must move horizontally before an update event is generated
        let regionDistance:CLLocationDistance   =   10000
        
        //latitude and longitude
        let coordinates                         =   CLLocationCoordinate2DMake(CLLocationDegrees(self.latitude), CLLocationDegrees(self.longitude))
        
        //Returns a region with specified value
        let regionSpan                          =   MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        let options                             =   [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        //placemark for given latitude and longitude
        let placeMark                           =   MKPlacemark(coordinate: coordinates)
        
        //returns specified point on the map
        let mapItem                             =   MKMapItem(placemark: placeMark)
        
        //shows point in the map
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    func openGoogleMap(action: UIAlertAction){
        // GOOGLE MAPS
        if UIApplication.shared.canOpenURL(URL.init(string: "comgooglemaps://")!) {
            UIApplication.shared.openURL(URL.init(string:
                "comgooglemaps://?saddr=&daddr=\(self.latitude),\(self.longitude)&directionsmode=driving")!)
        } else {
            Utility.showAlert(title: APPNAME, message: "Can't open", viewController: self)
        }
    }
    
    func openWazeMap(action: UIAlertAction) {
        if UIApplication.shared.canOpenURL(URL.init(string: "waze://")!) {
//            UIApplication.shared.openURL(URL.init(string:
//                "waze://?saddr=&daddr=\(self.latitude),\(self.longitude)&directionsmode=driving")!)
            
            UIApplication.shared.openURL(URL.init(string:
                "waze://?ll=\(self.latitude),\(self.longitude)&navigate=yes")!)
        
        } else {
            Utility.showAlert(title: APPNAME, message: "Can't open", viewController: self)
        }
    }
    
    
    
    // MARK: Get Car Location
    func carLocation() {
        
        let location                    =   CLLocationCoordinate2DMake(CLLocationDegrees(self.latitude), CLLocationDegrees(self.longitude))
        
        //pin the location on map using annotation
        let annotation                  =   MKPointAnnotation()
        
        annotation.coordinate           =   location
        
        carMapView.addAnnotation(annotation)
        
        // zoom the map
        let span                        =   MKCoordinateSpanMake(0.075, 0.075)
        
        let region                      =   MKCoordinateRegionMake(location, span)
        
        //  set the zoom in perticular region
        carMapView.setRegion(region, animated: true)
        
        //show campus,trafic,
        carMapView.showsCompass         =   true
        
        carMapView.showsTraffic         =   true
        
        carMapView.showsBuildings       =   true
        
        //Show user location
        carMapView.showsUserLocation    =   true
        
        carMapView.delegate             =   self
        
    }
    
    func mapView( _ mapV: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {
            
            return nil
            
        }
        
        // Better to make this class property
        let annotationIdentifier                        =   "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        
        if let dequeuedAnnotationView                   =   mapV.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            
            annotationView                              =   dequeuedAnnotationView
            
            annotationView?.annotation                  =   annotation
            
        } else {
            annotationView                              =   MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            
            annotationView?.rightCalloutAccessoryView   =   UIButton(type: .detailDisclosure)
            
        }
        
        if let annotationView                           =   annotationView {
            
            // Configure your annotation view here
            annotationView.canShowCallout               =   true
            
            annotationView.image                        =   UIImage(named: "carImage")
            
            annotationView.frame.size.width             =   61
            
            annotationView.frame.size.height            =   70
            
        }
       
       return annotationView ?? nil
        
    }
    
    // MARK: API
    func getCarLocation() {
        
        let url                             =   Constants.ServerAddress.baseURL + Constants.APIEndPoints.getCurrentLocationOfCar + "?"
        
        networkManager.getMethod(url, params: nil, success: {(response) in
            print("Response:\(response ?? 0)")
            if let response = response as? [String : Any], let locationResponse = response["data"] as? [String:Any] {
                self.lastDetectedDate       =   (locationResponse[LocateMyCarData.positionTime.rawValue] as? String) ?? ""
                self.longitude              =   (locationResponse[LocateMyCarData.longitude.rawValue] as? Float) ?? 0
                self.latitude               =   (locationResponse[LocateMyCarData.latitude.rawValue] as? Float) ?? 0
                self.lastDetectedTime.text = Utility.getFormattedDate(date: self.lastDetectedDate)
                self.carLocation()
                self.carAddress()
            }
            
        }, failure: {(error) in
            
            print("Error *** \(error)")
            
            Utility.showAlert(title: APPNAME, message: "Server Error!", viewController: self)
        })
    }
    
    // MARK: Get Address
    func  carAddress() {
        
        // Create Location
        let locations = CLLocation(latitude:CLLocationDegrees(self.latitude), longitude: CLLocationDegrees(self.longitude))
        
        // Geocode Location
        geocoder.reverseGeocodeLocation(locations) { (placemarks, error) in
            // Process Response
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        
    }
    
    // MARK: - PROCESS RESPONSE
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        
        if let error                        =   error {
            
            print("Unable to Reverse Geocode Location (\(error))")
            
            locationAddressText.text        =   "Unable to Find Address for Location"
            
        } else {
            
            if let placemarks               =   placemarks, let placemark = placemarks.first {
                
                
                if let addrDict = placemark.addressDictionary as? [String : Any], let addrArr = addrDict["FormattedAddressLines"] as? [String] {
                    locationAddressText.text = addrArr.joined(separator: ", ")
                    
                }
                
//                locationAddressText.text    =   "\(placemark.name ?? ""),\(placemark.subThoroughfare ?? ""),\(placemark.thoroughfare ?? ""),\(placemark.subLocality ?? ""),\(placemark.subAdministrativeArea ?? ""),\(placemark.administrativeArea ?? ""),\(placemark.country ?? "")"
//
            } else {
                
                locationAddressText.text    =   "No Matching Addresses Found"
                
            }
            
        }
        
    }
    
}
