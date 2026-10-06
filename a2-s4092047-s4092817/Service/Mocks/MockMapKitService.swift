//
//  MockMapKitService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import MapKit

/// Mock MapKit service that uses no MapKit methods. Used in UI Tests
@MainActor
final class MockMapKitService : MapKitService {
    
    func searchPlaces(searchRequest: String, currentRegion: MKCoordinateRegion) async throws -> [MKMapItem] {
        return [makeDummyMapItem(
            latitude: -33.8568,
            longitude: 151.2153,
            address: "Sydney Opera House, Bennelong Point, Sydney NSW"
        ),
        makeDummyMapItem(
            latitude: -33.8523,
            longitude: 151.2108,
            address: "Sydney Harbour Bridge, Sydney NSW"
        ),
        makeDummyMapItem(
            latitude: -33.8642,
            longitude: 151.2166,
            address: "Royal Botanic Garden, Mrs Macquaries Road, Sydney NSW"
        ),
        makeDummyMapItem(
            latitude: -33.8696,
            longitude: 151.2069,
            address: "The Rocks, Sydney NSW"
        ),
        makeDummyMapItem(
            latitude: -33.8731,
            longitude: 151.2065,
            address: "Museum of Contemporary Art Australia, George Street, Sydney NSW"
        )]
    }
    
    func createRoute(source: MKMapItem, destination: MKMapItem) async throws -> MKRoute? {
        return nil
    }
    
    private func makeDummyMapItem(
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        address: String
    ) -> MKMapItem {
       
        let location = CLLocation(
            latitude: latitude,
            longitude: longitude
        )

        let mapItem = MKMapItem(location: location, address: MKAddress(fullAddress: address, shortAddress: address))

        return mapItem
    }
    
}
