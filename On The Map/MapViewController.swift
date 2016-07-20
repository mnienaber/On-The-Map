//
//  MapViewController.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var studentLocation: [StudentLocation] = [StudentLocation]()
    var appDelegate: AppDelegate!
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 2000

    @IBOutlet weak var mapView: MKMapView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.hideKeyboardWhenTappedAround()
        getMapLocations()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            print("yay")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.65, longitudeDelta: 0.65))
        
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }

    
    func getMapLocations() {
        
        Client.sharedInstance().getStudentLocations { (studentLocation, errorString) in
            if let studentLocation = studentLocation {
                [self.studentLocation = studentLocation]
                var annotations = [MKPointAnnotation]()
                performUIUpdatesOnMain {
                    for student in self.studentLocation {
                        
                        let coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = student.firstName + student.lastName
                        annotation.subtitle = student.mediaURL
                        annotations.append(annotation)
                    }
                    self.mapView.addAnnotations(annotations)
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            pinView!.pinColor = .Red
            pinView!.animatesDrop = true
            
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
    
    @IBAction func buttonMethod(sender: AnyObject) {
        
        getMapLocations()
        print("refresh")
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    

    
    
}

