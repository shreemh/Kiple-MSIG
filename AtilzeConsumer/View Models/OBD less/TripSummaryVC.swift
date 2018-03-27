//
//  CurrentTripDetailsVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 18/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MBCircularProgressBar
import NVActivityIndicatorView

class TripSummaryVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    
    var mapLoaded : Bool = false
    @IBOutlet weak var tableView: UITableView!
    var tripDetails: TripModelView!
    var numberOfRows : Int = 0
    var incidentsArray : [Incidents] = []
    var locationsArray : [Locations] = []
    var tripSummaryModel: TripSummaryModelView!
    var detailCell : DetailCell?
    var isFromTripHostory : Bool = false
    
  //  @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var maxSpeedLbl: UILabel!
    
    var totalDuration:Double = 0.0
    
    @IBOutlet weak var fromAddress: UILabel!
    @IBOutlet weak var toAddress: UILabel!
    
    @IBOutlet weak var speedingCount: UILabel!
    @IBOutlet weak var hardBrakingCount: UILabel!
    @IBOutlet weak var hardCorneringCount: UILabel!
    @IBOutlet weak var hardAccelCount: UILabel!
    
    @IBOutlet weak var tripTime: UILabel!
    var geocoder = CLGeocoder()
    
    @IBOutlet weak var tripScore: MBCircularProgressBarView!
    
    var locations2DArray : [CLLocationCoordinate2D] = []
    var tripSummary : [String : Any] = [:]

    enum IncidentTypes: String {
        case start = "start"
        case stop = "stop"
        case accel = "sudden_acceleration"
        case braking = "sudden_deacceleration"
        case cornering = "sharp_turn"
        case overspeed = "overspeed"
    }
    
    enum IncidentTitles: String {
        case start = "starting"
        case stop = "ending"
        case accel = "hard acceleration"
        case braking = "hard braking"
        case cornering = "hard cornering"
        case overspeed = "speeding"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
//        createPolyline()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        navigationController?.navigationItem.hidesBackButton = true
        let myBackButton:UIButton = UIButton(type: .custom) as UIButton
        myBackButton.backgroundColor = .clear
        myBackButton.setTitleColor(BLUE, for: .normal)
        myBackButton.addTarget(self, action: #selector(popToRoot), for: .touchUpInside)
        myBackButton.setTitle("Back", for: .normal)
        //        myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
    }
    
    func popToRoot() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func setUpView() {
        
        //// shreeeee place this code later
    
        if locations2DArray.count > 0 {
            isFromTripHostory = false
            // MANUAL
            tripSummaryModel = TripSummaryModelView(tripSummary: TripSummary(rawData: tripSummary, totalDuration: totalDuration, isFromTripList: false))
            numberOfRows = 2
            tableView.reloadData()
            
//            getAddress(lat: locations2DArray[0].latitude, long: locations2DArray[0].longitude, label: fromAddress)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
//                self.getAddress(lat: self.locations2DArray[self.locations2DArray.count - 1].latitude, long: self.locations2DArray[self.locations2DArray.count - 1].longitude, label: self.toAddress)
//            })
            
        } else {
            // BE
            isFromTripHostory = true
            getTripDetails()
            reviewTrip(yesOrNo: true)
        }
    }

    func getTripDetails() {
        if Utility.isConnectedToNetwork() {
            startAnimating(CGSize(width: 30, height: 30), message: "")
            // INTERNET CONNECTION AVAILABLE
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.getTripDetail + tripDetails.tripID + "?"
            networkManager.getMethod(url, params: nil, success: { (response) in
                /* STOP LOADER */
                self.stopAnimating()
                if let responseObj = response as? [String : Any], let tripDetails = responseObj["data"] as? [String : Any] {
                    print("tripDetails  :\(tripDetails)")
                    self.tripSummaryModel = TripSummaryModelView(tripSummary: TripSummary(rawData: tripDetails, totalDuration: 0, isFromTripList: true))
                    self.incidentsArray = self.sortArray(array: self.tripSummaryModel?.incidentsArray ?? [])
                    self.locationsArray = self.tripSummaryModel?.locationsArray ?? []
                    print("incidentsArray == \(self.incidentsArray)")
                    self.numberOfRows = self.incidentsArray.count + 1 + 2
                    self.tableView.reloadData()
                    
                } else if let response = response as? [String : Any], let responseObj = response["error"] as? [String : Any], let error =  responseObj["error"] as? String {
                    if error == ErrorsFromAPI.tokenError.rawValue {
                        // CALL SUBSCRIPTION API
                        Utility.checkSubscription(viewController: self)
                    } else {
                        Utility.storeStaticDataToFile(fileName: ErrorMsgs.serverError, rawData: responseObj)
                    }
                } else {
                }
            }) { (_) in
                self.stopAnimating()
                Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
            }
        } else {
            // NO INTERNET CONNECTION
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }
    
    func sortArray(array : [Incidents] ) -> [Incidents] {
        return array.sorted(by: { $0.time.compare($1.time) == .orderedAscending })
    }
    
    func createPolyline(mapView : MKMapView) {
     
        if self.locations2DArray.count > 0 {
            // MANUAL
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: locations2DArray[Int(self.locations2DArray.count - 1)], span: span)
            mapView.setRegion(region, animated: true)
            
            //     let geodesic = MKPolyline(coordinates: &points, count: 3)
            let geodesic = MKGeodesicPolyline(coordinates: locations2DArray, count: locations2DArray.count)
            mapView.add(geodesic, level: .aboveRoads)
        
            if let distanceTravelled =  tripSummary["drivingDistance"] as? Double {
                let cam = MKMapCamera(lookingAtCenter: self.locations2DArray[Int(self.locations2DArray.count/2)], fromDistance: distanceTravelled, pitch: 45, heading: 0)
                mapView.setCamera(cam, animated: true)
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = "Starting"
            annotation.coordinate = locations2DArray[0]
            mapView.addAnnotation(annotation)
            
            let annotation2 = MKPointAnnotation()
            annotation2.title = "Ending"
            annotation2.coordinate = self.locations2DArray[Int(self.locations2DArray.count - 1)]
            mapView.addAnnotation(annotation2)
            mapView.showAnnotations(mapView.annotations, animated: true)
                        
        } else {
            
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: (tripSummaryModel?.endLocation)!, span: span)
            mapView.setRegion(region, animated: true)
            
            if tripSummaryModel?.endLocation != nil {
                locations2DArray.append((tripSummaryModel?.endLocation)!)
            }
            // BE
            for (index, location) in self.locationsArray.enumerated() {
                
                locations2DArray.append(location.location2D)
                if index == self.locationsArray.count - 1 {
                    if tripSummaryModel?.startLocation != nil {
                        locations2DArray.append((tripSummaryModel?.startLocation)!)
                    }
                }
                let geodesic = MKGeodesicPolyline(coordinates: locations2DArray, count: locations2DArray.count)
                mapView.add(geodesic, level: .aboveRoads)
                
                let distance: String = tripSummaryModel?.distance ?? "0.0"
                let cam = MKMapCamera(lookingAtCenter: self.locations2DArray[Int(self.locations2DArray.count/2)], fromDistance: Double(distance)!, pitch: 45, heading: 0)
                mapView.setCamera(cam, animated: true)
            }
            
            for (_, incident) in self.incidentsArray.enumerated() {
                if incident.location.latitude != 0, incident.location.longitude != 0 {
                    let annotation = MKPointAnnotation()
                    annotation.title = incident.incidentTitle
                    annotation.subtitle = incident.time
                    annotation.coordinate = incident.location
                    mapView.addAnnotation(annotation)
                }
            }
            
            guard let startPoint = tripSummaryModel?.startLocation, let endpoint = tripSummaryModel?.endLocation else {
                mapView.showAnnotations(mapView.annotations, animated: true)
                return
            }
            let annotation = MKPointAnnotation()
            annotation.title = "Starting"
            annotation.subtitle = tripSummaryModel.startTime
            annotation.coordinate = startPoint
            mapView.addAnnotation(annotation)
            
            let annotation2 = MKPointAnnotation()
            annotation2.title = "Ending"
            annotation2.subtitle = tripSummaryModel.endTime
            annotation2.coordinate = endpoint
            mapView.addAnnotation(annotation2)
            mapView.showAnnotations(mapView.annotations, animated: true)
        
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = BLUE
            polylineRenderer.lineWidth = 2
            return polylineRenderer
        }
        return MKPolylineRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
//        guard !annotation.isKind(of: MKUserLocation) else {
//            return nil
//        }
//
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            //annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        let annotationTitle = annotation.title as? String ?? ""
        let imageName = annotationTitle.lowercased()
        annotationView!.image = UIImage(named: imageName)
        return annotationView
    }
    
    // MARK: - GET LOCATION FROM LAT LONG
    func  getAddress(lat: Double, long: Double, label: UILabel) {
        // Create Location
        let locations = CLLocation(latitude:CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        // Geocode Location)
        geocoder.reverseGeocodeLocation(locations) { (placemarks, error) in
            if error != nil {
                label.text = "Unable to Find Address for Location"
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    label.text = "\(placemark.name ?? ""),\(placemark.subThoroughfare ?? ""),\(placemark.thoroughfare ?? ""),\(placemark.subLocality ?? ""),\(placemark.subAdministrativeArea ?? ""),\(placemark.administrativeArea ?? ""),\(placemark.country ?? "")"
                } else {
                    label.text = "No Matching Address Found"
                }
            }
        }
    }
    
    // MARK: - TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let incidentCell = tableView.dequeueReusableCell(withIdentifier: "IncidentCell") else {
            print("ERROR")
            fatalError()
        }
        guard let tripsButtonCell = tableView.dequeueReusableCell(withIdentifier: "SeeAllTripsCell") else {
            print("ERROR")
            fatalError()
        }
        
        incidentCell.selectionStyle = .none
        detailCell?.selectionStyle = .none
        tripsButtonCell.selectionStyle = .none
        
        let lastRow = self.tableView.numberOfRows(inSection: 0) - 1
        
        if indexPath.row == 0 {
            if !mapLoaded {
                detailCell = tableView.dequeueReusableCell(withIdentifier: "DetailCell") as? DetailCell
                mapLoaded = true
                detailCell?.mapView.delegate = self
                let overlays = detailCell?.mapView.overlays
                if overlays != nil {
                     detailCell?.mapView.removeOverlays(overlays!)
                }
                createPolyline(mapView: (detailCell?.mapView)!)
                
                detailCell?.dateTime.text = tripSummaryModel?.startEndTime
                detailCell?.duration.text = tripSummaryModel?.duration
                detailCell?.distance.text = (tripSummaryModel?.distance)! + " KM"
                detailCell?.maxSpeed.text = (tripSummaryModel?.maxSpeed)! + " KM/H"
                
                detailCell?.speeding.text = String(describing: tripSummaryModel.speedingCount)
                detailCell?.braking.text = String(describing: tripSummaryModel.hadrBraking)
                detailCell?.accel.text = String(describing: tripSummaryModel.hardAccel)
                detailCell?.cornering.text = String(describing: tripSummaryModel.sharpCornering)
                
                detailCell?.speeding.textColor = tripSummaryModel?.speedingCount ?? 0 > 0 ? RED : .black
                detailCell?.braking.textColor = tripSummaryModel?.hadrBraking ?? 0 > 0 ? RED : .black
                detailCell?.cornering.textColor = tripSummaryModel?.sharpCornering ?? 0 > 0 ? RED : .black
                detailCell?.accel.textColor = tripSummaryModel?.hardAccel ?? 0 > 0 ? RED : .black
                
                detailCell?.tripScore.value = CGFloat(tripSummaryModel.tripScore)

//                detailCell?.yesBtn.addTarget(self, action: #selector(yesBtnCall), for: .touchUpInside)
//                detailCell?.noBtn.addTarget(self, action: #selector(noBtnCall), for: .touchUpInside)
//
                return detailCell!
            } else {
                return detailCell!
            }
        } else if indexPath.row == 1, numberOfRows == 2 {
            let button = tripsButtonCell.viewWithTag(1) as? UIButton
            button?.addTarget(self, action: #selector(seeAllTripsBtnCall), for: .touchUpInside)
            return tripsButtonCell
        } else if indexPath.row == 1 {
            let titlelbl = incidentCell.viewWithTag(1) as? UILabel
            let address = incidentCell.viewWithTag(2) as? UILabel
            let icon = incidentCell.viewWithTag(3) as? UIImageView
            let view1 = incidentCell.viewWithTag(4)
            let view2 = incidentCell.viewWithTag(5)
            view1?.isHidden = true
            view2?.isHidden = false
            
            let time = incidentCell.viewWithTag(6) as? UILabel
            time?.text = tripSummaryModel?.startTime
            titlelbl?.text = "Starting"
            address?.text = tripSummaryModel?.startAddr
            icon?.image = UIImage.init(named: "starting")
           // icon?.backgroundColor = UIColor(red:0, green:0.45, blue:0.64, alpha:1)
            return incidentCell
        } else if indexPath.row == lastRow {
            let titlelbl = incidentCell.viewWithTag(1) as? UILabel
            let address = incidentCell.viewWithTag(2) as? UILabel
            let icon = incidentCell.viewWithTag(3) as? UIImageView
            let view1 = incidentCell.viewWithTag(4)
            let view2 = incidentCell.viewWithTag(5)
            view1?.isHidden = false
            view2?.isHidden = true
            
            let time = incidentCell.viewWithTag(6) as? UILabel
            time?.text = tripSummaryModel?.endTime
            titlelbl?.text = "Ending"
            address?.text = tripSummaryModel?.endAddr
            icon?.image = UIImage.init(named: "ending")
            return incidentCell
        } else {
            let titlelbl = incidentCell.viewWithTag(1) as? UILabel
            let address = incidentCell.viewWithTag(2) as? UILabel
            let icon = incidentCell.viewWithTag(3) as? UIImageView
            let view1 = incidentCell.viewWithTag(4)
            let view2 = incidentCell.viewWithTag(5)
            view1?.isHidden = false
            view2?.isHidden = false
            
            let time = incidentCell.viewWithTag(6) as? UILabel
            time?.text = incidentsArray[indexPath.row - 2].time
            titlelbl?.text = incidentsArray[indexPath.row - 2].incidentTitle
            address?.text = incidentsArray[indexPath.row - 2].addres
            
            if incidentsArray[indexPath.row - 2].incidentType == IncidentTypes.overspeed.rawValue {
                icon?.image = UIImage.init(named: "speeding")
            } else if incidentsArray[indexPath.row - 2].incidentType == IncidentTypes.cornering.rawValue {
                icon?.image = UIImage.init(named: "hard cornering")
            } else if incidentsArray[indexPath.row - 2].incidentType == IncidentTypes.accel.rawValue {
                icon?.image = UIImage.init(named: "hard acceleration")
            } else {
                icon?.image = UIImage.init(named: "hard braking")
            }
           // icon?.backgroundColor = UIColor(red:0.93, green:0.08, blue:0.36, alpha:1)
            return incidentCell
        }
    }

    // MARK: - UIBUTTON ACTIONS
    
    func seeAllTripsBtnCall() {
        Model.shared.isFromManualTracking = true
        self.tabBarController?.selectedIndex = 1
        self.popToRoot()
    }
