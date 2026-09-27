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
        ScrollView {
            LazyVStack {
                ForEach(appVM.tripFeed, id: \.id) { trip in
                    TripCard(trip: trip)
                }
                Text("")
                    .onAppear {appVM.loadAllTrips() }
                if (appVM.isLoading) {
                    ProgressView()
                }
                Spacer()
            }
        }
//        .onAppear {
//            appVM.loadAllTrips()
//        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
