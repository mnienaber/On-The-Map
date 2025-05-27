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
import SystemConfiguration

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
    var session: URLSession!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    let regionRadius: CLLocationDistance = 2000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                                  latitudinalMeters: regionRadius * 3.0, longitudinalMeters: regionRadius * 1.0)
        myMiniMapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMiniMapView.delegate = self
        myMiniMapView.isHidden = true
        textLocation.isHidden = false
        myMediaUrl.isHidden = true
        submitOutlet.isHidden = true
        questionText.text = "Where are you studying today?"
        questionText.textAlignment = .center
        dimOutlet.isHidden = true
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dimOutlet.isHidden = true
        // Keyboard notifications are now handled by the extension in Convenience.swift
        // self.subscribeToKeyboardNotifications() 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Keyboard notifications are now handled by the extension in Convenience.swift
        // self.unsubscribeToKeyboardNotifications()
    }
    
    @IBAction func findOnTheMap(_ sender: AnyObject) {
        
        activityOutlet.startAnimating()
        dimOutlet.isHidden = false
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = self.textLocation.text!
        request.region = myMiniMapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            performUIUpdatesOnMain { // Ensure UI updates are on the main thread
                self.activityOutlet.stopAnimating()
                self.dimOutlet.isHidden = true
                
                if let error = error {
                    let failSearchAlert = UIAlertController(title: "Oops!", message: "Either you have a problem with your connection or your query returned zero results. Error: \(error.localizedDescription)", preferredStyle: .alert)
                    failSearchAlert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { alertAction in self.returnToMapView() }))
                    self.present(failSearchAlert, animated: true, completion: nil)
                    print("There was an error searching for: \(String(describing: request.naturalLanguageQuery)) error: \(error)")
                } else {
                    self.textLocation.isHidden = true
                    self.myMiniMapView.isHidden = false
                    self.questionText.text! = "What's your media URL"
                    self.questionText.textAlignment = .center
                    self.findOnTheMap.isHidden = true
                    self.submitOutlet.isHidden = false
                    self.myMediaUrl.isHidden = false
                    self.dismissAnyVisibleKeyboards()
                    
                    self.annotations.removeAll() // Clear previous search results
                    guard let response = response else { return }
                    for item in response.mapItems {
                        let annotation = MKPointAnnotation()
                        let lat = item.placemark.coordinate.latitude
                        let long = item.placemark.coordinate.longitude
                        let title = item.placemark.title
                        
                        let initialLocation = CLLocation(latitude: lat, longitude: long)
                        self.centerMapOnLocation(initialLocation)
                        
                        annotation.coordinate = item.placemark.coordinate
                        annotation.title = title
                        self.annotations.append(annotation)
                        
                        // Update AppDelegate with the first found location details
                        if self.annotations.count == 1 { // Only set for the first item or based on specific logic
                            self.appDelegate.latitude = lat
                            self.appDelegate.longitude = long
                            self.appDelegate.mapString = title
                        }
                    }
                    self.myMiniMapView.addAnnotations(self.annotations)
                    
                    // Get user info after finding location if accountKey is a String
                    if let accountKeyString = self.appDelegate.accountKey as? String {
                        self.getUserInfo(accountKeyString)
                    } else {
                        print("Account key is not a String or is nil.")
                        // Handle error: maybe user needs to log in again or accountKey is missing
                        self.failPost("Error", message: "User account key is missing or invalid. Cannot proceed.", action: "OK")
                    }
                }
            }
        }
    }
    
    func postStudentLocation(_ studentLocationData: Client.StudentLocationPost) {
        if Reachability.isConnectedToNetwork() == false {
            self.dimOutlet.isHidden = true
            self.activityOutlet.stopAnimating()
            let failPostAlert = UIAlertController(title: "No Internet Connection", message: "Please check your connection and try again", preferredStyle: .alert)
            failPostAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(failPostAlert, animated: true, completion: nil)
        } else {
            Client.sharedInstance().postToMap(locationData: studentLocationData) { [weak self] (postResponse, error) in
                guard let self = self else { return }
                performUIUpdatesOnMain {
                    self.dimOutlet.isHidden = true
                    self.activityOutlet.stopAnimating()
                    if let error = error {
                        print("Error posting student location: \(error.localizedDescription)")
                        self.failPost("Yikes", message: "There seems to be a problem, your post didn't execute! \(error.localizedDescription)", action: "OK")
                    } else {
                        print("Successfully posted student location: \(String(describing: postResponse))")
                        self.returnToMapView()
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: AnyObject) {
        
        self.appDelegate.mediaUrl = nil
        self.appDelegate.mapString = nil
        self.appDelegate.latitude = nil
        self.appDelegate.longitude = nil
        
        returnToMapView()
    }
    
    func returnToMapView() {

        Client.sharedInstance().getStudentLocations() { [weak self] (studentLocations, error) in
            guard let self = self else { return }
            performUIUpdatesOnMain {
                self.dimOutlet.isHidden = true // Ensure these are hidden regardless of outcome
                self.activityOutlet.stopAnimating() // Ensure these are hidden regardless of outcome
                if let error = error {
                    print("Error fetching student locations in returnToMapView: \(error.localizedDescription)")
                    // Optionally, show an alert to the user if returning to map fails to refresh data
                } else if studentLocations != nil {
                    print("Refreshed student locations successfully in returnToMapView.")
                    // Data is in StudentModel, Map/List view will pick it up on their viewWillAppear
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func getUserInfo(_ accountKeyString: String) { // Changed parameter to String
        Client.sharedInstance().getUserCompleteInfo(accountKey: accountKeyString) { [weak self] (userInfoResponse, error) in
            guard let self = self else { return }
            performUIUpdatesOnMain { // Ensure UI updates are on the main thread
                // No need to hide dimOutlet/activityOutlet here as this is called after map search
                if let error = error {
                    print("Error fetching user info: \(error.localizedDescription)")
                    let failAlert = UIAlertController(title: "Oops", message: "We weren't able to capture your user info. \(error.localizedDescription)", preferredStyle: .alert)
                    failAlert.addAction(UIAlertAction(title: "Try Again Later", style: .default, handler: { _ in self.returnToMapView() }))
                    failAlert.addAction(UIAlertAction(title: "Log Me Out", style: .default, handler: { _ in self.logOut() }))
                    self.present(failAlert, animated: true, completion: nil)
                } else if let userInfo = userInfoResponse {
                    // AppDelegate is already updated by Convenience method
                    print("Successfully fetched user info: \(userInfo.user.firstName ?? "") \(userInfo.user.lastName ?? "")")
                } else {
                     self.failPost("Error", message: "Failed to get user info: Unknown error.", action: "OK")
                }
            }
        }
    }

    @IBAction func submitButton(_ sender: AnyObject) {
        performUIUpdatesOnMain {
            self.dimOutlet.isHidden = false
            self.activityOutlet.startAnimating()
        }

        let mediaURLString = self.myMediaUrl.text ?? ""
        var finalMediaURL = ""

        if verifyUrl(mediaURLString) { // verifyUrl is from UIViewController extension
            if mediaURLString.hasPrefix("http://") || mediaURLString.hasPrefix("https://") {
                finalMediaURL = mediaURLString
            } else {
                finalMediaURL = Client.Constants.Scheme.http + mediaURLString // Prepend http if missing
            }
            self.appDelegate.mediaUrl = finalMediaURL
        } else {
            performUIUpdatesOnMain {
                self.failPost("Invalid URL", message: "Please provide a valid media URL.", action: "OK")
                self.dimOutlet.isHidden = true
                self.activityOutlet.stopAnimating()
            }
            return
        }
        
        // Ensure all required appDelegate properties are set
        guard let uniqueKey = self.appDelegate.accountKey as? String, // Assuming accountKey is the uniqueKey
              let firstName = self.appDelegate.firstName,
              let lastName = self.appDelegate.lastName,
              let mapString = self.appDelegate.mapString,
              let latitude = self.appDelegate.latitude,
              let longitude = self.appDelegate.longitude else {
            performUIUpdatesOnMain {
                self.failPost("Missing Information", message: "Some required user or location data is missing. Please try finding location again.", action: "OK")
                self.dimOutlet.isHidden = true
                self.activityOutlet.stopAnimating()
            }
            return
        }
        
        let studentLocationData = Client.StudentLocationPost(
            uniqueKey: uniqueKey,
            firstName: firstName,
            lastName: lastName,
            mapString: mapString,
            mediaURL: finalMediaURL,
            latitude: latitude,
            longitude: longitude
        )
        
        postStudentLocation(studentLocationData)
    }
    
    func failPost(title: String, message: String, action: String) {
        performUIUpdatesOnMain {
            let failPostAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            failPostAlert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
            self.present(failPostAlert, animated: true, completion: nil)
        }
    }
}

// Removed redundant LocationViewController extension for verifyUrl, dismissAnyVisibleKeyboards, logOut
// verifyUrl is in UIViewController extension (Convenience.swift)
// dismissAnyVisibleKeyboards and logOut are specific enough to remain in the main class body if preferred, or moved to an extension if desired for organization.
// For now, keeping them in the main class body is fine.
extension LocationViewController {
    // Specific helper methods for this VC can remain in an extension if desired for organization
    func dismissAnyVisibleKeyboards() {
        if textLocation.isFirstResponder || myMediaUrl.isFirstResponder {
            self.view.endEditing(true)
        }
    }

    func logOut() {
        // Clear sensitive data from AppDelegate
        self.appDelegate.accountKey = nil
        self.appDelegate.accountRegistered = nil // Assuming this is still relevant
        self.appDelegate.sessionID = nil
        self.appDelegate.sessionExpiration = nil
        self.appDelegate.firstName = nil
        self.appDelegate.lastName = nil
        // Optionally call a method to clear any other session-specific data
        
        // Perform logout on the main thread
        performUIUpdatesOnMain {
            // Dismiss this view controller to return to the login screen or main interface
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    // verifyUrl is already available via UIViewController extension from Convenience.swift
}