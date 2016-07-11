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
        
        let jsonBody = "{\"uniqueKey\": \"\(self.appDelegate.accountKey!)\", \"firstName\": \"\(self.appDelegate.firstName!)\", \"lastName\": \"\(self.appDelegate.lastName!)\",\"mapString\": \"\(self.appDelegate.mapString!)\", \"mediaURL\": \"\(self.appDelegate.mediaUrl!)\",\"latitude\": \(self.appDelegate.latitude!), \"longitude\": \(self.appDelegate.londitude!)}"
        
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
    
    func getUserInfo(accountKey: String, completionHandlerForStudentLocations: (result: [StudentLocation]?, error: NSError?) -> Void) {

        let parameters = [
            Client.Constants.ParameterValues.ParseAPIKey: Client.Constants.ParameterValues.ParseAPIKey,
            Client.Constants.ParameterValues.RestAPIKey: Client.Constants.ParameterValues.RestAPIKey,
            ]
            
        let url = Client.Constants.Scheme.UdacUserMethod + accountKey
        
        taskForGETMethod(url, parameters: parameters) { results, error in
            if let error = error {
                print(error)
            } else {
//                if let results = results[Client.Constants.JSONResponseKeys.StudentLocationResults] as? [[String:AnyObject]] {
//                    let locations = StudentLocation.SLOFromResults(results)
//                    completionHandlerForStudentLocations(result: locations, error: nil)
//                } else {
//                    completionHandlerForStudentLocations(result: nil, error: error)
//                }
                print(results)
            }
        }
        
    }
}
