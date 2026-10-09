//
//  MockMapKitService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import MapKit

enum MockMapKitError: Error {
    case searchError
}

/// Mock MapKit service that uses no MapKit methods. Used in UI Tests
@MainActor
final class MockMapKitService : MapKitService {
    
    let dummyResults: [MapItem]
    let RETURN_EMPTY: Bool
    let RETURN_ERROR: Bool
    
    init(RETURN_EMPTY: Bool, RETURN_ERROR: Bool
) {
        self.RETURN_EMPTY = RETURN_EMPTY
        self.RETURN_ERROR = RETURN_ERROR
        
        self.dummyResults = [
            Self.makeDummyMapItem(
                identifier: "mock-sydney-opera-house",
                name: "Sydney Opera House",
                latitude: -33.8568,
                longitude: 151.2153,
                address: "Bennelong Point, Sydney NSW"
            ),
            Self.makeDummyMapItem(
                identifier: "mock-sydney-harbour-bridge",
                name: "Sydney Harbour Bridge",
                latitude: -33.8523,
                longitude: 151.2108,
                address: "Sydney Harbour Bridge, Sydney NSW"
            ),
            Self.makeDummyMapItem(
                identifier: "mock-royal-botanic-garden",
                name: "Royal Botanic Garden",
                latitude: -33.8642,
                longitude: 151.2166,
                address: "Mrs Macquaries Road, Sydney NSW"
            ),
            Self.makeDummyMapItem(
                identifier: "mock-the-rocks",
                name: "The Rocks",
                latitude: -33.8696,
                longitude: 151.2069,
                address: "The Rocks, Sydney NSW"
            ),
            Self.makeDummyMapItem(
                identifier: "mock-mca-australia",
                name: "Museum of Contemporary Art Australia",
                latitude: -33.8731,
                longitude: 151.2065,
                address: "George Street, Sydney NSW"
            )
        
        ]
    }
    
    func getMKMapItemFromId(identifier: String) async throws -> MapItem? {
        if RETURN_EMPTY {
            return nil
        }
        return dummyResults.first(where: {$0.identifier == identifier} )
    }
    
    
    func searchPlaces(searchRequest: String, currentRegion: MKCoordinateRegion) async throws -> [MapItem] {
        if RETURN_EMPTY {
            return []
        }
        
        if RETURN_ERROR {
            throw MockMapKitError.searchError
        }
        return dummyResults
    }
    
    func createRoute(source: MKMapItem, destination: MKMapItem) async throws -> MKRoute? {
        return nil
    }
    
    static func makeDummyMapItem(
        identifier: String,
        name: String,
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        address: String,
    ) -> MapItem {
       
        let location = CLLocation(
            latitude: latitude,
            longitude: longitude
        )

        let mkmapItem = MKMapItem(location: location, address: MKAddress(fullAddress: address, shortAddress: address))
        mkmapItem.name = name
        
        let mapItem = MapItem(identifier: identifier, mkMapItem: mkmapItem)
        return mapItem
    }
    
}
