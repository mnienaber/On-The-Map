//
//  Client.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import Foundation

class Client : NSObject {
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // configuration object
    //var config = TMDBConfig()
    
    // authentication state
    var requestToken: String? = nil
    var sessionID : String? = nil
    var userID : Int? = nil
    
    override init() {
        super.init()
    }
    
    func taskForGETMethod(method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> [[String: AnyObject]] {
        
        var results:[[String:AnyObject]] = [] {
            didSet {
                NSNotificationCenter.defaultCenter().postNotificationName("results", object: nil)
            }
        }
        
        let methodParameters = [
            Constants.ParameterValues.ParseAPIKey: Constants.ParameterValues.ParseAPIKey,
            Constants.ParameterValues.RestAPIKey: Constants.ParameterValues.RestAPIKey
        ]
        
        //TODO: fix the variables for this server request:
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.Scheme.ApiScheme)" + "\(Constants.Scheme.ApiHost)" + "\(Constants.Scheme.ApiPath)" + "\(Constants.Scheme.LimitAndOrder)")!)
        request.addValue(Constants.ParameterValues.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParameterValues.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            
            /* 5. Parse the data */
//            let parsedResult: AnyObject!
//            do {
//                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
//            } catch {
//                print("Could not parse the data as JSON: '\(data)'")
//                return
//            }
            
            
            /* GUARD: Did Parse return an error? */
//            if let _ = parsedResult[Constants.ParseResponseKeys.ObjectId] as? String {
//                print("Parse returned an error. See the '\(Constants.ParseResponseKeys.ObjectId)")
//                return
//            }
//            
//            /* GUARD: Is the "FirstName" key in parsedResult? */
//            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
//                print("Cannot find your key, the status code is \(statusCode) and the full response is \(parsedResult)")
//                return
            }
            
            //print(NSString(data: data, encoding: NSUTF8StringEncoding))
            //            self.studentLocation = StudentLocationObjects.SLOFromResults(results)
            //            performUIUpdatesOnMain {
            //                self.tableView.reloadData()
            //print(results)
        
        
        task.resume()
        return results
        
    }
    
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // create a URL from parameters
    private func URLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Scheme.ApiScheme
        components.host = Constants.Scheme.ApiHost
        components.path = Constants.Scheme.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> Constants {
        struct Singleton {
            static var sharedInstance = Constants()
        }
        return Singleton.sharedInstance
    }
    
    
}