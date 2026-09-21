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
    
    // When currentRegion updates:
    // - update currentLocation so that the map in CreateTripView updates
    // - update request so that search results are relevant
    private var currentRegion: MKCoordinateRegion {
        didSet {
            currentLocation = .region(currentRegion)
            request.region = currentRegion
        }
    }
    
    // The request used when making location search requests
    private let request: MKLocalSearch.Request
    
    // The place search request inputted by the user
    var searchRequest: String = ""
    
    // The results of a place search
    var searchResults: [MKMapItem] = []
    
    // The current region, represented as MapCameraPosition so it can be displayed by Map
    var currentLocation: MapCameraPosition
    
    // Places selected by the user to be a part of the trip
    var selectedPlaces: [MKMapItem] = []

    // Routes between selectionPlaces
    var routes: [MKRoute] = []
    
    // The current route finding task created by createRoute. Stored here so that it can be cancelled if a new request is made
    var currentRouteTask: Task<Void, Never>?
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
        
        // Default the search results to Sydney
        request = MKLocalSearch.Request()
        request.region = sydneyRegion
        
        super.init()
    }
    
    // Conduct a search of places the currently set request
    func searchPlaces() {
        request.naturalLanguageQuery = searchRequest
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }

            self.searchResults = response.mapItems
        }
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
    
    // Creates a route between all the locations currently stored in selectedPlaces, in the order they were added. Begins by checking if there was a previous, ongoing route request occurring and cancelling
    // it if there was and replacing it with the new one.
    func createRoute() {
        currentRouteTask?.cancel()
        routes.removeAll()
        
        let directionsRequest: MKDirections.Request = MKDirections.Request()
        currentRouteTask = Task {
            for i in 1...selectedPlaces.endIndex - 1 {
                directionsRequest.destination = selectedPlaces[i]
                directionsRequest.source = selectedPlaces[i-1]
                directionsRequest.transportType = MKDirectionsTransportType.walking
                
                let directions = MKDirections(request: directionsRequest)
                let response = try? await directions.calculate()
                if let route = response?.routes.first {
                    routes.append(route)
                }
            }
                  
        }
        
        
    }
}
