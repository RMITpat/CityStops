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

    var body: some View {
        @Bindable var appVM = appVM
        VStack (alignment: .leading) {
            Text("Your Feed").font(.largeTitle).padding()
            
            TripFeed(trips: appVM.tripFeed, isLoading: appVM.isLoading) {
                appVM.refreshFeed()
            } loadTrips: {
                appVM.loadTrips()
            }
        }
    }
}

#Preview {
    NavigationStack {
        let user = AppUser(id: "Test", username: "test", email: "test@email.com")

        HomeView()
            .environment(AppViewModel(user: user ))
    }
}
