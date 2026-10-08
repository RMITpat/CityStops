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
    
    var id: String
    let ownerId: String
    let ownerUsername: String
    let name: String
    let description: String
    let places: [MKMapItem.Identifier]
    let createdAt: Date
    let preferences: [String]
    
    var savedByUser: Bool = false
    var mkMapItemPlaces: [MapItem] = []
    
    init(id: String = "", ownerUsername:String, ownerId: String, name: String, description: String, places: [MKMapItem.Identifier], createdAt: Date = Date(), preferences: [String], savedByUser: Bool = false) {
        self.id = id
        self.ownerId = ownerId
        self.ownerUsername = ownerUsername
        self.name = name
        self.description = description
        self.places = places
        self.createdAt = createdAt
        self.preferences = preferences
        self.savedByUser = savedByUser
        
    }
    
    
    var asDictionary: [String: Any] {
        let rawValueIdentifiers: [String] = places.map { $0.rawValue }
        
        return [
            "id": id,
            "ownerId": ownerId,
            "ownerUsername": ownerUsername,
            "name": name,
            "description": description,
            "places": rawValueIdentifiers,
            "createdAt" : createdAt,
            "preferences" : preferences
        ]
    }
    
    // Converts a Firestore document back into Project.
    init?(snapshot: QueryDocumentSnapshot, isSaved: Bool) {
        
        let data = snapshot.data()
        
        guard
            let ownerId = data["ownerId"] as? String,
            let ownerUsername = data["ownerUsername"] as? String,
            let name = data["name"] as? String,
            let description = data["description"] as? String,
            let places = data["places"] as? [String],
            let preferences = data["preferences"] as? [String],
            let timestamp = data["createdAt"] as? Timestamp
                
        else {
            return nil
        }
        
        id = snapshot.documentID
        self.ownerId = ownerId
        self.ownerUsername = ownerUsername
        self.name = name
        self.description = description
        self.places = places.compactMap { MKMapItem.Identifier(rawValue: $0) }
        self.preferences = preferences
        self.savedByUser = isSaved
        createdAt = timestamp.dateValue()
    }
    //FIXME: FOR TESTING PURPOSES ONLY (FOR NOW)
    func toString() -> String {
        return "\(id) \(ownerId) \(ownerUsername) \(name) \(description) \(places) \(createdAt) \(preferences)"
    }
    
}
