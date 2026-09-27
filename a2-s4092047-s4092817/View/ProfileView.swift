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

        TripFeed(trips: appVM.yourTrips, isLoading: appVM.isLoading) {
            appVM.refreshUserTrips()
        } loadTrips: {
            appVM.loadYourTrips()
        }
    }
}
