//
//  MapViewController.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Refactored by Antigravity on 01/10/26.
//  Copyright © 2026 Michael Nienaber. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    private let viewModel = MapViewModel()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupBindings()
        
        viewModel.fetchStudentLocations()
        
        // Location Mgr Setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    private func setupBindings() {
        viewModel.onLocationsUpdated = { [weak self] in
            self?.refreshMap()
        }
        viewModel.onError = { [weak self] errorMsg in
            self?.showAlert(title: "Error", message: errorMsg)
        }
    }
    
    private func refreshMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(viewModel.createAnnotations())
    }
    
    // MARK: - Actions
    
    @IBAction func refreshTapped(_ sender: Any) {
        viewModel.fetchStudentLocations()
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        // Logout logic (calling NetworkManager session delete)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let subtitle = view.annotation?.subtitle, let urlString = subtitle, let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // MARK: - Helper
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
