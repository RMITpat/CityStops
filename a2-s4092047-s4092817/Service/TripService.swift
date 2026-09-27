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
    func loadFirst4Trips() async throws -> [QueryDocumentSnapshot]
    func loadNext4Trips(lastDocument: DocumentSnapshot) async throws -> [QueryDocumentSnapshot]
    
    func loadUserTrips(ownerId: String) async throws -> [Trip]
    func loadFirst4UserTrips(ownerId: String) async throws -> [QueryDocumentSnapshot]
    func loadNext4UserTrips(lastDocument: DocumentSnapshot, ownerId: String) async throws -> [QueryDocumentSnapshot]
    
    func clearLastTripFeedDocument()
    func clearLastUserTripDocument()

}

///
/// Real implementation of TripService used in the app
@MainActor
final class TripServiceImpl: TripService {
    private let db = Firestore.firestore()
    
    private var lastTripFeedDocument: DocumentSnapshot?
    private var lastUserTripDocument: DocumentSnapshot?
    
    private var reachedEndTripFeed: Bool = false
    private var reachedEndUserTrips: Bool = false

    // Save a trip to firestore
    func saveTrip(trip: Trip) async throws {
        let ref = db.collection("trips").document()
        
        let tripWithId = Trip(id: ref.documentID, ownerId: trip.ownerId, name: trip.name, places: trip.places, createdAt: trip.createdAt, preferences: trip.preferences)
        try await ref.setData(tripWithId.asDictionary)
    }
    
    func clearLastTripFeedDocument() {
        lastTripFeedDocument = nil
        reachedEndTripFeed = false
    }
    
    func clearLastUserTripDocument() {
        lastUserTripDocument = nil
        reachedEndUserTrips = false
    }
    
    // Get trips for trip feed from Firebase
    func loadTrips() async throws -> [Trip] {
        if reachedEndTripFeed {
            return []
        }
        var queryDocuments: [QueryDocumentSnapshot] = []
        
        if let lastTripFeedDocument {
            queryDocuments = try await loadNext4Trips(lastDocument: lastTripFeedDocument)
        } else {
            queryDocuments = try await loadFirst4Trips()
        }
        
        lastTripFeedDocument = queryDocuments.last
        
        if lastTripFeedDocument == nil {
            reachedEndTripFeed = true
        }
        
        return queryDocuments
            .compactMap { Trip(snapshot: $0) }

    }
    
    func loadFirst4Trips() async throws -> [QueryDocumentSnapshot] {
        let snapshot = try await db.collection("trips")
            .order(by: "createdAt", descending: true)
            .limit(to: 4)
            .getDocuments()
        
        return snapshot.documents
        
        
    }
    
    func loadNext4Trips(lastDocument: DocumentSnapshot) async throws -> [QueryDocumentSnapshot] {
        let snapshot = try await db.collection("trips")
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastDocument)
            .limit(to: 4)
            .getDocuments()
        
        return snapshot.documents
    
    }
    
    // Get user trips from Firebase
    func loadUserTrips(ownerId: String) async throws -> [Trip] {
        if reachedEndUserTrips {
            return []
        }
        var queryDocuments: [QueryDocumentSnapshot] = []
        
        
        if let lastUserTripDocument {
            queryDocuments = try await loadNext4UserTrips(lastDocument: lastUserTripDocument, ownerId: ownerId)
        } else {
            queryDocuments = try await loadFirst4UserTrips(ownerId: ownerId)
        }
        
        lastUserTripDocument = queryDocuments.last
        
        if lastUserTripDocument == nil {
            reachedEndUserTrips = true
        }
        
        return queryDocuments
            .compactMap { Trip(snapshot: $0) }

    }
    
    // Loads the signed-in user's trips.
    func loadFirst4UserTrips(ownerId: String) async throws -> [QueryDocumentSnapshot] {
        let snapshot = try await db.collection("trips")
            .whereField("ownerId", isEqualTo: ownerId)
            .order(by: "createdAt", descending: true)
            .limit(to: 4)
            .getDocuments()

        return snapshot.documents
    }
    
    
    
    func loadNext4UserTrips(lastDocument: DocumentSnapshot, ownerId: String) async throws -> [QueryDocumentSnapshot] {
        let snapshot = try await db.collection("trips")
            .whereField("ownerId", isEqualTo: ownerId)
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastDocument)
            .limit(to: 4)
            .getDocuments()
        
        return snapshot.documents
    
    }
}
