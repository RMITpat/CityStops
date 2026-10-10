//
//  HomeView.swift
//  a2_s4092047-s4092817
//
//  Created by Patrick Ly on 15/9/2026.
//

import SwiftUI
import MapKit
///
/// Home view for viewing trip feed.
/// Implements ``AuthViewModel`` to allow sign out (needs to be moved into settings)
struct HomeView: View {
    /// AppViewModel for accessing Firebase
    @Environment(AppViewModel.self) var appVM: AppViewModel
    /// Router for view navigation
    @Environment(Router.self) var router: Router
    
    /// Mode for controlling picker display
    enum Mode: String, CaseIterable, Identifiable {
        case first = "Recently Planned Trips"
        case second = "Recommended Trips"
        var id: Self { self }
    }
    
    /// The current picker display
    @State var mode: Mode
    
    var body: some View {
        @Bindable var appVM = appVM
        @Bindable var router = router
        
        NavigationStack(path: $router.feedRoute) {
            VStack (alignment: .leading) {
                // MARK: View Title
                // Mimic ``NavigationTitle`` styling
                Text("Your Daytrip Feed")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.top, 56)
                
                // MARK: The picker for displaying different feeds
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .background(Color(.systemBackground))
                .padding(.horizontal, 16)
                
                
                switch mode {
                case .first:
                    // MARK: Recenty craeted trips feed
                    TripFeed(trips: appVM.tripFeed, isLoading: appVM.isLoadingTrips, route: $router.feedRoute) {
                        appVM.refreshFeed()
                    } loadTrips: {
                        appVM.loadTrips()
                    }
                    
                case .second:
                    // MARK: Recommended trips feed
                    if appVM.isLoadingRecommendedTrips {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    else if appVM.recommendedTrips.isEmpty {
                        ScrollView {
                            ContentUnavailableView(
                                "No relevant recommendations",
                                systemImage: "sparkles",
                                description: Text("Sorry, we couldn't find trips that match your saved preferences. Try saving some more trips that you like.")
                            )
                        }
                        .refreshable {  appVM.refreshRecommendedTrips() }
                    }
                    else {
                        TripFeed(trips: appVM.recommendedTrips, isLoading: appVM.isLoadingRecommendedTrips, route: $router.feedRoute) {
                            appVM.refreshRecommendedTrips()
                        } loadTrips: {
                            // recommendations aren't paginated
                        }
                    }
                }
            }
            .navigationDestination(for: FeedRoute.self) { route in
                switch route {
                case .tripDetail: TripDetailView()
                }
            }

            Spacer()
        }
    }
}

#Preview {
        let user = AppUser(id: "Test", username: "test", email: "test@email.com")

    HomeView(mode: .first)
            .environment(AppViewModel(user: user ))
            .environment(Router())
    }
