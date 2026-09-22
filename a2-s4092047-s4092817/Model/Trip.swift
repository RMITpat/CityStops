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
    
    let id: String
    let name: String
    let places: [GeoPoint]
    
    init(id: String, name: String, places: [MKMapItem]) {
        self.id = id
        self.name = name
        self.places = places.map { (place: MKMapItem) -> GeoPoint in
            return GeoPoint(
                latitude: place.location.coordinate.latitude,
                longitude: place.location.coordinate.longitude)
        }
    }
}
