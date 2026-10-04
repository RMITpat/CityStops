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
/// ViewModel used for keeping track of the user's current location,
/// and managing a trip's route based on the stops chosen.
///
@Observable
final class LocationViewModel: NSObject, CLLocationManagerDelegate {
    
    /// The region of the user.
    /// When currentRegion updates:
    /// - update currentLocation so that the map in CreateTripView updates
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
    
    private var cachedRoutes: [String : [MKRoute]] = [:]
    
    
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
        
        if let cachedRoute = cachedRoutes[tripID] {
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
            cachedRoutes[tripID] = routes
        }
        return routes
        
    }
    
    /// Create an MKRoute between 2
    func createRoute(source: MKMapItem, destination: MKMapItem) async throws -> MKRoute? {
        let directionsRequest: MKDirections.Request = MKDirections.Request()
        directionsRequest.source = source
        directionsRequest.destination = destination
        directionsRequest.transportType = MKDirectionsTransportType.walking
        
        let directions = MKDirections(request: directionsRequest)
        let response = try await directions.calculate()
        
        if let route = response.routes.first {
            return route
        }
        return nil
    }
    ///
    /// 0 1 2 3 4 count = 5
    /// remove 4
    /// 0 1 2 3 count = 4
    func reroute(route: [MKRoute], placeIndex: Int, updatedSelectedPlaces: [MKMapItem] ) async throws ->  [MKRoute] {
        
        var route = route
        // Protect against edge cases even though they shouldn't occur
        if placeIndex > updatedSelectedPlaces.count || placeIndex < 0 {
            return route
        }
        
        // If the place removed was the last place in the list (with index of the updated selectedPlaces count since it's one smaller),
        if placeIndex == updatedSelectedPlaces.count {
            // Drop the route connecting to it
            return route.dropLast()
        }
        
        // If the place removed was the first place in the list,
        if placeIndex == 0 {
            // Drop the route connecting it to the second place
            return Array(route.suffix(from: 0))
        }
        
        // If the place removed was somewhere inside the list,
        else {
            // Mark the place before it as the source
            let source = updatedSelectedPlaces[placeIndex - 1]
            
            // And the place after it that is now in its index as the destination
            let destination = updatedSelectedPlaces[placeIndex]
            
            // And create a new route
            if let replacementRoute = try await createRoute(source: source, destination: destination) {
                // Remove the route from the deleted place to the place after it
                route.remove(at: placeIndex)
                
                // Add in the replacement route that connects the place before the removed place to the place after
                route.insert(replacementRoute, at: placeIndex - 1)
                
                return route
            }
            
        }
        return route
        
        
    }
}
