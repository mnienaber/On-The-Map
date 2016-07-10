//
//  LocationViewController.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class LocationViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate {
    
    var myStudentLocation: [StudentLocation] = [StudentLocation]()
    let mapView = MapViewController()
    var annotations = [MKPointAnnotation]()
    
    @IBOutlet weak var textLocation: UITextField!
    @IBOutlet weak var findOnTheMap: UIButton!
    @IBOutlet weak var myMiniMapView: MKMapView!
    @IBOutlet weak var submitOutlet: UIButton!
    @IBOutlet weak var myMediaUrl: UITextField!
    @IBOutlet weak var questionText: UITextView!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    let regionRadius: CLLocationDistance = 2000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 3.0, regionRadius * 1.0)
        myMiniMapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMiniMapView.delegate = self
        myMiniMapView.hidden = true
        textLocation.hidden = false
        myMediaUrl.hidden = true
        submitOutlet.hidden = true
        questionText.text = "Where are you studying today?"
        questionText.textAlignment = .Center
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.subscribeToKeyboardNotifications()
        self.unsubscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    

    
//    func mapVivarmapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        
//        let reuseId = "pin"
//        
//        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
//        
//        if pinView == nil {
//            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            pinView!.canShowCallout = true
//            pinView!.pinColor = .Red
//            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
//        }
//        else {
//            pinView!.annotation = annotation
//        }
//        
//        return pinView
//    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        
        textLocation.hidden = true
        myMiniMapView.hidden = false
        questionText.text! = "What's your media URL"
        questionText.textAlignment = .Center
        findOnTheMap.hidden = true
        submitOutlet.hidden = false
        myMediaUrl.hidden = false
        dismissAnyVisibleKeyboards()
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = self.textLocation.text!
        request.region = myMiniMapView.region
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, error in
            guard let response = response else {
                print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
                return
            }
            
            [self.myStudentLocation = self.myStudentLocation]
            performUIUpdatesOnMain {
                
                for item in response.mapItems {
                    
                    let annotation = MKPointAnnotation()
                    var lat = item.placemark.coordinate.latitude
                    var long = item.placemark.coordinate.longitude
                    let title = item.placemark.title
                    let initialLocation = CLLocation(latitude: lat, longitude: long)
                    
                    self.centerMapOnLocation(initialLocation)
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    annotation.coordinate = coordinate
                    annotation.title = title
                    print(annotation.title)
                    print(annotation.coordinate)
                    self.annotations.append(annotation)                    
                }
                self.myMiniMapView.addAnnotations(self.annotations)
            }
            
        }
        
    }
    
    func getPostToMap() {
        
        Client.sharedInstance().postToMap { (statusCode, error) in
            if let error = error {
                print(error)
                
            } else {
                
                performUIUpdatesOnMain {
                    
                    print("success")
                }
                
            }
        }
        
    }
    
    
    @IBAction func submitButton(sender: AnyObject) {
            
            self.getPostToMap()
            
        }
    }

extension LocationViewController {
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LocationViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    func dismissAnyVisibleKeyboards() {
        if textLocation.isFirstResponder() || myMediaUrl.isFirstResponder() {
            self.view.endEditing(true)
        }
    }
}