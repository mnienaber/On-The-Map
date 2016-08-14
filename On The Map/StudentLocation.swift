//
//  StudentLocation.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import Foundation

var studentLocationObjects = [StudentLocation]()

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
        
        objectId = dictionary[Client.Constants.ParseResponseKeys.ObjectId] as! String
        guard let unique = dictionary[Client.Constants.ParseResponseKeys.UniqueKey] as? String else { return nil }
        uniqueKey = unique //https://discussions.udacity.com/t/app-crashing-at-login-after-parse-update/182059/5?u=michael_135862232227
        firstName = dictionary[Client.Constants.ParseResponseKeys.FirstName] as! String
        lastName = dictionary[Client.Constants.ParseResponseKeys.LastName] as! String
        mapString = dictionary[Client.Constants.ParseResponseKeys.MapString] as! String
        mediaURL = dictionary[Client.Constants.ParseResponseKeys.MediaURL] as! String
        latitude = dictionary[Client.Constants.ParseResponseKeys.Latitude] as! Double
        longitude = dictionary[Client.Constants.ParseResponseKeys.Longitude] as! Double
        createdAt = dictionary[Client.Constants.ParseResponseKeys.CreatedAt] as! String
        updatedAt = dictionary[Client.Constants.ParseResponseKeys.UpdatedAt] as! String
    }
    
    static func SLOFromResults(results: [[String:AnyObject]]) -> [StudentLocation] {
        
        for result in results {
            
            if let studObjects = StudentLocation(dictionary: result) {
                
                studentLocationObjects.append(studObjects)
            }
        }
        print("\(studentLocationObjects)" + "this is studentlocationObject")
        return studentLocationObjects
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
