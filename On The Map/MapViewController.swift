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
    
    var studentLocation: [StudentLocationObjects] = [StudentLocationObjects]()

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        let locations = Client.taskForGETMethod(method, parameters,
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        print("after annotations")
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for dictionary in locations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
            let long = CLLocationDegrees(dictionary["longitude"] as! Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary["firstName"] as! String
            let last = dictionary["lastName"] as! String
            let mediaURL = dictionary["mediaURL"] as! String
            print("after in for dic")
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        
        }
        print(annotations)
        self.mapView.delegate = self
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        print("after mapview")
        
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
    
//    func StudentLocationData() -> [[String:AnyObject]] {
//        
//        var results:[[String:AnyObject]] = [] {
//            didSet {
//                NSNotificationCenter.defaultCenter().postNotificationName("results", object: nil)
//            }
//        }
//        
//        let methodParameters = [
//            Constants.ParameterValues.ParseAPIKey: Constants.ParameterValues.ParseAPIKey,
//            Constants.ParameterValues.RestAPIKey: Constants.ParameterValues.RestAPIKey
//        ]
//        
//        //TODO: fix the variables for this server request:
//        
//        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.Scheme.ApiScheme)" + "\(Constants.Scheme.ApiHost)" + "\(Constants.Scheme.ApiPath)" + "\(Constants.Scheme.LimitAndOrder)")!)
//        request.addValue(Constants.ParameterValues.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
//        request.addValue(Constants.ParameterValues.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
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
//            if let _ = parsedResult[Constants.ParseResponseKeys.ObjectId] as? String {
//                print("Parse returned an error. See the '\(Constants.ParseResponseKeys.ObjectId)")
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
////            self.studentLocation = StudentLocationObjects.SLOFromResults(results)
////            performUIUpdatesOnMain {
////                self.tableView.reloadData()
//            //print(results)
//        }
//        task.resume()
//        return results
//        
//    }
    
}

