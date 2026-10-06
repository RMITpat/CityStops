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
                    name: "Sydney Opera House",
                    lat: -33.8568,
                    lon: 151.2153
                ),
                OpenTripLocation(
                    name: "Sydney Harbour Bridge",
                    lat: -33.8523,
                    lon: 151.2108
                ),
                OpenTripLocation(
                    name: "Royal Botanic Garden",
                    lat: -33.8642,
                    lon: 151.2166
                ),
                OpenTripLocation(
                    name: "The Rocks",
                    lat: -33.8599,
                    lon: 151.2090
                ),
                OpenTripLocation(
                    name: "Circular Quay",
                    lat: -33.8610,
                    lon: 151.2107
                ),
        ]
    }
    
    
}
