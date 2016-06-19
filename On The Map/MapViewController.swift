//
//  MapViewController.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//
import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    var studentLocation: [StudentLocation] = [StudentLocation]()

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        getMapLocations()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    //    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //
    //        if control == annotationView.rightCalloutAccessoryView {
    //            let app = UIApplication.sharedApplication()
    //            app.openURL(NSURL(string: annotationView.annotation.subtitle))
    //        }
    //    }
    
    // MARK: - Sample Data
    
    // Some sample data. This is a dictionary that is more or less similar to the
    // JSON data that you will download from Parse.
    
    func getMapLocations() {
        
        Client.sharedInstance().getStudentLocations { (studentLocation, errorString) in
            if let studentLocation = studentLocation {
                [self.studentLocation = studentLocation]
                var annotations = [MKPointAnnotation]()
                performUIUpdatesOnMain {
                    for student in self.studentLocation {
                        
                        let lat = CLLocationDegrees(student.latitude)
                        let long = CLLocationDegrees(student.longitude)
                        
                        // The lat and long are used to create a CLLocationCoordinates2D instance.
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        
                        //let first = students["firstName"] as! String
                        let first = student.firstName
                        let last = student.lastName
                        let mediaURL = student.mediaURL
                        
                        // Here we create the annotation and set its coordiate, title, and subtitle properties
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = mediaURL
                        print(annotation.title)
                        // Finally we place the annotation in an array of annotations.
                        annotations.append(annotation)
                    }
                    self.mapView.addAnnotations(annotations)
                }
            }
            
    }
    
//    func StudentLocationData() -> [[String:AnyObject]] {
//        
//        var results:[[String:AnyObject]] = [] {
//            didSet {
//                NSNotificationCenter.defaultCenter().postNotificationName("results", object: nil)
//            }
//        }
//        
//        //TODO: fix the variables for this server request:
//        
//        let request = NSMutableURLRequest(URL: NSURL(string: "\(Client.Constants.Scheme.ApiScheme)" + "\(Client.Constants.Scheme.ApiHost)" + "\(Client.Constants.Scheme.ApiPath)" + "\(Client.Constants.Scheme.LimitAndOrder)")!)
//        request.addValue(Client.Constants.ParameterValues.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
//        request.addValue(Client.Constants.ParameterValues.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithRequest(request) { data, response, error in
//            guard (error == nil) else {
//                print("There was an error with your request: \(error)")
//                return
//            }
//            
//            /* GUARD: Did we get a successful 2XX response? */
//            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
//                print("Your request returned a status code other than 2xx!")
//                return
//            }
//            
//            /* GUARD: Was there any data returned? */
//            guard let data = data else {
//                print("No data was returned by the request!")
//                return
//            }
//            
//            /* 5. Parse the data */
//            let parsedResult: AnyObject!
//            do {
//                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
//            } catch {
//                print("Could not parse the data as JSON: '\(data)'")
//                return
//            }
//            
//            
//            /* GUARD: Did Parse return an error? */
//            if let _ = parsedResult[Client.Constants.ParseResponseKeys.ObjectId] as? String {
//                print("Parse returned an error. See the '\(Client.Constants.ParseResponseKeys.ObjectId)")
//                return
//            }
//            
//            /* GUARD: Is the "FirstName" key in parsedResult? */
//            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
//                print("Cannot find your key, the status code is \(statusCode) and the full response is \(parsedResult)")
//                return
//            }
//            
//            //print(NSString(data: data, encoding: NSUTF8StringEncoding))
//            self.studentLocation = StudentLocation.SLOFromResults(results)
//            print(results)
//        }
//        task.resume()
//        return results
        
    }
    
}

