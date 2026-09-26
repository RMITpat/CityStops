//
//  ProfileView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 26/9/2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppViewModel.self) var appVM: AppViewModel

    var body: some View {
        @Bindable var appVM = appVM

        ScrollView {
            VStack {
                ForEach(appVM.tripFeed, id: \.id) { trip in
                    TripCard(trip: trip)
                }
                if (appVM.isLoading) {
                    ProgressView()
                }
                Spacer()
            }
        }.onAppear {
            appVM.loadYourTrips()
        }
    }
}
