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
    func loadAllTrips() async throws -> [Trip]
    func loadUserTrips(ownerId: String) async throws -> [Trip] 

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
    
    // Get all trips from Firebase
    func loadAllTrips() async throws -> [Trip] {
        let snapshot = try await db.collection("trips")
            .getDocuments()

        return snapshot.documents
            .compactMap { Trip(snapshot: $0) }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    
    // Loads the signed-in user's trips.
    func loadUserTrips(ownerId: String) async throws -> [Trip] {
        let snapshot = try await db.collection("trips")
            .whereField("ownerId", isEqualTo: ownerId)
            .getDocuments()

        return snapshot.documents
            .compactMap { Trip(snapshot: $0) }
            .sorted { $0.createdAt > $1.createdAt }
    }
}
