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

extension Client {
    
    func getStudentLocations(completionHandlerForStudentLocations: (result: [StudentLocationObjects]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [TMDBClient.ParameterKeys.SessionID: TMDBClient.sharedInstance().sessionID!]
        var mutableMethod: String = Methods.AccountIDFavoriteMovies
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: TMDBClient.URLKeys.UserID, value: String(TMDBClient.sharedInstance().userID!))!
        
        /* 2. Make the request */
        taskForGETMethod(mutableMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForFavMovies(result: nil, error: error)
            } else {
                
                if let results = results[TMDBClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
                    
                    let movies = TMDBMovie.moviesFromResults(results)
                    completionHandlerForFavMovies(result: movies, error: nil)
                } else {
                    completionHandlerForFavMovies(result: nil, error: NSError(domain: "getFavoriteMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getFavoriteMovies"]))
                }
            }
        }
    }
    
    }
}