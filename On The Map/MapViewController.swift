//
//  MapViewController.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//
import UIKit
import MapKit
import AudioToolbox

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
        
        self.mapView.delegate = self
        mapView.showsUserLocation = true
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.hideKeyboardWhenTappedAround()
        getMapLocations()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override internal func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override internal func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            print("Shaked")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let failLogoutAlert = UIAlertController(title: "Wanna Logout?", message: "Just double checking, we'll miss you!", preferredStyle: UIAlertControllerStyle.Alert)
            failLogoutAlert.addAction(UIAlertAction(title: "Log Me Out", style: UIAlertActionStyle.Default, handler: { alertAction in self.logOut() }))
            failLogoutAlert.addAction(UIAlertAction(title: "Take Me Back!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(failLogoutAlert, animated: true, completion: nil)
        }
        
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
    
    func getMapLocations() {
        
        Client.sharedInstance().getStudentLocations { (studentLocation, errorString) in
            
            if errorString != nil {
                
                performUIUpdatesOnMain{
                    
                    self.failStudentLocations()
                }
            } else {
                
                if let studentLocation = studentLocation {
                    [self.studentLocation = studentLocation]
                    var annotations = [MKPointAnnotation]()
                    performUIUpdatesOnMain {
                        for student in self.studentLocation {
                            
                            let lat = student.latitude
                            let long = student.longitude
                            let mediaURL = student.mediaURL
                            let annotation = MKPointAnnotation()
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            
                            annotation.coordinate = coordinate
                            annotation.title = student.firstName + student.lastName
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
        
        getMapLocations()
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
    
    func logOut() {

        self.appDelegate.accountKey = nil
        self.appDelegate.accountRegistered = nil
        self.appDelegate.sessionID = nil
        self.appDelegate.sessionExpiration = nil
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
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

