//
//  MapKitService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import MapKit


@MainActor
/// Defines services for searching places, calculating routes, and retrieving map items.
///
/// See ``MapKitServiceImpl`` for real implementation in app.
protocol MapKitService {

    /// Conduct a search of places using a search request string.
    /// - Parameters:
    ///   - searchRequest: The natural language query used to search for places.
    ///   - currentRegion: The geographic region where search is performed.
    /// - Returns: Array of ``MapItem`` matching the search query.
    /// - Throws: An error if the place search fails.
    func searchPlaces(searchRequest: String, currentRegion: MKCoordinateRegion) async throws -> [MapItem]
    
    /// Create an MKRoute between 2 MapItems
    /// - Parameters:
    ///   - source: The starting location of route.
    ///   - destination: The ending location of route.
    /// - Returns: The calculated MKRoute
    /// - Throws: An error if route calculation fails.
    func createRoute(source: MKMapItem, destination: MKMapItem) async throws -> MKRoute?
    
    /// Request ``MapItem`` from identifier
    /// - Parameter identifier: The identifier of the map item.
    /// - Returns: The corresponding ``MapItem``, or `nil` if the identifier is invalid.
    /// - Throws: An error if retrieving the map item fails.
    func getMKMapItemFromId(identifier: String) async throws -> MapItem?
}

/// Real implementation of ``MapKitService`` used in app.
@MainActor
final class MapKitServiceImpl : MapKitService {
    private var cachedRoutes: [CachedRoute : MKRoute] = [:]

    /// Conduct a search of places using a search request string
    func searchPlaces(searchRequest: String, currentRegion: MKCoordinateRegion) async throws -> [MapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchRequest
        request.region = currentRegion
        
        let response = try await MKLocalSearch(request: request).start()
        
        return response.mapItems.compactMap { item in
            guard let identifier = item.identifier else {
                return nil
            }

            return MapItem(
                identifier: identifier.rawValue,
                mkMapItem: item
            )
        }
    }
    
    /// Create an MKRoute between 2 MapItems
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
    
    /// Request MKMapItem from identifier
    func getMKMapItemFromId(identifier: String) async throws -> MapItem? {
        if let mkIdentifier = MKMapItem.Identifier(rawValue: identifier) {
            let request = MKMapItemRequest(mapItemIdentifier: mkIdentifier)
            
            let mkItem = try await request.mapItem
            return MapItem(identifier: identifier, mkMapItem: mkItem)
        }
        return nil
    }
    
}
