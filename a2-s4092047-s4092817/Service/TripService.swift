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
    func loadTrips() async throws -> [Trip]
    func loadUserTrips(ownerId: String) async throws -> [Trip]
    func clearLastDocument()

}

///
/// Real implementation of TripService used in the app
@MainActor
final class TripServiceImpl: TripService {
    private let db = Firestore.firestore()
    
    private var lastDocument: DocumentSnapshot?
    // Save a trip to firestore
    func saveTrip(trip: Trip) async throws {
        let ref = db.collection("trips").document()
        
        let tripWithId = Trip(id: ref.documentID, ownerId: trip.ownerId, name: trip.name, places: trip.places, createdAt: trip.createdAt, preferences: trip.preferences)
        try await ref.setData(tripWithId.asDictionary)
    }
    
    func clearLastDocument() {
        lastDocument = nil
    }
    
    // Get all trips from Firebase
    func loadTrips() async throws -> [Trip] {
        if let lastDocument {
            return try await loadNext4Trips(lastDocument: lastDocument)
        } else {
            return try await loadFirst4Trips()
        }
    }
    
    func loadFirst4Trips() async throws -> [Trip] {
        let snapshot = try await db.collection("trips")
            .order(by: "createdAt", descending: true)
            .limit(to: 4)
            .getDocuments()
        
        lastDocument = snapshot.documents.last
        return snapshot.documents
            .compactMap { Trip(snapshot: $0) }
    }
    
    func loadNext4Trips(lastDocument: DocumentSnapshot) async throws -> [Trip] {
        let snapshot = try await db.collection("trips")
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastDocument)
            .limit(to: 4)
            .getDocuments()
        
        self.lastDocument = snapshot.documents.last
        return snapshot.documents
            .compactMap { Trip(snapshot: $0) }
    
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
