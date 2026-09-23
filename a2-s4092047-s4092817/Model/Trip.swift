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
struct Trip: Identifiable, Codable {
    
    let id: String
    let ownerId: String
    let name: String
    let places: [GeoPoint]
    let createdAt: Date
    
    init(id: String, ownerId: String, name: String, places: [MKMapItem], createdAt: Date = Date()) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.places = places.map { (place: MKMapItem) -> GeoPoint in
            return GeoPoint(
                latitude: place.location.coordinate.latitude,
                longitude: place.location.coordinate.longitude)
        }
        self.createdAt = createdAt

    }
    
    var asDictionary: [String: Any] {
        [
            "id": id,
            "ownerId": ownerId,
            "name": name,
            "places": places
        ]
    }
}
