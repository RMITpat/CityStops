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
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    var body: some View {
        @Bindable var appVM = appVM
        ScrollView {
            VStack {
                
                ForEach(appVM.tripFeed, id: \.id) { trip in
                    Text(trip.name)
                    Map {
                        ForEach(trip.mkMapItemPlaces, id: \.self) { place in
                                Marker(item: place)
                                    .mapItemDetailSelectionAccessory(.callout)
                            
                        }
                        
                    }.frame(height: 400)
                }
                if (appVM.isLoading) {
                    ProgressView()
                }
                Spacer()
                
            }
        }.onAppear {
            appVM.loadAllTrips()
        }
            .navigationTitle("Welcome!")
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
