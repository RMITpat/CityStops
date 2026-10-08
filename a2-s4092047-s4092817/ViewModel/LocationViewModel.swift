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
@MainActor
@Observable
final class LocationViewModel {
    
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
    
    var coreLocationService: CoreLocationService
    
    var mapKitService: MapKitService
    
    /// The logged in user
    private let user: AppUser
    
    private var cachedTripRoutes: [String : [MKRoute]] = [:]
    
    
    // Used in mocks to inject mock service
    init(user: AppUser, coreLocationService: CoreLocationService, mapKitService: MapKitService) {
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
        
        self.mapKitService = mapKitService

        self.coreLocationService = coreLocationService
        self.coreLocationService.onLocationUpdate = { [weak self] location in
            self?.currentRegion.center = location.coordinate
        }
    }
    
    // Used in real app to set CoreLocationServiceImpl
    convenience init(user: AppUser) {
        self.init(
            user: user,
            coreLocationService: CoreLocationServiceImpl(),
            mapKitService: MapKitServiceImpl()
        )
    }
    
    
    /// Conduct a search of places the currently set request
    func searchPlaces(searchRequest: String) async throws -> [MapItem] {
        return try await mapKitService.searchPlaces(searchRequest: searchRequest, currentRegion: currentRegion)
    }
    
    
    
    
    /// Sets the current location based off authorisation
    func checkLocationAuthorization() {
        coreLocationService.checkLocationAuthorization()
    }
    
  
    
    /// Creates a route between all the locations currently stored in selectedPlaces, in the order they were added.
    /// Begins by checking if there was a previous, ongoing route request occurring and
    /// cancelling it if there was and replacing it with the new one.
    func createTripRoutes(selectedPlaces: [MapItem], tripID: String = "") async throws -> [MKRoute] {
        var routes: [MKRoute] = []
        
        if let cachedRoute = cachedTripRoutes[tripID] {
            return cachedRoute
        }
        for (source, dest) in zip(selectedPlaces, selectedPlaces.dropFirst()) {
            // If the user has closed the view cancel this task. Will still finish calculating the last directions however.
            if Task.isCancelled {
                break
            }
            
            let route = try await createRoute(source: source.mkMapItem, destination: dest.mkMapItem)
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
        return try await mapKitService.createRoute(source: source, destination: destination)
    }
    
    
}
