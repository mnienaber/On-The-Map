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

class StudentDetailController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    var studentDetailLocation: [StudentLocation] = [StudentLocation]()
    
    let locationManager = CLLocationManager()
    var locations = CLLocationCoordinate2D()
    
    @IBOutlet weak var navBarOutlet: UINavigationBar!
    @IBOutlet weak var mapViewOutlet: MKMapView!
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.hideKeyboardWhenTappedAround()
        self.mapViewOutlet.delegate = self
        getLocationManager(locationManager, didUpdateLocations: self.getCoordinates(self.studentDetailLocation))
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navBarOutlet.hidden = true
        self.navigationController?.navigationBarHidden = true
    }
    
    func getCoordinates(studentDetailLocation: [StudentLocation]) -> CLLocationCoordinate2D {
        
        for result in studentDetailLocation {
            
            locations = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
        }
        return locations
    }
        
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
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
        var annotations = [MKPointAnnotation]()
        [self.studentDetailLocation = self.studentDetailLocation]
        performUIUpdatesOnMain {
            
            for result in self.studentDetailLocation {
                let coordinate = locations
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegionMake(coordinate, span)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = result.firstName + " " + result.lastName
                annotation.subtitle = result.mediaURL
                annotations.append(annotation)
                self.mapViewOutlet.addAnnotations(annotations)
                self.mapViewOutlet.setRegion(region, animated: true)
            }
        }
    }

    @IBAction func cancelButton(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
}
