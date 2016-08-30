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

extension Client {
    
    func getStudentLocations(completionHandlerForStudentLocations: (result: [StudentLocation]?, error: NSError?) -> Void) {

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

                    StudentModel.sharedInstance().studentLocation = []
                    let locations = StudentLocation.SLOFromResults(results)
                    StudentModel.sharedInstance().studentLocation = locations
                    completionHandlerForStudentLocations(result: locations, error: nil)
                } else {
                    
                    completionHandlerForStudentLocations(result: nil, error: error)
                }
            }
        }
    }
    
    func postToMap(jsonBody: String, completionHandlerForPOST: (result: Int?, error: NSError?) -> Void) {
        
        
        taskForPOSTMethod(jsonBody) { results, error in
            
            if let error = error {
                
                print("\(error)" + "posttomap error")
            } else {
                
                if let results = results as? Int? {
                    
                    completionHandlerForPOST(result: results, error: nil)
                } else {
                    
                    completionHandlerForPOST(result: nil, error: error)
                }
            }
        }
    }
    
    func loginToApp(username: String, password: String, completionHandlerForLOGIN: (details: [String: AnyObject]?, error: NSError?) -> Void) {
        
        let param = "{\"udacity\": {\"username\":\"\(username)\", \"password\":\"\(password)\"}}"
        
        taskForLOGINMethod(param) { (results, error) in
            
            if let error = error {
                
                completionHandlerForLOGIN(details: nil, error: error)
                
            } else {
                
                if let results = results as? [String: AnyObject]? {
                    completionHandlerForLOGIN(details: results, error: nil)
                } else {
                    
                    completionHandlerForLOGIN(details: nil, error: error)
                }
            }
        }
    }
    
    func getUserCompleteInfo(accountKey: AnyObject, completionHandlerForUSERINFO: (result: AnyObject!, error: NSError?) -> Void) {

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        taskForUSERINFOMethod(accountKey) { (result, error) in

            if let error = error {

                completionHandlerForUSERINFO(result: nil, error: error)
            } else {

                if let result = result as? [String: AnyObject]? {

                    let user = result!["user"]!

                    if let lastName = user["last_name"] as? String {

                        self.appDelegate.lastName = lastName
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            print("Failed to get (lastname).")
                        }
                    }

                    if let firstName = user["first_name"] as? String {

                        self.appDelegate.firstName = firstName
                    } else {

                        dispatch_async(dispatch_get_main_queue()) {
                            print("Failed to get (firstname).")
                        }
                    }

                    completionHandlerForUSERINFO(result: result, error: nil)
                } else {

                    completionHandlerForUSERINFO(result: nil, error: error)
                }
            }
        }
    }

    func deleteSession(completionHandlerForDELETE: (result: AnyObject!, error: NSError?) -> Void) {

        taskForDeleteSession() { (result, error) in

            if let error = error {

                completionHandlerForDELETE(result: nil, error: error)

            } else {

                if let result = result as? [String: AnyObject]? {

                    let deleteResult = result!["session"]!
                    completionHandlerForDELETE(result: deleteResult, error: nil)
                }
            }
        }
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


