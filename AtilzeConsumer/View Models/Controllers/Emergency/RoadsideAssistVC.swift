//
//  RoadsideAssistVC.swift
//  AtilzeCunsumer
//
//  Created by Shree on 20/09/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

import MapKit

import CoreLocation

class RoadsideAssistVC: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var assistentTypeCollection: [UIView]!
    @IBOutlet var assistentImagesCollection: [UIImageView]!
    @IBOutlet var assistentLabelsCollection: [UILabel]!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var additionalNotes: UITextView!
    
    lazy var geocoder               =   CLGeocoder()
    
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var type : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carAddress()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillLayoutSubviews() {
//        assistentImagesCollection[0].image = UIImage(named: "Tyres")
//        assistentImagesCollection[0].tintColor = UIColor(hexString: "0073A4")
//
        assistentImagesCollection[0].layer.borderColor = UIColor.lightGray.cgColor
        assistentImagesCollection[1].layer.borderColor = UIColor.lightGray.cgColor
        assistentImagesCollection[2].layer.borderColor = UIColor.lightGray.cgColor
        assistentImagesCollection[3].layer.borderColor = UIColor.lightGray.cgColor
        
        assistentImagesCollection[0].layer.masksToBounds = true
        assistentImagesCollection[1].layer.masksToBounds = true
        assistentImagesCollection[2].layer.masksToBounds = true
        assistentImagesCollection[3].layer.masksToBounds = true
        additionalNotes.layer.cornerRadius = 3
        additionalNotes.layer.borderColor = UIColor.lightGray.cgColor
        additionalNotes.layer.masksToBounds = true
    }

    @IBAction func tapped(_ sender: Any) {
        let selectedColor = UIColor(hexString: "0073A4")
        for view in assistentTypeCollection {
            view.backgroundColor = .white
            for subView in view.subviews {
                if let image = subView as? UIImageView {
                   image.tintColor = selectedColor
                } else if let label = subView as? UILabel {
                    label.textColor = .black
                }
            }
        }
        guard let tapGester = sender as? UITapGestureRecognizer, let selectedView = tapGester.view else {
            return
        }
        switch selectedView {
        case assistentTypeCollection[1]:
            type = "battery"
            assistentTypeCollection[1].backgroundColor = selectedColor
            assistentImagesCollection[1].image = UIImage(named: "batteries")
            assistentImagesCollection[1].tintColor = .white
            assistentLabelsCollection[1].textColor = .white
            break
        case assistentTypeCollection[2]:
            assistentTypeCollection[2].backgroundColor = selectedColor
            assistentImagesCollection[2].image = UIImage(named: "Tows")
            assistentImagesCollection[2].tintColor = .white
            assistentLabelsCollection[2].textColor = .white
            type = "tow"
            break
        case assistentTypeCollection[3]:
            assistentTypeCollection[3].backgroundColor = selectedColor
            assistentImagesCollection[3].image = UIImage(named: "Assistances")
            assistentImagesCollection[3].tintColor = .white
            assistentLabelsCollection[3].textColor = .white
            type = "call_service"
            break
        default:
            assistentTypeCollection[0].backgroundColor = selectedColor
            assistentImagesCollection[0].image = UIImage(named: "Tyres")
            assistentImagesCollection[0].tintColor = .white
            assistentLabelsCollection[0].textColor = .white
            type = "tire"
            break
        }
    }
    
    @IBAction func sendrequestBtnCall(_ sender: Any) {
        var flag : Bool = true
        if type.isEmpty {
            flag = false
            Utility.showAlert(title: APPNAME, message: "Please select assistent type to continue", viewController: self)
        }
        if flag {
            apiCall()
        }
    }
    
    func  carAddress() {
        // Create Location
        let locations = CLLocation(latitude:CLLocationDegrees(self.latitude), longitude: CLLocationDegrees(self.longitude))
        // Geocode Location)
        geocoder.reverseGeocodeLocation(locations) { (placemarks, error) in
            // Process Response
            self.processResponse(withPlacemarks: placemarks, error: error)
            print(placemarks ?? 0)
        }
    }

    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        
        if let error                        =   error {
            
            print("Unable to Reverse Geocode Location (\(error))")
            
            location.text        =   "Unable to Find Address for Location"
            
        } else {
            
            if let placemarks               =   placemarks, let placemark = placemarks.first {
                
                if let addrDict = placemark.addressDictionary as? [String : Any], let addrArr = addrDict["FormattedAddressLines"] as? [String] {
                    location.text = addrArr.joined(separator: ", ")
                    
                }
//                location.text    =   "\(placemark.name ?? ""),\(placemark.subLocality ?? ""),\(placemark.subAdministrativeArea ?? ""),\(placemark.administrativeArea ?? ""),\(placemark.country ?? "")"
                
            } else {
                
                location.text    =   "No Matching Addresses Found"
                
            }
        }
    }

    func apiCall() {
        if Utility.isConnectedToNetwork() {
            //base url and api end point
            let url = Constants.ServerAddress.baseURL + Constants.APIEndPoints.regEmergency
            let latString = String(self.latitude)
            let longString = String(self.longitude)
            let params: [String : Any] = ["type" : type, "latitude" : latString, "longitude" : longString, "description" : additionalNotes.text]
            networkManager.postMethod(url, params: params, success: { (response) in
                if let res = response as? [String: Any], res["error"] == nil, let responseObj = res["data"] as? [String : Any] {
                  
                    print("response == \(response)")
                    
                    //Utility.showAlert(title: APPNAME, message: "Successfull", viewController: self)
                    guard let roadsideAssistDetailVC = mainSB.instantiateViewController(withIdentifier: "RoadsideAssistDetailVC") as? RoadsideAssistDetailVC else {
                        return
                    }
                    roadsideAssistDetailVC.requestID = responseObj["request_id"] as? Int ?? 0
                    let backItem = UIBarButtonItem()
                    
                    backItem.title = ""
                    self.navigationItem.backBarButtonItem = backItem
                    self.navigationController?.pushViewController(roadsideAssistDetailVC, animated: true)
                    
                } else if let res = response as? [String: Any], let responseObj = res["error"] as? [String : Any], let msg = responseObj["message"] as? String {
                    Utility.showAlert(title: APPNAME, message: msg, viewController: self)
                } else {
                    Utility.showAlert(title: APPNAME, message: ErrorMsgs.tryAgain, viewController: self)
                }
                
            }, failure: { (error) in
                print("Error *** \(error)")
                Utility.showAlert(title: APPNAME, message: ErrorMsgs.serverError, viewController: self)
            })
        } else {
            Utility.showAlert(title: APPNAME, message: internetConnectMsg, viewController: self)
        }
    }

}
