//
//  Convenience.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import Foundation

//TODO: move all get and post methods and completion handlers here

//func getLocations {
//    
//    let methodParameters = [
//        Constants.ParameterValues.ParseAPIKey: Constants.ParameterValues.ParseAPIKey,
//        Constants.ParameterValues.RestAPIKey: Constants.ParameterValues.RestAPIKey
//    ]
//    
//    //TODO: fix the variables for this server request:
//    
//    let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.Scheme.ApiScheme)" + "\(Constants.Scheme.ApiHost)" + "\(Constants.Scheme.ApiPath)")!)
//    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
//    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
//    let session = NSURLSession.sharedSession()
//    let task = session.dataTaskWithRequest(request) { data, response, error in
//        guard (error == nil) else {
//            print("There was an error with your request: \(error)")
//            return
//        }
//        
//        /* GUARD: Did we get a successful 2XX response? */
//        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
//            print("Your request returned a status code other than 2xx!")
//            return
//        }
//        
//        /* GUARD: Was there any data returned? */
//        guard let data = data else {
//            print("No data was returned by the request!")
//            return
//        }
//        
//        /* 5. Parse the data */
//        let parsedResult: AnyObject!
//        do {
//            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
//        } catch {
//            print("Could not parse the data as JSON: '\(data)'")
//            return
//        }
//        
//        
//        /* GUARD: Did TheMovieDB return an error? */
//        if let _ = parsedResult[Constants.ParseResponseKeys.ObjectId] as? String {
//            print("TheMovieDB returned an error. See the '\(Constants.ParseResponseKeys.ObjectId)")
//            return
//        }
//        
//        /* GUARD: Is the "results" key in parsedResult? */
//        guard let results = parsedResult[Constants.ParseResponseKeys.FirstName] as? [[String:AnyObject]] else {
//            print("Cannot find your fucking key in \(parsedResult)")
//            return
//        }
//        
//
//    }
//    task.resume()
//}
//}