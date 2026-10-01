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
// TODO: MOVE SIGN OUT TO SETTINGS PAGE
struct HomeView: View {
    @Environment(AppViewModel.self) var appVM: AppViewModel
    @Environment(Router.self) var router: Router
    var body: some View {
        @Bindable var appVM = appVM
        @Bindable var router = router
        
        NavigationStack(path: $router.feedRoute) {
            VStack (alignment: .leading) {
                Text("Your Feed").font(.largeTitle).padding()
                
                TripFeed(trips: appVM.tripFeed, isLoading: appVM.isLoadingTrips) {
                    appVM.refreshFeed()
                } loadTrips: {
                    appVM.loadTrips()
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
    NavigationStack {
        let user = AppUser(id: "Test", username: "test", email: "test@email.com")

        HomeView()
            .environment(AppViewModel(user: user ))
            .environment(Router())
    }
}
