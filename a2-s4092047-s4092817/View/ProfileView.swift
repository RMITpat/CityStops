//
//  ProfileView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 26/9/2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppViewModel.self) var appVM: AppViewModel
    
    @State private var mode: Mode = .first

    enum Mode: String, CaseIterable, Identifiable {
        case first = "Your trips"
        case second = "Saved trips"
        var id: Self { self }
    }
    
    var body: some View {
        @Bindable var appVM = appVM
        
        VStack (alignment: .leading) {
            Text(appVM.user.username).font(.largeTitle).padding()
            
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            
            switch mode {
            case .first:
                if appVM.yourTrips.isEmpty {
                    Text("You haven't created any trips")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                }
                TripFeed(trips: appVM.yourTrips, isLoading: appVM.isLoadingUserTrips) {
                    appVM.refreshUserTrips()
                } loadTrips: {
                    appVM.loadYourTrips()
                }
                
            case .second:
                if appVM.savedTrips.isEmpty {
                    Text("You haven't saved any trips")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                }
                TripFeed(trips: appVM.savedTrips, isLoading: appVM.isLoadingSavedTrips) {
                    appVM.refreshSavedTrips()
                } loadTrips: {
                    appVM.loadSavedTrips()
                }
                
            }
        }
    }
}
