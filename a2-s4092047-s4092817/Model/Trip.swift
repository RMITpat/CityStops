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
/// - ownerId: String The id of the user who created this trip
/// - name: String name of the trip
/// - places: [MKMapItem.Identifier] the Apple mapkit identifiers of each stop in the trip
/// - createdAt: Date the date the trip was created
/// - preferences: [String] a list of preferences that hold the trip's categories
struct Trip: Identifiable {
    
    let id: String
    let ownerId: String
    let name: String
    let places: [MKMapItem.Identifier]
    let createdAt: Date
    let preferences: [String]
    
    init(id: String = "", ownerId: String, name: String, places: [MKMapItem.Identifier], createdAt: Date = Date(), preferences: [String]) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.places = places
        self.createdAt = createdAt
        self.preferences = preferences

    }
  
    
    var asDictionary: [String: Any] {
        let rawValueIdentifiers: [String] = places.map { $0.rawValue }
        
        return [
                "id": id,
                "ownerId": ownerId,
                "name": name,
                "places": rawValueIdentifiers,
                "createdAt" : createdAt,
                "preferences" : preferences
            ]
    }
}
