//
//  OnTheMapAPI.swift
//  On The Map
//
//  Created by Antigravity on 01/10/26.
//  Copyright © 2026 Michael Nienaber. All rights reserved.
//

import Foundation

struct OnTheMapAPI {
    
    // MARK: - Constants
    static let udacityBaseURL = "https://www.udacity.com/api"
    static let parseBaseURL = "https://parse.udacity.com/parse/classes" // Assuming legacy URL or similar
    
    // Headers needed for Parse (if still applicable, typically ApplicationID/RESTKey)
    static let parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let parseAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    enum Endpoint {
        case session // POST (Login), DELETE (Logout)
        case studentLocations(limit: Int, skip: Int, order: String)
        case postStudentLocation
        
        var url: URL? {
            switch self {
            case .session:
                return URL(string: "\(OnTheMapAPI.udacityBaseURL)/session")
            case .studentLocations(let limit, let skip, let order):
                var components = URLComponents(string: "\(OnTheMapAPI.parseBaseURL)/StudentLocation")
                components?.queryItems = [
                    URLQueryItem(name: "limit", value: "\(limit)"),
                    URLQueryItem(name: "skip", value: "\(skip)"),
                    URLQueryItem(name: "order", value: order)
                ]
                return components?.url
            case .postStudentLocation:
                return URL(string: "\(OnTheMapAPI.parseBaseURL)/StudentLocation")
            }
        }
    }
}

// MARK: - Models

// -- Udacity Session --
struct UdacitySessionResponse: Codable {
    let account: Account
    let session: Session
}

struct Account: Codable {
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}

// -- Student Location --
struct StudentLocationResponse: Codable {
    let results: [StudentLocation]
}

struct StudentLocation: Codable {
    let objectId: String
    let uniqueKey: String?
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let createdAt: String
    let updatedAt: String
}

struct StudentLocationRequest: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
