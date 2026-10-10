//
//  TripDetailView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import SwiftUI
import MapKit

/// Displays the details of a trip and allows saving/deletion
struct TripDetailView: View {
    /// App viewmodel for interacting with Firebase
    @Environment(AppViewModel.self) var appVM: AppViewModel
    /// Location ViewModel for accessing MapKit methods
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    /// Router for view navigation
    @Environment(Router.self) var router: Router
    
    /// The overall route for the trip
    @State var routes: [MKRoute] = []
    
    /// The picker's display state
    @State private var mode: Mode = .first
    /// Error message
    @State private var error: String?
    
    /// The display states for the picker
    enum Mode: String, CaseIterable, Identifiable {
        case first = "Details"
        case second = "Places"
        var id: Self { self }
    }
    
    var body: some View {
        if let trip = appVM.currentTrip {
            ScrollView {
                
                VStack {
                    // MARK: Trip name, preferences and creator
                    TripCardInfo(trip: trip)
                    
                }.padding()
                
                // MARK: UIKit Map
                UIKitMapView(
                    position: .framing(trip.mkMapItemPlaces.map({$0.mkMapItem})),
                    places: trip.mkMapItemPlaces.map({$0.mkMapItem}),
                    routes: routes,
                    showsUserLocation: true,
                    isPinSelectable: true,
                    interactionModes: .all
                )
                .accessibilityHidden(true)
                .frame(height: 325)
                .task {
                    do {
                        routes = try await locationVM.createTripRoutes(selectedPlaces: trip.mkMapItemPlaces, tripID: trip.id)
                    } catch {
                        self.error = "Failed to create trip route"
                    }
                    
                }
                
                // MARK: Desc + Save button
                VStack(alignment: .center) {
                    
                    HStack {
                        // MARK: Delete button
                        if (trip.ownerId == appVM.user.id) {
                            Button("Delete", systemImage: "trash") {
                                Task {
                                    do {
                                        try await appVM.deleteTrip(tripId: trip.id)
                                        if router.feedRoute.contains(.tripDetail) {
                                            router.feedRoute.removeAll()
                                        } else {
                                            router.profileRoute.removeAll()
                                        }
                                    } catch {
                                        self.error = "Failed to delete trip"
                                    }
                                    
                                }
                                
                            }
                            .font(.title2)
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("\(trip.id).delete")
                            .accessibilityLabel("Delete this trip")
                            Spacer()
                        }
                        // MARK: Save button
                        SaveTripButton(trip: trip)
                        
                    }.padding()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                // MARK: Picker for display state
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .accessibilitySortPriority(1)
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                
                switch mode {
                case .first:
                    // MARK: Trip description and creation date
                    VStack(alignment: .leading) {
                        Text(trip.description)
                            .accessibilityIdentifier("trip.description")
                        Divider()
                        Text("Created on \(trip.createdAt.formatted())")
                            .font(.subheadline)
                            .accessibilityLabel("Created on \(trip.createdAt.formatted(date: .complete, time: .shortened))")
                    }.padding()
                case .second:
                    // MARK: Location List
                    VStack {
                        ForEach(trip.mkMapItemPlaces, id: \.self) { place in
                            VStack {
                                LocationCard(location: place)
                                
                            }
                        }
                    }.padding()
                }
                
                
            }
            Spacer()
                .toolbar(.hidden, for: .tabBar)
            if let error {
                Text(error)
                    .foregroundStyle(.red)
            }
            
        }
        else {
            // MARK: Error
            VStack {
                Text("Error")
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }
}

#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    
    let trip = Trip(id: "1", ownerUsername: "conan", ownerId: "", name: "Cool trip", description: "Very cool trip!", places: [], preferences: ["Food", "Landmarks"])
    TripDetailView()
        .environment(LocationViewModel(user: user))
        .environment(AppViewModel(user: user, currentTrip: trip))
}
