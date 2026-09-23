//
//  AppViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 17/9/2026.
//

import Foundation

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
    
    func saveTrip(trip: Trip) {
        isLoading = true
        Task {
            do {
                try await tripService.saveTrip(trip: trip)
            } catch {
                self.error = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func loadAllTrips() {
        isLoading = true
        Task {
            do {
                tripFeed = try await tripService.loadAllTrips()
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    
}
