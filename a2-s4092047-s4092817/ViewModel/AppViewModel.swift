//
//  AppViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 17/9/2026.
//

import Foundation
import MapKit



///
/// Handles communication with firebase and general app states
///
@Observable class AppViewModel {
    
    /// Tripservice used for getting trip data from firebase
    private let tripService: TripService
    
    /// The currently logged in user
    let user: AppUser
    
    /// Error displayed in views from various methods
    var error: String?
    
    /// Are trips currently loading for the trip feed
    var isLoadingTrips: Bool = false
    
    /// Are trips currently loading for the user's created trips
    var isLoadingUserTrips: Bool = false
    
    /// Are trips currently loading for the user's saved trips
    var isLoadingSavedTrips: Bool = false
    
    /// The feed of loaded trips
    var tripFeed: [Trip] = []
    
    /// The feed of user's created trips
    var yourTrips: [Trip] = []
    
    /// The feed of user's saved trips
    var savedTrips: [Trip] = []
    
    /// The current trip being viewed in TripDetailView
    var currentTrip: Trip? = nil
    
    /// Is a trip currently being saved
    var isSaving: Bool = false
    
    /// Real init used in app
    init(user: AppUser) {
        let service = TripServiceImpl()
        self.tripService = service
        self.user = user
    }
    
    /// Init used by mock in tests
    init(service: TripService, user: AppUser) {
        self.tripService = service
        self.user = user
    }
    
    /// Init used by preview
    init(user: AppUser, currentTrip: Trip) {
        let service = TripServiceImpl()
        self.tripService = service
        self.user = user
        self.currentTrip = currentTrip
    }
    /// Saves a trip to Firestore
    func saveTrip(name: String, description: String, selectedPlaces: [MKMapItem], preferences: [String]) async throws {
        isSaving = true
        let placeIdentifiers = selectedPlaces.compactMap { $0.identifier }
        let newTrip = Trip(ownerUsername: user.username, ownerId: user.id, name: name, description: description, places: placeIdentifiers, preferences: preferences)
        try await tripService.saveTrip(trip: newTrip)
        isSaving = false

    }
    
    func refreshFeed() {
        tripService.clearLastTripFeedDocument()
        tripFeed.removeAll()
        loadTrips()
    }
    
    func refreshUserTrips() {
        tripService.clearLastUserTripDocument()
        yourTrips.removeAll()
        loadYourTrips()
    }
    
    func refreshSavedTrips() {
        tripService.clearLastSavedTripDocument()
        savedTrips.removeAll()
        loadSavedTrips()
    }
    
    /// Function to start reading all trips from Firestore
    func loadTrips() {
        
        if isLoadingTrips {
            print("isloading trips")
            return }
        isLoadingTrips = true
        Task {
            do {
                // Artificial wait, can be removed but feels nice
                try await Task.sleep(for: .seconds(1))
                // Call the service
                let loadedTrips = try await tripService.loadTrips(ownerId: user.id)
                
                // For each trip,
                for trip in loadedTrips {
                    // Convert its stops, stored as MKMapItem.Identifier's, to MKMapItems so they can be displayed.
                    let updatedTrip = try await getMKMapItemsForTrip(trip: trip)
                    
                    // Only once all stops have been converted do we add the trip to the tripFeed, causing the fully loaded trip to appear in HomeView
                    tripFeed.append(updatedTrip)
                }
             
            } catch {
                self.error = error.localizedDescription
                
            }
            isLoadingTrips = false
            
            
        }
    }
    
    /// Function to start reading user's trips from Firestore
    func loadYourTrips() {
        if isLoadingUserTrips { return }
        isLoadingUserTrips = true
        Task {
            do {
                // Artificial wait, can be removed but feels nice
                try await Task.sleep(for: .seconds(1))
                
                // Call the service
                let loadedTrips = try await tripService.loadUserTrips(ownerId: user.id )
                // For each trip,
                for trip in loadedTrips {
                    // Convert its stops, stored as MKMapItem.Identifier's, to MKMapItems so they can be displayed.
                    let updatedTrip = try await getMKMapItemsForTrip(trip: trip)
                    // Only once all stops have been converted do we add the trip to the tripFeed, causing the fully loaded trip to appear in HomeView
                    yourTrips.append(updatedTrip)
                }
             
            } catch {
                self.error = error.localizedDescription
                
            }
            isLoadingUserTrips = false
            
            
        }
    }
    