//    @IBAction func seeAllTripsBtnCall(_ sender: Any) {
//        Model.shared.isFromManualTracking = true
//        self.tabBarController?.selectedIndex = 1
//        self.popToRoot()
//
//        // GO TO TripHistoryVC
//        if let tripsVC = mainSB.instantiateViewController(withIdentifier: StoryBoardVC.trip) as? TripHistoryVC {
//            tripsVC.isFromDashBoard = true
//            let backItem = UIBarButtonItem()
//            backItem.title = ""
//            navigationItem.backBarButtonItem = backItem
//            navigationController?.pushViewController(tripsVC, animated: true)
//        }
//    }
    
    func yesBtnCall() {
        reviewTrip(yesOrNo: true)
    }
    
    func noBtnCall() {
        reviewTrip(yesOrNo: false)
    }
    
    @IBAction func fullViewBtnCall(_ sender: Any) {
        if let fullScreenVC = mainSB.instantiateViewController(withIdentifier: StoryBoardVC.fullScrenVC) as? FullScreenMapVC {
            //if incidentsArray.count > 0 {
                fullScreenVC.tripSummaryModel = tripSummaryModel
                fullScreenVC.incidentsArray = incidentsArray
           // }
            fullScreenVC.locations2DArray = locations2DArray
            fullScreenVC.isFromTripHostory = isFromTripHostory
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            navigationController?.pushViewController(fullScreenVC, animated: true)
        }
    }
    
    func reviewTrip(yesOrNo : Bool) {
        if Utility.isConnectedToNetwork() {
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.reviewTrip + tripDetails.tripID + "?"
            networkManager.putMethod(url, params: nil, success: { (response) in
                guard let res = response as? [String : Any], res["error"] == nil else {
                    Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                    return
                }
            }) { (error) in
                Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
            }
        }
    }
}
class DetailCell: UITableViewCell {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var maxSpeed: UILabel!
    @IBOutlet weak var duration: UILabel!

    @IBOutlet weak var tripScore: MBCircularProgressBarView!
    @IBOutlet weak var speeding: UILabel!
    @IBOutlet weak var braking: UILabel!
    @IBOutlet weak var accel: UILabel!
    @IBOutlet weak var cornering: UILabel!
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var noBtn: UIButton!
    @IBOutlet weak var yesBtn: UIButton!
    
}
