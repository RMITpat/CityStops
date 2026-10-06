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

struct CachedRoute : Hashable {
    let source: String
    let destination: String
}
///
/// ViewModel used for keeping track of the user's current location,
/// and managing a trip's route based on the stops chosen.
///
@Observable
final class LocationViewModel: NSObject, CLLocationManagerDelegate {
    
    /// The region of the user.
    /// When currentRegion updates:
    /// - update request so that search results are relevant
    var currentRegion: MKCoordinateRegion {
        didSet {
            currentLocation = .region(currentRegion)
        }
    }
    
    /// The current region, represented as MapCameraPosition so it can be displayed by Map
    var currentLocation: MapCameraPosition
    
    /// The logged in user
    private let user: AppUser
    
    private var cachedTripRoutes: [String : [MKRoute]] = [:]
    
    private var cachedRoutes: [CachedRoute : MKRoute] = [:]
    
    init(user: AppUser) {
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
        
        self.user = user
        
        super.init()
    }
    
    /// Conduct a search of places the currently set request
    func searchPlaces(searchRequest: String) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchRequest
        request.region = currentRegion
        
        let response = try await MKLocalSearch(request: request).start()
        
        return response.mapItems.filter {
            $0.identifier != nil
        }
    }
    
    var manager = CLLocationManager()
    
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
        currentRegion.center = locations.first?.coordinate ?? currentRegion.center
        
    }
    
    /// Called when manager.requestLocation() fails
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Failed to get location:", error.localizedDescription)
    }
    
    /// Creates a route between all the locations currently stored in selectedPlaces, in the order they were added.
    /// Begins by checking if there was a previous, ongoing route request occurring and
    /// cancelling it if there was and replacing it with the new one.
    func createTripRoutes(selectedPlaces: [MKMapItem], tripID: String = "") async throws -> [MKRoute] {
        var routes: [MKRoute] = []
        
        if let cachedRoute = cachedTripRoutes[tripID] {
            return cachedRoute
        }
        for (source, dest) in zip(selectedPlaces, selectedPlaces.dropFirst()) {
            // If the user has closed the view cancel this task. Will still finish calculating the last directions however.
            if Task.isCancelled {
                break
            }
            
            let route = try await createRoute(source: source, destination: dest)
            if let route {
                routes.append(route)
            }
        }
        
        // Cache the route for this trip so we can get it next time
        if (!tripID.isEmpty) {
            cachedTripRoutes[tripID] = routes
        }
        return routes
        
    }
    
    /// Create an MKRoute between 2 MKMapItems
    func createRoute(source: MKMapItem, destination: MKMapItem) async throws -> MKRoute? {
        var newRoute: CachedRoute?
        
        // If both locations have an id
        if let sourceID = source.identifier?.rawValue, let destID = destination.identifier?.rawValue {
            
            // Create a new cached route key
            newRoute = CachedRoute(source: sourceID, destination: destID)
            
            // if the route for that key has been calculated previously, return it
            if let newRoute, let cachedRoute = cachedRoutes[newRoute] {
                return cachedRoute
            }
        }
        
        let directionsRequest: MKDirections.Request = MKDirections.Request()
        directionsRequest.source = source
        directionsRequest.destination = destination
        directionsRequest.transportType = MKDirectionsTransportType.walking
        
        let directions = MKDirections(request: directionsRequest)
        let response = try await directions.calculate()
        
        if let route = response.routes.first {
            
            // If newRoute was previously created, meaning the id's for source and dest exists, store it against the calculated route
            if let newRoute {
                cachedRoutes[newRoute] = route
            }
            return route
        }
        return nil
    }
    
    
}