    /// Function to start reading user's saved trips from Firestore
    func loadSavedTrips() {
        if isLoadingSavedTrips { return }
        isLoadingSavedTrips = true
        Task {
            do {
                // Artificial wait, can be removed but feels nice
                try await Task.sleep(for: .seconds(1))
                
                // Call the service
                let loadedTrips = try await tripService.loadSavedTrips(ownerId: user.id )

                // For each trip,
                for trip in loadedTrips {
                    // Convert its stops, stored as MKMapItem.Identifier's, to MKMapItems so they can be displayed.
                    let updatedTrip = try await getMKMapItemsForTrip(trip: trip)

                    // Only once all stops have been converted do we add the trip to the tripFeed, causing the fully loaded trip to appear in HomeView
                    savedTrips.append(updatedTrip)
                }
             
            } catch {
                self.error = error.localizedDescription
                
            }
            isLoadingSavedTrips = false
            
            
        }
    }
    
    /// Function for converting a trip's place Identifiers to MKMapItems
    func getMKMapItemsForTrip(trip: Trip) async throws -> Trip {
        var trip = trip
        for identifier in trip.places {
            let place = try await getMKMapItemFromId(identifier: identifier)
            trip.mkMapItemPlaces.append(place)

        }
        return trip
    }
    
    /// Function for converting a singular Identifier to an MKMapItem
    func getMKMapItemFromId(identifier: MKMapItem.Identifier) async throws -> MKMapItem {
        
        let request = MKMapItemRequest(mapItemIdentifier: identifier)
    
        return try await request.mapItem
      
        
    }
    
    /// Calls service to save a document which contains the user's id and the id of the trip they are bookmarking
    func bookmarkTrip(tripId: String) async throws {

        try await tripService.bookmarkTrip(ownerId: user.id, tripId: tripId)
        if let feedSavedTrip = tripFeed.firstIndex(where: { $0.id == tripId}) {
            tripFeed[feedSavedTrip].savedByUser = true

        }
        
        if let userSavedTrip = yourTrips.firstIndex(where: { $0.id == tripId}) {
            yourTrips[userSavedTrip].savedByUser = true
        }
        
        if let savedSavedTrip = savedTrips.firstIndex(where: { $0.id == tripId}) {
            savedTrips[savedSavedTrip].savedByUser = true
        }
        currentTrip?.savedByUser = true
    }
    
    func deleteTripBookmark(tripId: String) async throws {
        
        try await tripService.removeTripBookmark(ownerId: user.id, tripId: tripId)
      
        if let feedSavedTrip = tripFeed.firstIndex(where: { $0.id == tripId}) {
            tripFeed[feedSavedTrip].savedByUser = false

        }
        
        if let userSavedTrip = yourTrips.firstIndex(where: { $0.id == tripId}) {
            yourTrips[userSavedTrip].savedByUser = false
        }
        
        if let savedSavedTrip = savedTrips.firstIndex(where: { $0.id == tripId}) {
            savedTrips[savedSavedTrip].savedByUser = false
        }
        
        currentTrip?.savedByUser = false

    }
    
    /// Delete a created trip
    func deleteTrip(tripId: String) async throws {
        try await tripService.deleteTrip(tripId: tripId)
        
        // Ensure feeds are refreshed so no stale trips are able to be interacted with by the user
        refreshFeed()
        refreshUserTrips()
        refreshSavedTrips()
        
    }
    
    /// Delete a created trip
    func deleteTrip(tripId: String) async throws {
        try await tripService.deleteTrip(tripId: tripId)
        
        // Ensure feeds are refreshed so no stale trips are able to be interacted with by the user
        refreshFeed()
        refreshUserTrips()
        refreshSavedTrips()
    }
    
    
}
