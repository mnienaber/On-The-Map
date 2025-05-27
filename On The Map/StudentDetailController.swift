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
        updateMapWithCoordinates(self.getCoordinates(self.studentDetailLocation))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navBarOutlet.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func getCoordinates(_ studentDetailLocation: [StudentLocation]) -> CLLocationCoordinate2D {
        
        for result in studentDetailLocation {
            
            locations = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
        }
        return locations
    }
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle!, let url = URL(string: toOpen) {
                
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func updateMapWithCoordinates(_ locations: CLLocationCoordinate2D) {
        var annotations = [MKPointAnnotation]()
        // The line below seems to be a no-op or a mistake, consider removing or clarifying its purpose.
        // [self.studentDetailLocation = self.studentDetailLocation] 
        performUIUpdatesOnMain {
            
            for result in self.studentDetailLocation {
                let coordinate = locations
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: coordinate, span: span)
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

    @IBAction func cancelButton(_ sender: AnyObject) {
        
        DispatchQueue.main.async {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController")
            self.present(controller, animated: true, completion: nil)
        }
    }
}
