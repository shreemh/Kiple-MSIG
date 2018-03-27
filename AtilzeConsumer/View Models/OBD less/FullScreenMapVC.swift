//
//  FullScreenMapVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 01/12/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class FullScreenMapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locations2DArray : [CLLocationCoordinate2D] = []
    var tripSummaryModel: TripSummaryModelView!
    var incidentsArray : [Incidents] = []
    var isFromTripHostory : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent("Trip_View_Full", parameters: nil)
        mapView.delegate = self
        createPolyline()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createPolyline() {

        // MANUAL   -- Routes
        // BE -- Routes + Incidents
        
        //     let geodesic = MKPolyline(coordinates: &points, count: 3)
        
        if !isFromTripHostory {
            // MANUAL
            if locations2DArray.count > 0 {
                let geodesic = MKGeodesicPolyline(coordinates: locations2DArray, count: locations2DArray.count)
                mapView.add(geodesic, level: .aboveRoads)
            }
            let annotation = MKPointAnnotation()
            annotation.title = "Starting"
          //  annotation.subtitle = tripSummaryModel.startTime //  TimeZone
            annotation.coordinate = locations2DArray[0]
            mapView.addAnnotation(annotation)
            
            let annotation2 = MKPointAnnotation()
            annotation2.title = "Ending"
           // annotation2.subtitle = tripSummaryModel.endTime  //  TimeZone
            annotation2.coordinate = locations2DArray[locations2DArray.count - 1]
            mapView.addAnnotation(annotation2)
            
        } else {
            // BE
            if locations2DArray.count > 0 {
                let geodesic = MKGeodesicPolyline(coordinates: locations2DArray, count: locations2DArray.count)
                mapView.add(geodesic, level: .aboveRoads)
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
            
            if incidentsArray.count > 0 {
                for (_, incident) in self.incidentsArray.enumerated() {
                    if incident.location.latitude != 0, incident.location.longitude != 0 {
                        let annotation = MKPointAnnotation()
                        annotation.title = incident.incidentTitle
                        annotation.subtitle = incident.time
                        annotation.coordinate = incident.location
                        mapView.addAnnotation(annotation)
                    }
                }
            }
        }
        
        mapView.showAnnotations(mapView.annotations, animated: true)
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
    
}
