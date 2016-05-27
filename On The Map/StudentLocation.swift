//
//  StudentLocation.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import Foundation

struct StudentLocationObjects {
    
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Float
    let longitude: Float
    let createdAt: String
    let updatedAt: String
    //let ACL: Bool


    // construct a StudentLocationObject from a dictionary
    init(dictionary: [String:AnyObject]) {
        
        objectId = dictionary[Constants.ParseResponseKeys.ObjectId] as! String
        uniqueKey = dictionary[Constants.ParseResponseKeys.UniqueKey] as! String
        firstName = dictionary[Constants.ParseResponseKeys.FirstName] as! String
        lastName = dictionary[Constants.ParseResponseKeys.LastName] as! String
        mapString = dictionary[Constants.ParseResponseKeys.MapString] as! String
        mediaURL = dictionary[Constants.ParseResponseKeys.MediaURL] as! String
        latitude = dictionary[Constants.ParseResponseKeys.Latitude] as! Float
        longitude = dictionary[Constants.ParseResponseKeys.Longitude] as! Float
        createdAt = dictionary[Constants.ParseResponseKeys.CreatedAt] as! String
        updatedAt = dictionary[Constants.ParseResponseKeys.UpdatedAt] as! String
        //ACL = dictionary[Constants.ParseResponseKeys.ACL] as! Bool
    }
    
    static func SLOFromResults(results: [[String:AnyObject]]) -> [StudentLocationObjects] {
        
        var studentLocationObjects = [StudentLocationObjects]()
        
        // iterate through array of dictionaries, each studentLocationObject is a dictionary
        for result in results {
            studentLocationObjects.append(StudentLocationObjects(dictionary: result))
        }
        return studentLocationObjects
    }    
}