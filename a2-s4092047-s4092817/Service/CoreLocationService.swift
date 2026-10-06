//
//  CoreLocationService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import CoreLocation

@MainActor
protocol CoreLocationService {
    var onLocationUpdate: ((CLLocation) -> Void)? { get set }
    
    func checkLocationAuthorization()
}

@MainActor
final class CoreLocationServiceImpl : NSObject, CoreLocationService, CLLocationManagerDelegate {
    var manager = CLLocationManager()
    var onLocationUpdate: ((CLLocation) -> Void)?
    
    init(onLocationUpdate: ((CLLocation) -> Void)? = nil) {
        self.onLocationUpdate = onLocationUpdate
    }
    
    /// Sets the current location based off authorisation
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
    
    /// Triggered every time authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    /// Called when manager.requestLocation() succeeds
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            onLocationUpdate?(location)
        }
     
        
    }
    
    /// Called when manager.requestLocation() fails
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Failed to get location:", error.localizedDescription)
    }
    
}
