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
    
    
    @IBOutlet weak var activityOutlet: UIActivityIndicatorView!
    @IBOutlet weak var dimOutlet: UIView!
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
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
        dimOutlet.hidden = true
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        dimOutlet.hidden = true
        self.subscribeToKeyboardNotifications()
        self.unsubscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.unsubscribeToKeyboardNotifications()
    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        
        
        activityOutlet.startAnimating()
        dimOutlet.hidden = false
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = self.textLocation.text!
        request.region = myMiniMapView.region
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, error in
            
            self.activityOutlet.stopAnimating()
            self.dimOutlet.hidden = true
            
            if let error = error {
                
                let failSearchAlert = UIAlertController(title: "Oops!", message: "Either you have a problem with your connection or your query returned zero results", preferredStyle: UIAlertControllerStyle.Alert)
                failSearchAlert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: { alertAction in self.returnToMapView() }))
                self.presentViewController(failSearchAlert, animated: true, completion: nil)
                print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
            } else {
                
                self.textLocation.hidden = true
                self.myMiniMapView.hidden = false
                self.questionText.text! = "What's your media URL"
                self.questionText.textAlignment = .Center
                self.findOnTheMap.hidden = true
                self.submitOutlet.hidden = false
                self.myMediaUrl.hidden = false
                self.dismissAnyVisibleKeyboards()
                
                [self.myStudentLocation = self.myStudentLocation]
                performUIUpdatesOnMain {
                    
                    for item in response!.mapItems {
                        
                        let annotation = MKPointAnnotation()
                        let lat = item.placemark.coordinate.latitude
                        let long = item.placemark.coordinate.longitude
                        let title = item.placemark.title
                        let initialLocation = CLLocation(latitude: lat, longitude: long)
                        
                        self.centerMapOnLocation(initialLocation)
                        
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        
                        annotation.coordinate = coordinate
                        annotation.title = title
                        self.annotations.append(annotation)
                        self.appDelegate.latitude = lat
                        self.appDelegate.longitude = long
                        self.appDelegate.mapString = title
                        
                    }
                    self.myMiniMapView.addAnnotations(self.annotations)
                    self.getUserInfo(self.appDelegate.accountKey!)
                }

            }
            
                    }
    }
    
    func getPostToMap(jsonBody: String) {
        
        Client.sharedInstance().postToMap(jsonBody) { (result, error) in
            
            if error != nil {
                
                self.dimOutlet.hidden = true
                self.activityOutlet.stopAnimating()
                print(error)
                let failPostAlert = UIAlertController(title: "Yikes", message: "There seems to be a problem, your post didn't execute!", preferredStyle: UIAlertControllerStyle.Alert)
                failPostAlert.addAction(UIAlertAction(title: "I'll try again later", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(failPostAlert, animated: true, completion: { alertAction in self.returnToMapView() })
                
            } else {
                
                self.dimOutlet.hidden = true
                self.activityOutlet.stopAnimating()
                print("success")
                self.returnToMapView()
            }
        }
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        
        self.appDelegate.mediaUrl = nil
        self.appDelegate.mapString = nil
        self.appDelegate.latitude = nil
        self.appDelegate.longitude = nil
        
        returnToMapView()
    }
    
    func returnToMapView() {

        Client.sharedInstance().getStudentLocations() { (results, error) in

            if error != nil {

                print("that's an error")
                self.dimOutlet.hidden = true
                self.activityOutlet.stopAnimating()
                self.dismissViewControllerAnimated(true, completion: nil)

            } else {

                performUIUpdatesOnMain {

                    print("refresh is \(results)")
                    self.dimOutlet.hidden = true
                    self.activityOutlet.stopAnimating()
                    self.dismissViewControllerAnimated(true, completion: nil)

                }
            }
        }
    }
    
    func getUserInfo(accountKey: AnyObject) {

        Client.sharedInstance().getUserCompleteInfo(self.appDelegate.accountKey!) { (result, error) in

            if error != nil {

                self.dimOutlet.hidden = true
                self.activityOutlet.stopAnimating()
                print(error)
                let failPostAlert = UIAlertController(title: "Oops", message: "We weren't able to capture your userinfo so you will not be able to post to the map", preferredStyle: UIAlertControllerStyle.Alert)
                failPostAlert.addAction(UIAlertAction(title: "I'll log out try again later", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(failPostAlert, animated: true, completion: { alertAction in self.returnToMapView() })
                failPostAlert.addAction(UIAlertAction(title: "Log me out", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(failPostAlert, animated: true, completion: { alertAction in self.logOut() })

            } else {

                print("success")
            }
        }
    }

    @IBAction func submitButton(sender: AnyObject) {
        
        dimOutlet.hidden = false
        activityOutlet.startAnimating()
        
        if verifyUrl(self.myMediaUrl.text!) == true {

//        ((self.myMediaUrl.text!.rangeOfString("http://") != nil) && verifyUrl(self.myMediaUrl.text!) = true)  || (self.myMediaUrl.text!.rangeOfString("https://")) != nil)
            
            self.appDelegate.mediaUrl = self.myMediaUrl.text!
        } else if verifyUrl(self.myMediaUrl.text!) == false {

            failPost()
            
//            self.appDelegate.mediaUrl = Client.Constants.Scheme.http + self.myMediaUrl.text!
        }
        
        let jsonBody: String = "{\"uniqueKey\": \"\(self.appDelegate.accountKey!)\", \"firstName\": \"\(self.appDelegate.firstName!)\", \"lastName\": \"\(self.appDelegate.lastName!)\",\"mapString\": \"\(self.appDelegate.mapString!)\", \"mediaURL\": \"\(self.appDelegate.mediaUrl!)\",\"latitude\": \(self.appDelegate.latitude!), \"longitude\": \(self.appDelegate.longitude!)}"
        
        self.getPostToMap(jsonBody)
    }
    
    func failPost() {
        
        let failPostAlert = UIAlertController(title: "Yikes", message: "There seems to be a problem, your post didn't execute!", preferredStyle: UIAlertControllerStyle.Alert)
        failPostAlert.addAction(UIAlertAction(title: "I'll try again later", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(failPostAlert, animated: true, completion: { alertAction in self.returnToMapView() })
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

    func logOut() {

        self.appDelegate.accountKey = nil
        self.appDelegate.accountRegistered = nil
        self.appDelegate.sessionID = nil
        self.appDelegate.sessionExpiration = nil
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
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