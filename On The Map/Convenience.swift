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
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(Client.Constants.ParameterValues.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Client.Constants.ParameterValues.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        print("afterrequest")
        print(request)
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
            print("newdata3")
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
    func loginToApp(username: String, password: String, completionHandlerForLOGIN: (details: [String: AnyObject]?, error: NSError?) -> Void) {
        
        let param = "{\"udacity\": {\"username\":\"\(username)\", \"password\":\"\(password)\"}}"
        
        taskForLOGINMethod(param) { (results, error) in
            
            if let error = error {
                
                completionHandlerForLOGIN(details: nil, error: error)
                
            } else {
                
                if let results = results["account"] as? [String: AnyObject]? {
                    completionHandlerForLOGIN(details: results, error: nil)
                } else {
                    
                    completionHandlerForLOGIN(details: nil, error: error)
                }
            }
        }
    }
}
