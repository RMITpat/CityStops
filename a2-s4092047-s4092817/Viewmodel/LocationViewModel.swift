//
//  LocationViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 19/9/2026.
//
import Foundation
import CoreLocation
import Observation
import MapKit
import _MapKit_SwiftUI
///
/// ViewModel used for keeping track of the user's current location
///
@Observable
final class LocationViewModel: NSObject, CLLocationManagerDelegate {
    
    private var currentRegion: MKCoordinateRegion {
        didSet {
            currentLocation = .region(currentRegion)
            print(currentRegion.center.latitude)
            print(currentRegion.center.longitude)
        }
    }

    var currentLocation: MapCameraPosition

    override init() {
        let sydneyRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: -33.8688,
                longitude: 151.2093
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.1,
                longitudeDelta: 0.1
            )
        )

        currentRegion = sydneyRegion
        currentLocation = .region(sydneyRegion)
        
        super.init()
    }

    var manager = CLLocationManager()
    
    // Sets the current location based off authorisation
    func checkLocationAuthorization() {
        
        // Sets delegate so that locationManagerDidChangeAuthorization and locationManager(didUpdateLocations) functions are called automatically
        manager.delegate = self
                
        switch manager.authorizationStatus {
            // If the user hasn't determined authorisation status, prompt it
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            
            // If the user has given authorisation, request location
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()

            default:
                break
            
        }
    }
    
    // Trigged every time authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    // Called when manager.requestLocation() succeeds
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentRegion.center = locations.first?.coordinate ?? currentRegion.center
        
    }
    
    // Called when manager.requestLocation() fails
    func locationManager(
            _ manager: CLLocationManager,
            didFailWithError error: Error
        ) {
            print("Failed to get location:", error.localizedDescription)
        }
}
