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
    
    func getStudentLocations(completionHandlerForStudentLocations: @escaping (_ result: [StudentLocation]?, _ error: Error?) -> Void) {

        let parameters = [
            Client.Constants.ParameterValues.ParseAPIKey: Client.Constants.ParameterValues.ParseAPIKey,
            Client.Constants.ParameterValues.RestAPIKey: Client.Constants.ParameterValues.RestAPIKey,
        ]
        
        let url = Client.Constants.Scheme.Method + Client.Constants.Scheme.LimitAndOrder
        
        // Parameters for GET student locations are typically part of the URL query string.
        // The `taskForGETMethod` in Client.swift already handles adding parameters to the URL if provided.
        // For this specific call, the parameters map seems to be for headers or specific API keys,
        // which are handled inside taskForGETMethod.
        // However, the `parameters` argument in `taskForGETMethod` is for URL query parameters.
        // The Parse API keys are typically sent as HTTP headers, which `taskForGETMethod` does.
        // So, parameters here should be nil or an empty dictionary if they are not URL query params.
        // For this API, limit and order are part of the URL path, not parameters dictionary.
        
        taskForGETMethod(urlString: url, parameters: nil) { (response: StudentLocationResults?, error: Error?) in
            
            if let error = error {
                completionHandlerForStudentLocations(nil, error)
            } else if let response = response {
                // StudentModel is updated here. This is a side effect.
                // Consider if StudentModel should be updated by the caller instead.
                StudentModel.sharedInstance().studentLocation = response.results
                completionHandlerForStudentLocations(response.results, nil)
            } else {
                // Should not happen if error is nil and response is nil, but as a fallback:
                completionHandlerForStudentLocations(nil, NSError(domain: "getStudentLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error: No data and no error."]))
            }
        }
    }
    
    // For postToMap, we need a Codable request body if we are sending structured data.
    // The current `jsonBody: String` suggests raw JSON. If this is intended, taskForPOSTMethod needs
    // a variant that accepts raw String/Data.
    // Assuming for now that we want to send structured data for posting a location.
    struct StudentLocationPost: Encodable {
        let uniqueKey: String
        let firstName: String
        let lastName: String
        let mapString: String
        let mediaURL: String
        let latitude: Double
        let longitude: Double
    }
    
    // The completion handler for postToMap currently returns Int?.
    // This needs to map to a field in the PostResponse (defined in Client.swift) or a new specific Codable struct.
    // For now, let's assume PostResponse { let objectId: String?, let createdAt: String? } is sufficient.
    func postToMap(locationData: StudentLocationPost, completionHandlerForPOST: @escaping (Client.PostResponse?, Error?) -> Void) {
        
        let urlString = Client.Constants.Scheme.Method // URL for posting student location
        
        taskForPOSTMethod(urlString: urlString, body: locationData, completionHandlerForPOST: completionHandlerForPOST)
    }
    
    func loginToApp(username: String, password: String, completionHandlerForLOGIN: @escaping (UdacityAccount?, Error?) -> Void) {
        
        let credentials = Client.UdacityCredentials(username: username, password: password)
        let loginBody = Client.UdacityLoginRequestBody(udacity: credentials)
        
        taskForLOGINMethod(credentials: loginBody) { (udacityAccount, error) in
            if let error = error {
                completionHandlerForLOGIN(nil, error)
            } else if let udacityAccount = udacityAccount {
                // Successfully decoded UdacityAccount
                // Update AppDelegate with account details
                self.appDelegate.accountKey = udacityAccount.account.key as AnyObject // appDelegate.accountKey is AnyObject?
                self.appDelegate.sessionID = udacityAccount.session.id
                // Consider if appDelegate.accountRegistered needs to be set from udacityAccount.account.registered
                
                completionHandlerForLOGIN(udacityAccount, nil)
            } else {
                completionHandlerForLOGIN(nil, NSError(domain: "loginToApp", code: 0, userInfo: [NSLocalizedDescriptionKey: "Login failed: No data or error."]))
            }
        }
    }
    
    func getUserCompleteInfo(accountKey: String, completionHandlerForUSERINFO: @escaping (Client.UserInfoResponse?, Error?) -> Void) {
        // Ensure appDelegate is initialized. It's an implicitly unwrapped optional.
        // It should be initialized when the Client is, or passed in.
        // For now, assuming it's available as before.
        appDelegate = UIApplication.shared.delegate as! AppDelegate 

        taskForUSERINFOMethod(accountKey: accountKey) { (userInfoResponse, error) in
            if let error = error {
                completionHandlerForUSERINFO(nil, error)
            } else if let userInfoResponse = userInfoResponse {
                // Update AppDelegate with user's first and last name
                self.appDelegate.firstName = userInfoResponse.user.firstName
                self.appDelegate.lastName = userInfoResponse.user.lastName
                completionHandlerForUSERINFO(userInfoResponse, nil)
            } else {
                completionHandlerForUSERINFO(nil, NSError(domain: "getUserCompleteInfo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get user info."]))
            }
        }
    }

    func deleteSession(completionHandlerForDELETE: @escaping (Client.DeleteSessionResponse?, Error?) -> Void) {

        taskForDeleteSession() { (deleteResponse, error) in
            if let error = error {
                completionHandlerForDELETE(nil, error)
            } else {
                // Handle successful deletion, maybe clear some session data in AppDelegate
                // The actual response might be minimal, just confirming deletion.
                // The DeleteSessionResponse struct in Client.swift should model what's expected.
                completionHandlerForDELETE(deleteResponse, nil)
                }
            }
        }
    }

    func verifyUrl(_ urlString: String?) -> Bool {

        if let urlString = urlString {

            if URL(string: urlString) != nil {

                return true
            }
        }
        return false
    }
}

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

extension UIViewController {
    @objc func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardViewController))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboardViewController() {
        view.endEditing(true)
    }
}


