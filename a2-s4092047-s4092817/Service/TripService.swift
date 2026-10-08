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
    func loadUserTrips(ownerId: String) async throws -> [Trip]
    func loadSavedTrips(ownerId: String) async throws -> [Trip]
    func loadTrips(ownerId: String) async throws -> [Trip]
    
    func clearLastTripFeedDocument()
    func clearLastUserTripDocument()
    func clearLastSavedTripDocument()
    
    func bookmarkTrip(ownerId: String, tripId: String) async throws
    func removeTripBookmark(ownerId: String, tripId: String) async throws
    
    func deleteTrip(tripId: String) async throws
}

///
/// Real implementation of TripService used in the app
@MainActor
final class TripServiceImpl: TripService {
    private let db = Firestore.firestore()
    
    private var lastTripFeedDocument: DocumentSnapshot?
    private var lastUserTripDocument: DocumentSnapshot?
    private var lastSavedTripDocument: DocumentSnapshot?

    private var reachedEndTripFeed: Bool = false
    private var reachedEndUserTrips: Bool = false
    private var reachedEndSavedTrips: Bool = false

    /// Save a trip to firestore
    func saveTrip(trip: Trip) async throws {
        let ref = db.collection("trips").document()
        
        let tripWithId = Trip(id: ref.documentID, ownerUsername: trip.ownerUsername, ownerId: trip.ownerId, name: trip.name, description: trip.description, places: trip.places, createdAt: trip.createdAt, preferences: trip.preferences)
        try await ref.setData(tripWithId.asDictionary)
    }
    
    /// Reset the last document so the next LoadTrips() call  LoadFirst4Trips()
    func clearLastTripFeedDocument() {
        lastTripFeedDocument = nil
        reachedEndTripFeed = false
    }
    
    /// Reset the last document so the next LoadTrips() call  LoadFirst4Trips()
    func clearLastUserTripDocument() {
        lastUserTripDocument = nil
        reachedEndUserTrips = false
    }
    
    /// Reset the last saved trip document so the next LoadTrips() calls LoadFirst4Trips()
    func clearLastSavedTripDocument() {
        lastSavedTripDocument = nil
        reachedEndSavedTrips = false
    }
    
    
    /// Get trips for trip feed from Firebase
    func loadTrips(ownerId: String) async throws -> [Trip] {
        if reachedEndTripFeed {
            return []
        }
        var queryDocuments: [QueryDocumentSnapshot] = []
        let query = db.collection("trips")
            .order(by: "createdAt", descending: true)
            .limit(to: 4)
        
        
        if let lastTripFeedDocument {
            queryDocuments = try await loadNext4Trips(lastDocument: lastTripFeedDocument, query: query)
        } else {
            queryDocuments = try await loadFirst4Trips(query: query)
        }
        
        lastTripFeedDocument = queryDocuments.last
        
        // When we reach the end, the last document will be nil. To prevent the feed from starting again and loadFirst4Trips() being called, set this bool
        if lastTripFeedDocument == nil {
            reachedEndTripFeed = true
        }
        return try await retrieveTrips(queryDocuments: queryDocuments, ownerId: ownerId)
    }
    
  
    
    /// Get user trips from Firebase
    func loadUserTrips(ownerId: String) async throws -> [Trip] {
        if reachedEndUserTrips {
            return []
        }
        var queryDocuments: [QueryDocumentSnapshot] = []
        let query = db.collection("trips")
            .whereField("ownerId", isEqualTo: ownerId)
            .order(by: "createdAt", descending: true)
            .limit(to: 4)
        
        if let lastUserTripDocument {
            queryDocuments = try await loadNext4Trips(lastDocument: lastUserTripDocument, query: query)
        } else {
            queryDocuments = try await loadFirst4Trips(query: query)
        }
        
        lastUserTripDocument = queryDocuments.last
        
        // When we reach the end, the last document will be nil. To prevent the feed from starting again and loadFirst4UserTrips() being called, set this bool
        if lastUserTripDocument == nil {
            reachedEndUserTrips = true
        }
        
        
        return try await retrieveTrips(queryDocuments: queryDocuments, ownerId: ownerId)
    }
    
