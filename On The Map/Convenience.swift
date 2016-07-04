////
////  Convenience.swift
////  On The Map
////
////  Created by Michael Nienaber on 23/05/2016.
////  Copyright © 2016 Michael Nienaber. All rights reserved.
////
//
import UIKit
import Foundation
//
////TODO: move all get and post methods and completion handlers here
////
extension Client {
    
    func getStudentLocations(completionHandlerForStudentLocations: (result: [StudentLocation]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [
            Client.Constants.ParameterValues.ParseAPIKey: Client.Constants.ParameterValues.ParseAPIKey,
            Client.Constants.ParameterValues.RestAPIKey: Client.Constants.ParameterValues.RestAPIKey,
        ]
        let url = Client.Constants.Scheme.Method + Client.Constants.Scheme.LimitAndOrder
        
        taskForGETMethod(url, parameters: parameters) { results, error in
            if let error = error {
                print(error)
            } else {
                if let results = results[Client.Constants.JSONResponseKeys.StudentLocationResults] as? [[String:AnyObject]] {
                    let locations = StudentLocation.SLOFromResults(results)
                    completionHandlerForStudentLocations(result: locations, error: nil)
                } else {
                    completionHandlerForStudentLocations(result: nil, error: error)
                }
            }
        }
        
    }
    
    func postToMap(completionHandlerForPOST: (result: Int?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [
            Client.Constants.ParameterValues.ParseAPIKey: Client.Constants.ParameterValues.ParseAPIKey,
            Client.Constants.ParameterValues.RestAPIKey: Client.Constants.ParameterValues.RestAPIKey,
            ]
        
        let jsonBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"Susan\", \"lastName\": \"Roads\",\"mapString\": \"Cape Town\", \"mediaURL\": \"https://udacity.com\",\"latitude\": -33.55555, \"longitude\": 18.22222}"
        
        let url = Client.Constants.Scheme.Method
        
        taskForPOSTMethod(url, parameters: parameters, jsonBody: jsonBody) { results, error in
            if let error = error {
                print(error)
            } else {
                if let results = results[Client.Constants.JSONResponseKeys.StudentLocationResults] as? Int {
                    //let locations = StudentLocation.SLOFromResults(results)
                    completionHandlerForPOST(result: results, error: nil)
                } else {
                    completionHandlerForPOST(result: nil, error: error)
                }
            }
        }
        
    }
}
