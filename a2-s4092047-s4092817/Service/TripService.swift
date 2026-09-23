//
//  TripService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 22/9/2026.
//

import Foundation
import FirebaseFirestore

///
/// Trip service that handles reading and writing trips to the firebase store
@MainActor
protocol TripService {
    func saveTrip(trip: Trip) async throws
}

///
/// Real implementation of TripService used in the app
@MainActor
final class TripServiceImpl: TripService {
    private let db = Firestore.firestore()
    
    
    // Save a trip to firestore
    func saveTrip(trip: Trip) async throws {
        let ref = db.collection("trips").document()
        
        let tripWithId = Trip(id: ref.documentID, ownerId: trip.ownerId, name: trip.name, places: trip.places, createdAt: trip.createdAt, preferences: trip.preferences)
        try await ref.setData(tripWithId.asDictionary)
    }
}