    /// Get saved trips from Firebase
    func loadSavedTrips(ownerId: String) async throws -> [Trip] {
        if reachedEndSavedTrips {
            return []
        }
        let query = db.collection("bookmarkedTrips")
            .whereField("ownerId", isEqualTo: ownerId)
            .order(by: "createdAt", descending: true)
            .limit(to: 4)
        
       
        var savedTrips: [QueryDocumentSnapshot] = []

        if let lastSavedTripDocument {
            savedTrips = try await loadNext4Trips(lastDocument: lastSavedTripDocument, query: query)
            
        } else {
            savedTrips = try await loadFirst4Trips(query: query)
            
        }
        
        lastSavedTripDocument = savedTrips.last
        
        // When we reach the end, the last document will be nil. To prevent the feed from starting again and loadFirst4UserTrips() being called, set this bool
        if lastSavedTripDocument == nil {
            reachedEndSavedTrips = true
        }
        
        let convertedTrips: [QueryDocumentSnapshot] = try await lookupSavedTrips(savedTrips: savedTrips)
        
        return try await retrieveTrips(queryDocuments: convertedTrips, ownerId: ownerId)
    }
    
    /// Looks up the saved trip id in the trips collection manually since Firestore is NoSQL and has no table joins :(
    func lookupSavedTrips(savedTrips: [QueryDocumentSnapshot]) async throws -> [QueryDocumentSnapshot] {
        var queryDocuments: [QueryDocumentSnapshot] = []

        for doc in savedTrips {
            let data = doc.data()
            if let tripId = data["tripId"] as? String {
                
                let getTripsFromId = db.collection("trips")
                    .whereField("id", isEqualTo: tripId)
                    .limit(to: 4)
                
                let trip = try await loadFirst4Trips(query: getTripsFromId)

                queryDocuments.append(contentsOf: trip)
                
                
            }
            
        }
        return queryDocuments
    }
    
    
    /// Turn querydocuments into trips
    func retrieveTrips(queryDocuments: [QueryDocumentSnapshot], ownerId: String) async throws -> [Trip] {
        var trips: [Trip] = []
        for document in queryDocuments {
                let isSaved = try await checkIfTripIsSaved(
                    ownerId: ownerId,
                    tripId: document.documentID
                )

                if let trip = Trip(snapshot: document, isSaved: isSaved) {
                    trips.append(trip)
                }
            }
        
        return trips
    }
    
    /// Loads the first 4 trips and sets the lastDocument for the next query to begin at
    func loadFirst4Trips(query: FirebaseFirestore.Query) async throws -> [QueryDocumentSnapshot] {
        let snapshot = try await query.getDocuments()

        return snapshot.documents
    }
    
    
    /// Loads the next 4 trips starting at the previous query's end
    func loadNext4Trips(lastDocument: DocumentSnapshot, query: FirebaseFirestore.Query) async throws -> [QueryDocumentSnapshot] {
        let snapshot = try await query
            .start(afterDocument: lastDocument)
            .getDocuments()
        
        return snapshot.documents
    
    }
 
    
    /// Save a document which contains the user's id and the id of the trip they are bookmarking
    func bookmarkTrip(ownerId: String, tripId: String) async throws {
        let ref = db.collection("bookmarkedTrips").document()
        
        let data: [String : Any] = [
            "ownerId" : ownerId,
            "tripId" : tripId,
            "createdAt" : Date()
        ]
        try await ref.setData(data)
    }
    
    /// Unsave a trip by deleting document from bookmarkedTrips collection
    func removeTripBookmark(ownerId: String, tripId: String) async throws {
        let dbCollection = db.collection("bookmarkedTrips")
        let snapshot = try await dbCollection
            .whereField("ownerId", isEqualTo: ownerId)
            .whereField("tripId", isEqualTo: tripId)
            .getDocuments()
        
        if let document = snapshot.documents.first {
            try await document.reference.delete()
        }
        
    }
    /// Save a trip by adding document to bookmarkedTrips collection
    func checkIfTripIsSaved(ownerId: String, tripId: String) async throws -> Bool {
        let dbCollection = db.collection("bookmarkedTrips")
        let snapshot = try await dbCollection
            .whereField("ownerId", isEqualTo: ownerId)
            .whereField("tripId", isEqualTo: tripId)
            .getDocuments()
        return !snapshot.documents.isEmpty
    }
    
    /// Delete a trip by deleting document from trips collection
    func deleteTrip(tripId: String) async throws {
        
        let tripsSnapshot = try await db.collection("trips")
            .whereField("id", isEqualTo: tripId)
            .getDocuments()
        
        for document in tripsSnapshot.documents {
            try await document.reference.delete()
        }
        
        // Delete any references to it in bookmarkedTrips
        let savedTripsSnapshot = try await db.collection("bookmarkedTrips")
            .whereField("tripId", isEqualTo: tripId)
            .getDocuments()
        
        for document in savedTripsSnapshot.documents {
            try await document.reference.delete()
        }
    }
    
}


