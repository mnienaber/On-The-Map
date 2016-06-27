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
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        
        textLocation.hidden = true
        myMiniMapView.hidden = false
        questionText.text! = "What's your media URL"
        questionText.textAlignment = .Center
        findOnTheMap.hidden = true
        submitOutlet.hidden = false
        myMediaUrl.hidden = false
        
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
                    let lat = item.placemark.coordinate.latitude
                    let long = item.placemark.coordinate.longitude
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
    
    
    @IBAction func submitButton(sender: AnyObject) {
        
        //TODO write function to post pin
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(Client.Constants.ParameterValues.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Client.Constants.ParameterValues.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type"
        request.HTTPBody = "{\"uniqueKey\": "Client.Constants.ParseResponseKeys.UniqueKey", \"firstName\":" Client.Constants.ParseResponseKeys.FirstName", \"lastName\": "Client.Constants.ParseResponseKeys.LastName",\"mapString\": "Client.Constants.ParseResponseKeys.MapString", \"mediaURL\": "Client.Constants.ParseResponseKeys.MediaURL",\"latitude\": "Client.Constants.ParseResponseKeys.Latitude", \"longitude\": "Client.Constants.ParseResponseKeys.UniqueKey"}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        
        
    }

}
