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
    @State var routes: [MKRoute] = []
    
    var body: some View {
        if let trip = appVM.currentTrip {
            ScrollView {

            VStack {
                TripCardInfo(trip: trip)
                
                
            }.padding()
            Map {
                ForEach(trip.mkMapItemPlaces, id: \.self) { place in
                    Marker(item: place)
                        .mapItemDetailSelectionAccessory(.callout)
                    ForEach(routes, id: \.self) { route in
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
                
            }
            
            .frame(height: 425)
            .task {
                do {
                    routes = try await locationVM.createRoute(selectedPlaces: trip.mkMapItemPlaces, tripID: trip.id)
                } catch {
                    // TODO: display error somewhere
                }
                
            }
                // MARK: Desc + Save button
                VStack(alignment: .center) {
                    Text(trip.description)
                    HStack() {
                        SaveTripButton(trip: trip)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                // MARK: Location List
                VStack {
                    ForEach(trip.mkMapItemPlaces, id: \.identifier) { place in
                        VStack {
                            LocationCardView(location: place)
                           
                        }
                    }
                }
            }
            Spacer()
            // TODO: Toolbar disappear / reappear animation?
                .toolbar(.hidden, for: .tabBar)

            
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
