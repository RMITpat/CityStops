//
//  ProfileView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 26/9/2026.
//

import SwiftUI

struct ProfileView: View {
    /// App viewmodel for interacting with Firebase
    @Environment(AppViewModel.self) var appVM: AppViewModel
    /// Router for view navigation
    @Environment(Router.self) var router: Router
    /// Current displayed trip feed
    @State private var mode: Mode = .first

    /// The different trip feeds to display
    enum Mode: String, CaseIterable, Identifiable {
        case first = "Your trips"
        case second = "Saved trips"
        var id: Self { self }
    }
    
    var body: some View {
        @Bindable var appVM = appVM
        @Bindable var router = router

        NavigationStack(path: $router.profileRoute) {
            
            VStack (alignment: .leading) {
                // MARK: User's display name
                Text(appVM.user.username).font(.largeTitle).padding()
                
                // MARK: Picker for currently displayed trip feed
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                
                switch mode {
                case .first:
                    // MARK: User's created trips feed
                    if appVM.yourTrips.isEmpty {
                        Text("You haven't created any trips")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                    }
                    TripFeed(trips: appVM.yourTrips, isLoading: appVM.isLoadingUserTrips, route: $router.profileRoute) {
                        appVM.refreshUserTrips()
                    } loadTrips: {
                        appVM.loadYourTrips()
                    }
                    
                case .second:
                    // MARK: User's saved trips feed
                    if appVM.savedTrips.isEmpty {
                        Text("You haven't saved any trips")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                    }
                    TripFeed(trips: appVM.savedTrips, isLoading: appVM.isLoadingSavedTrips, route: $router.profileRoute) {
                        appVM.refreshSavedTrips()
                    } loadTrips: {
                        appVM.loadSavedTrips()
                    }
                    
                }
            }.navigationDestination(for: FeedRoute.self) { route in
                switch route {
                case .tripDetail: TripDetailView()
                }
            }
        }
    }
}
