//
//  RecommendedFeedViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 10/10/2026.
//
import Foundation

@Observable class RecommendedFeedViewModel {
    
    /// The feed of recommended trips
    var recommendedTrips: [Trip] = []
    
    /// The maximum recommended trips to show
    private let recommendedTripCount = 5
    
    /// The app's VM, used to retrieve user.
    private let appVM: AppViewModel
    
    /// Error displayed in views from various methods
    var error: String?
    
    /// Runs the MiniLM model.
    private var recommendationService: RecommendationService
    
    private var tripService: TripService
    
    /// Set if a load recommendations run was already in progress.
    private var recommendationsOutdated = false
    
    /// Are recommended trips currently being calculated.
    var isLoadingRecommendedTrips: Bool = false
    
    /// Real init used in app.
    init(appVM: AppViewModel) {
        tripService = TripServiceImpl()
        recommendationService = RecommendationService()
        self.appVM = appVM
    }
    
    /// Function to start working out the recommended trips.
    /// It ranks trips that are in Firebase against the user's `savedTrips`, using the MiniLM model.
    func loadRecommendedTrips() {
        if isLoadingRecommendedTrips {
            recommendationsOutdated = true
            return
        }
        
        isLoadingRecommendedTrips = true
        
            Task {
                // Artificial wait, can be removed but feels nice
                try? await Task.sleep(for: .seconds(1))
                
                // Get all of saved trips directly from Firebase
                var allSavedTrips: [Trip] = []
                var savedTripTitles: [String] = []
                var savedTripIds: [String] = []
                do {
                    allSavedTrips = try await tripService.loadAllSavedTrips(ownerId: self.appVM.user.id)
                    
                    savedTripTitles = allSavedTrips.map(\.name)
                    savedTripIds = allSavedTrips.map(\.id)
                    
                } catch {
                    print("Failed to load saved trips: \(error)")
                }
                
                // get all trips from Firebase
                var allTrips: [Trip] = []
                
                do {
                    allTrips = try await tripService.loadAllTrips(ownerId: self.appVM.user.id)
                } catch {
                    self.error = error.localizedDescription
                    isLoadingRecommendedTrips = false
                    return
                }
                
                let candidates = allTrips.filter {
                    !savedTripIds.contains($0.id) && $0.ownerId != self.appVM.user.id
                }
                
                // debug
                print("saved:", savedTripTitles.count, "candidates:", candidates.count)
                
                if candidates.isEmpty || savedTripTitles.isEmpty {
                    recommendedTrips = []
                    isLoadingRecommendedTrips = false
                    return
                }
                
                // get the input Strings for the recommendation methods
                recommendationService.setCandidates(candidates.map { $0.name })
                // run the Core ML algorithm, and retrieve the Trips that meet the confidence threshold
                recommendationService.recommend(basedOn: savedTripTitles, topN: recommendedTripCount, confidenceThreshold: 0.2)
                { [weak self] names in
                    // debug
                    print("model returned:", names)
                    guard let self else { return }

                
                let matched = names.compactMap { name in
                    candidates.first {
                        $0.name.trimmingCharacters(in: .whitespacesAndNewlines) == name
                    }
                }
                
                // Get the stops in each trip
                Task {
                    var converted: [Trip] = []
                    for trip in matched {
                        if let fullTrip = try? await self.appVM.getMKMapItemsForTrip(trip: trip) {
                            converted.append(fullTrip)
                        }
                    }
                    // Assign recommendedTrips with the trips with stops included
                    self.recommendedTrips = converted
                    self.isLoadingRecommendedTrips = false
                    
                    print("recommended:", self.recommendedTrips.count)

                    // handle constant refreshes
                    if self.recommendationsOutdated {
                        self.recommendationsOutdated = false
                        self.loadRecommendedTrips()
                    }
                }
            }
        }
    }
    
    func refreshRecommendedTrips() {
        recommendedTrips.removeAll()
        loadRecommendedTrips()
    }

}
