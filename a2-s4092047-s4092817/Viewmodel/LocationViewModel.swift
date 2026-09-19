//
//  LocationViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 19/9/2026.
//
import Foundation
import CoreLocation

///
/// ViewModel used for keeping track of the user's current location
///
@Observable
final class LocationViewModel: NSObject, CLLocationManagerDelegate {
    
    // Default to Sydney
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -33, longitude: 151)
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
        currentLocation = locations.first?.coordinate ?? currentLocation
        print(currentLocation.latitude)
        print(currentLocation.longitude)
    }
    
    // Called when manager.requestLocation() fails
    func locationManager(
            _ manager: CLLocationManager,
            didFailWithError error: Error
        ) {
            print("Failed to get location:", error.localizedDescription)
        }
}
