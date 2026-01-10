//
//  MapViewModel.swift
//  On The Map
//
//  Created by Antigravity on 01/10/26.
//  Copyright © 2026 Michael Nienaber. All rights reserved.
//

import Foundation
import MapKit

@MainActor
class MapViewModel {
    
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    
    @Published var locations: [StudentLocation] = []
    
    var onLocationsUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Intents
    
    func fetchStudentLocations() {
        Task {
            do {
                // Fetch last 100 locations
                let response: StudentLocationResponse = try await networkManager.fetch(
                    from: OnTheMapAPI.Endpoint.studentLocations(limit: 100, skip: 0, order: "-updatedAt").url,
                    skipUdacitySanitization: true // Parse API is standard JSON
                )
                self.locations = response.results
                onLocationsUpdated?()
            } catch {
                onError?("Failed to download locations: \(error.localizedDescription)")
            }
        }
    }
    
    func createAnnotations() -> [MKPointAnnotation] {
        return locations.map { location in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            return annotation
        }
    }
}
