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
        
        let url = Client.Constants.Scheme.Method
        
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
    
    func postToMap(jsonBody: String, completionHandlerForPOST: (result: Int?, error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(Client.Constants.ParameterValues.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Client.Constants.ParameterValues.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                
                func displayError(error: String, debugLabelText: String? = nil) {
                    print(error)
                    performUIUpdatesOnMain {
                        "fail"
                    }
                }
                
                guard (error == nil) else {
                    displayError("There was an error with your request: \(error)")
                    return
                }
                
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    displayError("Your request returned a status code other than 2xx!")
                    return
                }
                
                guard let data = data else {
                    displayError("No data was returned by the request!")
                    return
                }
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                    print(parsedResult!)
                } catch {
                    print("Error: Parsing JSON data")
                    return
                }
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
    func loginToApp(username: String, password: String, completionHandlerForLogin: (statusCode: Int?, error: NSError?) -> Void) {
        
        var param = "{\"udacity\": {\"username\":\"\(username)\", \"password\":\"\(password)\"}}"
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = param.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        print(param)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func displayError(error: String, debugLabelText: String? = nil) {
                print(error)
                performUIUpdatesOnMain {
//                    self.setUIEnabled(true)
//                    self.debugText.text = "Login Failed (Session ID)."
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Error: Parsing JSON data")
                return
            }
            
            let account = parsedResult["account"]!
            print(account)
            let sessionDict = parsedResult["session"]!
            print(sessionDict)
            
            if let accountKey = account!["key"] as? Int {
                self.appDelegate.accountKey = accountKey
                print(accountKey)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    //self.debugText.text = "Login Failed (accountKey)."
                    print("Login Failed (accountKey).")
                }
            }
            
            if let accountRegistered = account!["registered"] as? Int {
                
                self.appDelegate.accountRegistered = accountRegistered
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    //self.debugText.text = "Login Failed (accountRegistered)."
                    print("Login Failed (accountRegistered).")
                }
            }
            
            if let sessionExpiration = sessionDict!["expiration"] as? String {
                self.appDelegate.sessionExpiration = sessionExpiration
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    //self.debugText.text = "Login Failed (accountKey)."
                    print("Login Failed (accountKey).")
                }
            }
            
            if let sessionID = sessionDict!["id"] as? String {
                self.appDelegate.sessionID = sessionID
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    //self.debugText.text = "Login Failed (sessExpiration)."
                    print("Login Failed (sessExpiration).")
                }
            }
        }
        task.resume()
    }

}
