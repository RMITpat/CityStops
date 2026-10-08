//
//  MapKitService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import MapKit

@MainActor
protocol MapKitService {

    func searchPlaces(searchRequest: String, currentRegion: MKCoordinateRegion) async throws -> [MapItem]
    func createRoute(source: MKMapItem, destination: MKMapItem) async throws -> MKRoute?
    
    func getMKMapItemFromId(identifier: MKMapItem.Identifier) async throws -> MapItem?
}

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
    func getMKMapItemFromId(identifier: MKMapItem.Identifier) async throws -> MapItem? {
        let request = MKMapItemRequest(mapItemIdentifier: identifier)
        
        let mkItem = try await request.mapItem
        return MapItem(identifier: mkItem.identifier?.rawValue ?? "", mkMapItem: mkItem)
    }
    
}
