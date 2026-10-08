//
//  TripDetailView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import SwiftUI
import MapKit

struct TripDetailView: View {
    @Environment(AppViewModel.self) var appVM: AppViewModel
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(Router.self) var router: Router

    @State var routes: [MKRoute] = []
    
    @State private var mode: Mode = .first
    @State private var error: String?
    
    enum Mode: String, CaseIterable, Identifiable {
        case first = "Details"
        case second = "Places"
        var id: Self { self }
    }
    
    var body: some View {
        if let trip = appVM.currentTrip {
            ScrollView {

            VStack {
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

                
            
            .frame(height: 425)
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
                            Spacer()
                        }
                        SaveTripButton(trip: trip)
                       
                    }.padding()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                
                switch mode {
                case .first:
                    
                    VStack(alignment: .leading) {
                        Text(trip.description)
                            .accessibilityIdentifier("trip.description")
                        Divider()
                        Text("Created on \(trip.createdAt.formatted())")
                            .font(.subheadline)
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
            // TODO: Toolbar disappear / reappear animation?
                .toolbar(.hidden, for: .tabBar)
            if let error {
                Text(error)
                    .foregroundStyle(.red)
            }
        

            
        } else {
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
