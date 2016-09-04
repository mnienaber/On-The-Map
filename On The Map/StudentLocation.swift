//
//  StudentLocation.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import Foundation

var accountVerificationObjects = [AccountVerification]()

struct StudentLocation {
    
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let createdAt: String
    let updatedAt: String

    init?(dictionary: [String:AnyObject]) {

        //https://discussions.udacity.com/t/app-crashing-at-login-after-parse-update/182059/5?u=michael_135862232227

        guard let object = dictionary[Client.Constants.ParseResponseKeys.ObjectId] as? String else { return nil }
        objectId = object
        guard let unique = dictionary[Client.Constants.ParseResponseKeys.UniqueKey] as? String else { return nil }
        uniqueKey = unique
        guard let first = dictionary[Client.Constants.ParseResponseKeys.FirstName] as? String else { return nil }
        firstName = first
        guard let last = dictionary[Client.Constants.ParseResponseKeys.LastName] as? String else { return nil }
        lastName = last
        guard let map = dictionary[Client.Constants.ParseResponseKeys.MapString] as? String else { return nil }
        mapString = map
        guard let url = dictionary[Client.Constants.ParseResponseKeys.MediaURL] as? String else { return nil }
        mediaURL = url
        guard let lat = dictionary[Client.Constants.ParseResponseKeys.Latitude] as? Double else { return nil }
        latitude = lat
        guard let long = dictionary[Client.Constants.ParseResponseKeys.Longitude] as? Double else { return nil }
        longitude = long
        guard let created = dictionary[Client.Constants.ParseResponseKeys.CreatedAt] as? String else { return nil }
        createdAt = created
        guard let updated = dictionary[Client.Constants.ParseResponseKeys.UpdatedAt] as? String else { return nil }
        updatedAt = updated
    }

    static func SLOFromResults(results: [[String:AnyObject]]) -> [StudentLocation] {

        for result in results {
            
            if let studObjects = StudentLocation(dictionary: result) {
                
                StudentModel.sharedInstance().studentLocation.append(studObjects)
            }
        }
        return StudentModel.sharedInstance().studentLocation
    }
}

struct AccountVerification {
    
    let accountRegistered: Int
    let accountKey: Int
    let sessionId: String
    let sessionExpiration: String
    
    init(dictionary: [String: AnyObject]) {
        
        accountRegistered = dictionary[Client.Constants.UdacityAccountDetails.Account_Registered] as! Int
        accountKey = dictionary[Client.Constants.UdacityAccountDetails.Account_Key] as! Int
        sessionId = dictionary[Client.Constants.UdacityAccountDetails.Session_Id] as! String
        sessionExpiration = dictionary[Client.Constants.UdacityAccountDetails.Session_Expiration] as! String

    }
    
    static func LOGFromResults(results: [[String:AnyObject]]) -> [AccountVerification] {
        
        var accountVerificationObjects = [AccountVerification]()

        for result in results {
            accountVerificationObjects.append(AccountVerification(dictionary: result))
        }
        print(accountVerificationObjects)
        return accountVerificationObjects
    }
}
