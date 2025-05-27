//
//  StudentLocation.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import Foundation

// var accountVerificationObjects = [AccountVerification]() // This global variable seems unused or will be replaced by direct decoding.

struct StudentLocation: Codable {
    
    let objectId: String
    let uniqueKey: String? // Made optional as per Parse API, sometimes it might be missing for new users
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let createdAt: String
    let updatedAt: String

    // CodingKeys enum is not strictly necessary here if all property names
    // exactly match the JSON keys (which they seem to, based on Client.Constants.ParseResponseKeys).
    // JSONDecoder will map them automatically.
    // It's only needed if Swift property names differ from JSON keys (e.g., camelCase vs snake_case without a strategy, or different names).
    // Manual init and SLOFromResults are no longer needed with Codable
}

// Wrapper struct for the results array from Parse
struct StudentLocationResults: Codable {
    let results: [StudentLocation]
}

struct AccountVerification: Codable {
    
    let registered: Bool // Changed from Int to Bool as 'registered' usually is boolean
    let key: String      // Changed from Int to String as keys are often strings

    enum CodingKeys: String, CodingKey {
        case registered
        case key
    }
}

struct SessionData: Codable {
    let id: String
    let expiration: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case expiration
    }
}

struct UdacityAccount: Codable {
    let account: AccountVerification
    let session: SessionData
    
    // Udacity API often nests account and session details, this structure reflects that.
    // The exact structure depends on the API response.
    // Assuming Client.Constants.UdacityAccountDetails are keys within these nested objects.
}

// The old LOGFromResults and the global accountVerificationObjects are likely no longer needed.
// If AccountVerification is part of a larger login response, that larger struct should be made Codable.
