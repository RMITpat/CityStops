//
//  MockOpenTripMapService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import MapKit

/// Mock Open Trip Map Service that doesn't make any rest api calls. Used in UI Tests
@MainActor
final class MockOpenTripMapService : OpenTripMapService {
    func fetchNearbyPointsByCategory(location: CLLocationCoordinate2D, radius: Int, filter: String, returnLimit: Int) async throws -> [OpenTripLocation] {
        return [
            OpenTripLocation(
                    name: "Darling Harbour",
                    lat: -33.8731,
                    lon: 151.1982
                ),
                OpenTripLocation(
                    name: "Queen Victoria Building",
                    lat: -33.8718,
                    lon: 151.2067
                ),
                OpenTripLocation(
                    name: "St Mary's Cathedral",
                    lat: -33.8711,
                    lon: 151.2132
                ),
                OpenTripLocation(
                    name: "Art Gallery of New South Wales",
                    lat: -33.8688,
                    lon: 151.2173
                ),
                OpenTripLocation(
                    name: "Australian Museum",
                    lat: -33. filosofía,
                    lon: 151.2167
                ),
        ]
    }
    
    
}
