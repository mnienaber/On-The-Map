//
//  Constants.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
// 

import UIKit

extension Client {
    
    struct Constants {
        
        struct Scheme {
            
            static let Method = "https://parse.udacity.com/parse/classes/StudentLocation"
            static let UdacUserMethod = "https://www.udacity.com/api/users/"
            static let ApiScheme = "https://"
            static let http = "http://"
            static let ApiHost = "parse.udacity.com"
            static let ApiPath = "parse/classes/StudentLocation"
            static let Limit = "?limit=50"
            static let Skip = "?limit=200&skip=400"
            static let Order = "?order=-updatedAt"
            static let LimitAndOrder = "?limit=100&order=-updatedAt"
        }

        struct ParameterKeys {
            static let ApiKey = "api_key"
            static let RequestToken = "request_token"
            static let SessionID = "session_id"
            static let Username = "username"
            static let Password = "password"
        }
        
        struct ParameterValues {
            
            static let ParseAPIKey = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            static let RestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        }
        
        struct ParseResponseKeys {
            
            static let ObjectId = "objectId"
            static let UniqueKey = "uniqueKey"
            static let FirstName = "firstName"
            static let LastName = "lastName"
            static let MapString = "mapString"
            static let MediaURL = "mediaURL"
            static var Latitude = "latitude"
            static let Longitude = "longitude"
            static let CreatedAt = "createdAt"
            static let UpdatedAt = "updatedAt"
            static let ACL = "ACL"
        }
        
        struct UdacityAccountDetails {
            
            static let Account_Registered = "registered"
            static let Account_Key = "key"
            static let Session_Id = "id"
            static let Session_Expiration = "expiration"
        }
        
        struct UdacityResponseKeys {
            
            static let Account_Details = "results"
            
        }
        
        struct UI {
            static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
            static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
            static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
            static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        }
        
        struct Selectors {
            static let KeyboardWillShow: Selector = "keyboardWillShow:"
            static let KeyboardWillHide: Selector = "keyboardWillHide:"
            static let KeyboardDidShow: Selector = "keyboardDidShow:"
            static let KeyboardDidHide: Selector = "keyboardDidHide:"
        }
        
        struct JSONResponseKeys {
            
            static let StudentLocationResults = "results"
        }
    }
}


