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
    
    //var studentLocation: [StudentLocation] = [StudentLocation]()
    var appDelegate: AppDelegate!
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 2000
    var annotations = [MKPointAnnotation]()

    @IBOutlet weak var mapView: MKMapView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.mapView.delegate = self
        mapView.showsUserLocation = true
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.hideKeyboardWhenTappedAround()
        getMapLocations()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mapView.delegate = self
        self.mapView.addAnnotations(annotations)
        print("map_willappear")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
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
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView.rem
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

                if verifyUrl(toOpen) == false {

                    let failAlertGeneral = UIAlertController(title: "Yikes", message: "The url you're trying to open is invalid", preferredStyle: UIAlertControllerStyle.Alert)
                    failAlertGeneral.addAction(UIAlertAction(title: "Try Another", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(failAlertGeneral, animated: true, completion: nil)
                } else {

                    app.openURL(NSURL(string: toOpen)!)
                }
            }
        }
    }

    func getMapLocations() {

        if StudentModel.sharedInstance().studentLocation.isEmpty == true {

            refresh()
        } else if StudentModel.sharedInstance().studentLocation.isEmpty == false {

            performUIUpdatesOnMain {

                self.mapView.removeAnnotations(self.annotations)

                for student in StudentModel.sharedInstance().studentLocation {

                    let lat = student.latitude
                    let long = student.longitude
                    let mediaURL = student.mediaURL
                    let annotation = MKPointAnnotation()
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

                    annotation.coordinate = coordinate
                    annotation.title = student.firstName + " " + student.lastName
                    annotation.subtitle = mediaURL
                    self.annotations.append(annotation)

                }
                self.mapView.addAnnotations(self.annotations)
            }
        }
    }

    func refresh() {

        Client.sharedInstance().getStudentLocations { (studentLocation, errorString) in

            if errorString != nil {

                performUIUpdatesOnMain{

                    self.failStudentLocations()
                }
            } else {

                if let studentLocation = studentLocation {

                    var annotations = [MKPointAnnotation]()

                    performUIUpdatesOnMain {

                        self.mapView.removeAnnotations(annotations)
                        for student in studentLocation {

                            let lat = student.latitude
                            let long = student.longitude
                            let mediaURL = student.mediaURL
                            let annotation = MKPointAnnotation()
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

                            annotation.coordinate = coordinate
                            annotation.title = student.firstName + " " + student.lastName
                            annotation.subtitle = mediaURL
                            annotations.append(annotation)

                        }
                        self.mapView.addAnnotations(annotations)
                    }
                }
            }
        }
    }

    @IBAction func buttonMethod(sender: AnyObject) {

        self.mapView.removeAnnotations(annotations)
        refresh()
    }

    func failStudentLocations() {

        let failDataAlert = UIAlertController(title: "Sorry", message: "There was a problem with retrieving Student Location data", preferredStyle: UIAlertControllerStyle.Alert)
        failDataAlert.addAction(UIAlertAction(title: "I'll Come Back Later", style: UIAlertActionStyle.Default, handler: nil))
        failDataAlert.addAction(UIAlertAction(title: "Leave Feedback", style: UIAlertActionStyle.Default, handler: { alertAction in
            UIApplication.sharedApplication().openURL(NSURL(string : "mailto:mnienaber@google.com")!)
            failDataAlert.dismissViewControllerAnimated(true, completion: nil)
        self.presentViewController(failDataAlert, animated: true, completion: nil)
        }))
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

    func verifyUrl(urlString: String?) -> Bool {

        if let urlString = urlString {

            if NSURL(string: urlString) != nil {

                return true
            }
        }
        return false
    }
}

