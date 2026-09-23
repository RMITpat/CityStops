//
//  Trip.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 22/9/2026.
//

import Foundation
import FirebaseFirestore
import MapKit

/// A created trip
/// - id: String identifier for the trip, created by Firebase
/// - name: String name of the trip
/// - places: [GeoPoint] the list of stops in the trip, stored as Firebase's GeoPoint which represents a lat and long pair
struct Trip: Identifiable {
    
    var id: String
    let ownerId: String
    let name: String
    let places: [MKMapItem]
    let createdAt: Date
    let preferences: [String]
    
    init(id: String = "", ownerId: String, name: String, places: [MKMapItem], createdAt: Date = Date(), preferences: [String]) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.places = places
        self.createdAt = createdAt
        self.preferences = preferences

    }
    
    mutating func setId(id: String) {
        self.id = id
    }
    
    var asDictionary: [String: Any] {
        let geoPointPlaces: [GeoPoint] = places.map { (place: MKMapItem) -> GeoPoint in
            return GeoPoint(
                latitude: place.location.coordinate.latitude,
                longitude: place.location.coordinate.longitude)
            }
        
        return [
                "id": id,
                "ownerId": ownerId,
                "name": name,
                "places": geoPointPlaces,
                "createdAt" : createdAt,
                "preferences" : preferences
            ]
    }
}
