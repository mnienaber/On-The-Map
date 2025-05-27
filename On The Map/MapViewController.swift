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

    var appDelegate: AppDelegate!
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 2000
    var annotations: [MKAnnotation] = []

    @IBOutlet weak var mapView: MKMapView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Optimization: Reduced accuracy for battery
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.hideKeyboardWhenTappedAround()
        getMapLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.65, longitudeDelta: 0.65))
        
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        print("error:: \(error)")
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
            if let toOpen = view.annotation?.subtitle! {

                if verifyUrl(toOpen) == false {

                    let failAlertGeneral = UIAlertController(title: "Yikes", message: "The url you're trying to open is invalid", preferredStyle: .alert)
                    failAlertGeneral.addAction(UIAlertAction(title: "Try Another", style: .default, handler: nil))
                    self.present(failAlertGeneral, animated: true, completion: nil)
                } else {

                    app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
                }
            }
        }
    }

    func getMapLocations() {

        if StudentModel.sharedInstance().studentLocation.isEmpty == true {

            refresh()
        } else if StudentModel.sharedInstance().studentLocation.isEmpty == false {

            self.annotations = []

            performUIUpdatesOnMain {

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

        if Reachability.isConnectedToNetwork() == false {

            failAlertGeneral("No Internet Connection", message: "Please check your connection", actionTitle: "OK")
        } else if Reachability.isConnectedToNetwork() == true {

            self.mapView.removeAnnotations(self.annotations)

            self.annotations = []

            Client.sharedInstance().getStudentLocations { [weak self] (studentLocations, error) in
                guard let self = self else { return }
                performUIUpdatesOnMain {
                    if let error = error {
                        print("Error fetching student locations: \(error.localizedDescription)")
                        self.failStudentLocations()
                    } else if let studentLocations = studentLocations {
                        var newAnnotations: [MKAnnotation] = [] // Create new annotations locally
                        for student in studentLocations {
                            let lat = student.latitude
                            let long = student.longitude
                            let mediaURL = student.mediaURL 
                            let annotation = MKPointAnnotation()
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

                            annotation.coordinate = coordinate
                            annotation.title = "\(student.firstName) \(student.lastName)"
                            annotation.subtitle = mediaURL
                            newAnnotations.append(annotation)
                        }
                        self.annotations = newAnnotations // Update the class member
                        self.mapView.addAnnotations(self.annotations)
                    }
                }
            }
        }
    }

    @IBAction func buttonMethod(_ sender: AnyObject) {

        self.mapView.removeAnnotations(annotations) // Existing annotations
        refresh()
    }

    func failStudentLocations() {

        let failDataAlert = UIAlertController(title: "Sorry", message: "There was a problem with retrieving Student Location data", preferredStyle: .alert)
        failDataAlert.addAction(UIAlertAction(title: "I'll Come Back Later", style: .default, handler: nil))
        failDataAlert.addAction(UIAlertAction(title: "Leave Feedback", style: .default, handler: { alertAction in
            if let url = URL(string : "mailto:mnienaber@google.com") {
                 UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            failDataAlert.dismiss(animated: true, completion: nil)
        }))
        self.present(failDataAlert, animated: true, completion: nil)
    }

    func logOut() {

        Client.sharedInstance().deleteSession() { (deleteResponse, error) in
            performUIUpdatesOnMain {
                if let error = error {
                    print("Logout error: \(error.localizedDescription)")
                    self.failAlertGeneral("LogOut Unsuccessful", message: "Something went wrong, please try again", actionTitle: "OK")
                } else {
                    // Successfully logged out (or session deletion initiated)
                    // deleteResponse might contain details if needed, e.g., deleteResponse.session.id
                    print("Logout success \(String(describing: deleteResponse))")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func logOutButton(_ sender: AnyObject) {

        failLogOutAlert()
    }

    func failAlertGeneral(title: String, message: String, actionTitle: String) {

        let failAlertGeneral = UIAlertController(title: title, message: message, preferredStyle: .alert)
        failAlertGeneral.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        self.present(failAlertGeneral, animated: true, completion: nil)
    }

    func failLogOutAlert() {

        let failLogoutAlert = UIAlertController(title: "Wanna Logout?", message: "Just double checking, we'll miss you!", preferredStyle: .alert)
        failLogoutAlert.addAction(UIAlertAction(title: "Log Me Out", style: .default, handler: { alertAction in self.logOut() }))
        failLogoutAlert.addAction(UIAlertAction(title: "Take Me Back!", style: .default, handler: nil))
        self.present(failLogoutAlert, animated: true, completion: nil)
    }
}

// Removed redundant UIViewController extension, as these methods are in Convenience.swift

