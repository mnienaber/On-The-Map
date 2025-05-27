////
////  Client.swift
////  On The Map
////
////  Created by Michael Nienaber on 23/05/2016.
////  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class Client : NSObject {
    
    var session = URLSession.shared
    var config = Config()
    var appDelegate: AppDelegate!
    
    override init() {
        super.init()
    }

    // Updated to be generic for Codable types
    private func convertDataWithCompletionHandler<T: Decodable>(_ data: Data, completionHandlerForConvertData: (T?, Error?) -> Void) {
        do {
            let decoder = JSONDecoder()
            // Date/key decoding strategies can be set here if needed globally,
            // or handled by specific Codable types with custom init(from decoder: Decoder)
            // Example: 
            // if T.self == UdacityDateFormattedType.self { // Hypothetical type needing specific date format
            //    decoder.dateDecodingStrategy = .formatted(someDateFormatter)
            // }
            let parsedResult = try decoder.decode(T.self, from: data)
            completionHandlerForConvertData(parsedResult, nil)
        } catch {
            // More detailed error logging
            var errorDetails = "Could not parse the data as JSON: '\(String(data: data, encoding: .utf8) ?? "Invalid data")'. Error: \(error.localizedDescription)"
            if let decodingError = error as? DecodingError {
                errorDetails += "\nDecoding Error Details: \(decodingError.debugDescription)"
            }
            let userInfo = [NSLocalizedDescriptionKey : errorDetails]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
    }

    func taskForGETMethod<ResponseType: Decodable>(urlString: String, parameters: [String:AnyObject]? = nil, completionHandlerForGET: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        
        // Construct URL with parameters if any
        var components = URLComponents(string: urlString)!
        if let parameters = parameters, !parameters.isEmpty {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
        }
        
        var request = URLRequest(url: components.url!)
        request.addValue(Client.Constants.ParameterValues.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Client.Constants.ParameterValues.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(errorString: String) {
                print(errorString)
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            if let error = error {
                sendError("There was an error with your request: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                sendError("Invalid response received from server.")
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                var errorDetail = "Your request returned a status code other than 2xx! Status: \(httpResponse.statusCode)"
                if let data = data, let errorBody = String(data: data, encoding: .utf8) {
                   errorDetail += "\nResponse body: \(errorBody)"
                }
                sendError(errorDetail)
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        task.resume()
        return task
        
    }
    
    // Placeholder for POST request body and response types
    struct PostRequest<Body: Encodable>: Encodable { let body: Body } // Generic wrapper if needed
    struct PostResponse: Codable { // Example response
        let objectId: String?
        let createdAt: String?
        // Include other fields relevant to a POST response
    }

    func taskForPOSTMethod<RequestType: Encodable, ResponseType: Decodable>(urlString: String, body: RequestType, completionHandlerForPOST: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {

        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        // Common headers for POST requests, assuming Parse API
        request.addValue(Client.Constants.ParameterValues.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Client.Constants.ParameterValues.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            // Handle encoding error immediately
            let userInfo = [NSLocalizedDescriptionKey : "Failed to encode request body: \(error.localizedDescription)"]
            completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            // Return a completed or dummy task
            let dummyTask = URLSession.shared.dataTask(with: URLRequest(url: URL(string: "dummy://")!))
            dummyTask.resume() // Ensure it's started and completed if caller expects a resumed task
            return dummyTask
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(errorString: String) {
                print(errorString)
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            if let error = error {
                sendError("There was an error with your request: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                sendError("Invalid response received from server.")
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                 var errorDetail = "Your request returned a status code other than 2xx! Status: \(httpResponse.statusCode)"
                if let data = data, let errorBody = String(data: data, encoding: .utf8) {
                   errorDetail += "\nResponse body: \(errorBody)"
                }
                sendError(errorDetail)
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // For POST, the response might not always have a body or might be a specific success indicator.
            // If the response is empty and success is indicated by status code, handle that.
            if data.isEmpty && (ResponseType.self == EmptyResponse.self || ResponseType.self == Optional<EmptyResponse>.self) {
                 // Assuming EmptyResponse is a Codable struct for empty success responses.
                 // completionHandlerForPOST(EmptyResponse() as? ResponseType, nil) // This needs careful type handling.
                 // For now, if data is empty, we might assume success with no specific object to parse.
                 // Or, if ResponseType is Optional, we can pass nil.
                 if ResponseType.self == Optional<EmptyResponse>.self {
                    completionHandlerForPOST(nil, nil) // Or some indicator of success with no data
                 } else if data.isEmpty && (200...299).contains(httpResponse.statusCode) {
                    // If data is empty but status is success, and ResponseType isn't optional Empty,
                    // it's tricky. For now, let's assume a non-empty response is expected by default.
                    // This part needs to be robust based on API contract.
                    // Potentially, we can try to decode an EmptyResponse if that's a valid scenario.
                    // This placeholder assumes data is expected for ResponseType.
                    sendError("Received empty data for a response type that expects content.")
                 }
                 return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        task.resume()
        return task
    }

    // Udacity Login Request Body
    struct UdacityLoginRequestBody: Codable {
        let udacity: UdacityCredentials
    }
    struct UdacityCredentials: Codable {
        let username: String
        let password: String
    }
    
    func taskForLOGINMethod(credentials: UdacityLoginRequestBody, completionHandlerForLOGIN: @escaping (UdacityAccount?, Error?) -> Void) -> URLSessionDataTask {
        let urlString = "https://www.udacity.com/api/session"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(credentials)
        } catch {
            // Handle encoding error
            let userInfo = [NSLocalizedDescriptionKey : "Failed to encode login request body: \(error.localizedDescription)"]
            completionHandlerForLOGIN(nil, NSError(domain: "taskForLOGINMethod", code: 1, userInfo: userInfo))
            let dummyTask = URLSession.shared.dataTask(with: URLRequest(url: URL(string: "dummy://")!))
            dummyTask.resume()
            return dummyTask
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(errorString: String) {
                print(errorString)
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForLOGIN(nil, NSError(domain: "taskForLOGINMethod", code: 1, userInfo: userInfo))
            }
            
            if let error = error {
                sendError("Login request error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                sendError("Invalid response received from server.")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                var errorDetail = "Your request returned a status code other than 2xx! Status: \(httpResponse.statusCode)"
                if let data = data, let errorBody = String(data: data, encoding: .utf8) {
                    errorDetail += "\nResponse body: \(errorBody)"
                }
                sendError(errorDetail)
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Udacity API requires stripping first 5 characters
            guard data.count > 5 else {
                sendError("Data is too short to strip prefix for Udacity API.")
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range)
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForLOGIN)
        }
        task.resume()
        return task
    }
    
    // UserInfo response structure (as defined in StudentLocation.swift or here if more specific)
    // Assuming UserInfo struct is defined elsewhere (e.g. StudentLocation.swift) or as a nested struct if specific to Client.
    // For this example, let's assume a UserDetail struct for clarity:
    struct UserDetail: Codable {
        let firstName: String?
        let lastName: String?
        // Add other fields like nickname, etc.
        enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
        }
    }
    // And a wrapper for the "user" key
    struct UserInfoResponse: Codable {
        let user: UserDetail
    }

    func taskForUSERINFOMethod(accountKey: String, completionHandlerForUSERINFO: @escaping (UserInfoResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/" + accountKey)!)
        // No specific headers, assuming GET.
        
        let task = session.dataTask(with: request) { data, response, error in
            func sendError(errorString: String) {
                print(errorString)
                 performUIUpdatesOnMain { /* UI update from client is unusual */ print("Error: \(errorString)") }
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForUSERINFO(nil, NSError(domain: "taskForUSERINFOMethod", code: 1, userInfo: userInfo))
            }
            
            if let error = error {
                sendError("There was an error with your request: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                sendError("Invalid response received from server.")
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                var errorDetail = "Your request returned a status code other than 2xx! Status: \(httpResponse.statusCode)"
                if let data = data, let errorBody = String(data: data, encoding: .utf8) {
                   errorDetail += "\nResponse body: \(errorBody)"
                }
                sendError(errorDetail)
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            // Udacity API requires stripping first 5 characters
            guard data.count > 5 else {
                sendError("Data is too short to strip prefix for Udacity API.")
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range)

            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForUSERINFO)
        }
        task.resume()
        return task
    }

    // Placeholder for DeleteSession response structure
    struct DeleteSessionResponse: Codable {
        let session: SessionData // Assuming SessionData is defined as in StudentLocation.swift
    }

    func taskForDeleteSession(completionHandlerForDELETE: @escaping (DeleteSessionResponse?, Error?) -> Void) -> URLSessionDataTask {

        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        // Ensure cookies is not nil before iterating
        for cookie in sharedCookieStorage.cookies ?? [] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            func sendError(errorString: String) {
                print(errorString)
                 performUIUpdatesOnMain { /* UI update from client is unusual */ print("Error: \(errorString)") }
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForDELETE(nil, NSError(domain: "taskForDeleteSession", code: 1, userInfo: userInfo))
            }
            
            if let error = error {
                sendError("There was an error with your request: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                sendError("Invalid response received from server.")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                 var errorDetail = "Your request returned a status code other than 2xx! Status: \(httpResponse.statusCode)"
                if let data = data, let errorBody = String(data: data, encoding: .utf8) {
                   errorDetail += "\nResponse body: \(errorBody)"
                }
                sendError(errorDetail)
                return
            }

            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            // Udacity API requires stripping first 5 characters
             guard data.count > 5 else {
                sendError("Data is too short to strip prefix for Udacity API.")
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range)

            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDELETE)
        }
        task.resume()
        return task
    }
    
    // private func convertDataWithCompletionHandler is now at the top and generic.
    
    class func escapedParameters(parameters: [String : Any]) -> String { // Changed to [String: Any]
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            let stringValue = "\(value)"
            
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }

    // Define EmptyResponse for POST/PUT/DELETE calls that might return no body on success
    struct EmptyResponse: Codable {}

    public class Reachability {
        class func isConnectedToNetwork() -> Bool {

            print("running the internet check")

            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)

            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }

            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
                return false
            }

            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)

            return isReachable && !needsConnection
            
        }
    }

    class func sharedInstance() -> Client {
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }
    
}