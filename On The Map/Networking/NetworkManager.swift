//
//  NetworkManager.swift
//  On The Map
//
//  Created by Antigravity on 01/10/26.
//  Copyright © 2026 Michael Nienaber. All rights reserved.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidStatusCode(Int)
    case decodingError(Error)
    case authFailed
}

actor NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Generic Fetch
    
    func fetch<T: Decodable>(from url: URL?, headers: [String: String] = [:], skipUdacitySanitization: Bool = false) async throws -> T {
        guard let url = url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        // Add Parse Headers if needed based on URL logic, or passed in
        if url.absoluteString.contains("parse.udacity.com") {
             request.addValue(OnTheMapAPI.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
             request.addValue(OnTheMapAPI.parseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
             throw APIError.invalidStatusCode((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        let validData: Data
        if !skipUdacitySanitization {
            // Udacity API returns JSON prefixed with 5 chars ")]}'\n" (sometimes)
            // We check the prefix or length
            validData = sanitize(data)
        } else {
            validData = data
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: validData)
        } catch {
            print("Decoding Error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Generic Post
    
    func post<T: Decodable>(to url: URL?, body: Encodable, headers: [String: String] = [:], skipUdacitySanitization: Bool = false) async throws -> T {
        guard let url = url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        if url.absoluteString.contains("parse.udacity.com") {
             request.addValue(OnTheMapAPI.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
             request.addValue(OnTheMapAPI.parseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
             throw APIError.requestFailed(NSError(domain: "Network", code: 0))
        }
        
        if httpResponse.statusCode == 403 {
            throw APIError.authFailed
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
             throw APIError.invalidStatusCode(httpResponse.statusCode)
        }
        
        let validData: Data
        if !skipUdacitySanitization {
            validData = sanitize(data)
        } else {
            validData = data
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: validData)
        } catch {
            print("Decoding Error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Helpers
    
    /// Udacity API returns a security string prefix that must be skipped.
    private func sanitize(_ data: Data) -> Data {
        let range = 5..<data.count
        // Heuristic: Check if data is longer than 5 and likely has the garbage
        // For strictness, often Udacity API was specifically only on 'session' endpoints or similar
        // But the legacy code used it generally. We safely try to preserve it if it looks like standard JSON,
        // but here we emulate the legacy behavior: "subdataWithRange(NSMakeRange(5, data.length - 5))"
        // Only apply if it looks malformed? Or always apply for Udacity domains?
        // Legacy code applied it to LOGIN and USERINFO.
        // It did NOT apply it to StudentLocation (Parse).
        // The calling function should decide via `skipUdacitySanitization` flag.
        if data.count > 5 {
             return data.subdata(in: range)
        }
        return data
    }
}
