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
    @Environment(AppViewModel.self) var appVM: AppViewModel
    @Environment(Router.self) var router: Router
    
    enum Mode: String, CaseIterable, Identifiable {
        case first = "Recently Planned Trips"
        case second = "Recommended Trips"
        var id: Self { self }
    }
    
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
                
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .background(Color(.systemBackground))
                .padding(.horizontal, 16)
                
                
                switch mode {
                case .first:
                    TripFeed(trips: appVM.tripFeed, isLoading: appVM.isLoadingTrips, route: $router.feedRoute) {
                        appVM.refreshFeed()
                    } loadTrips: {
                        appVM.loadTrips()
                    }
                    .navigationDestination(for: FeedRoute.self) { route in
                        switch route {
                        case .tripDetail: TripDetailView()
                        }
                    }
                    
                case .second:
                    Text("hello")
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

