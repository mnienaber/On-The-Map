//
//  StudentDetailController.swift
//  On The Map
//
//  Created by Michael Nienaber on 15/07/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StudentDetailController: UIViewController, MKMapViewDelegate {
    
    
    var studentDetailLocation: [StudentLocation] = [StudentLocation]()
    
    let latitude = 47.619729999999997
    let longitude = -122.143
    @IBOutlet weak var mapViewOutlet: MKMapView!
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let locationManager = CLLocationManager()
        self.hideKeyboardWhenTappedAround()
        self.mapViewOutlet.delegate = self
        getLocationManager(locationManager, didUpdateLocations: location)
    
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    func getLocationManager(manager: CLLocationManager, didUpdateLocations locations: CLLocationCoordinate2D) {
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(locations, span)
        mapViewOutlet.setRegion(region, animated: true)
        var annotations = [MKPointAnnotation]()
        [self.studentDetailLocation = self.studentDetailLocation]
        performUIUpdatesOnMain {
            
            let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Fake Title"
            annotations.append(annotation)
            self.mapViewOutlet.addAnnotations(annotations)
        }
    }

    @IBAction func cancelButton(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
}
