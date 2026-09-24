//
//  AppViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 17/9/2026.
//

import Foundation
import MapKit

enum Route {
    case createTrip
    case createRoute
}

@Observable class AppViewModel {
    
    var path: [Route] = [Route]()
    
    private let tripService: TripService
    
    private let user: AppUser
    
    var error: String?
    
    var isLoading: Bool = false
    
    var tripFeed: [Trip] = []
    
//    var loadedItems: [String: MKMapItem] = [:]
    
    // Real init
    init(user: AppUser) {
        let service = TripServiceImpl()
        self.tripService = service
        self.user = user
    }
    
    // Init used by mock
    init(service: TripService, user: AppUser) {
        self.tripService = service
        self.user = user
    }
    
    // Saves a trip to Firestore
    func saveTrip(name: String, selectedPlaces: [MKMapItem], preferences: [String]) {
        isLoading = true
        Task {
            do {
                let placeIdentifiers = selectedPlaces.compactMap { $0.identifier }
                let newTrip = Trip(ownerId: user.id, name: name, places: placeIdentifiers, preferences: preferences)
                try await tripService.saveTrip(trip: newTrip)
            } catch {
                self.error = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    
    /// Function to start reading all trips from Firestore
    func loadAllTrips() {
        tripFeed.removeAll()
        isLoading = true
        Task {
            do {
                // Call the service
                let loadedTrips = try await tripService.loadAllTrips()
                
                // For each trip,
                for trip in loadedTrips {
                    // Convert its stops, stored as MKMapItem.Identifier's, to MKMapItems so they can be displayed
                    let updatedTrip = try await getMKMapItemsForTrip(trip: trip)
                    
                    // Only once all stops have been converted do we add the trip to the tripFeed, causing the fully loaded trip to appear in HomeView
                    tripFeed.append(updatedTrip)
                }
             
            } catch {
                self.error = error.localizedDescription
                
            }
            isLoading = false
            
            
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
    
    
}
