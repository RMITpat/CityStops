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
                VStack {
                    ForEach(trip.mkMapItemPlaces, id: \.self) { place in
                        VStack {
                            Text(place.name ?? "")
                            Text(place.address?.fullAddress ?? "")
                        }
                    }
                }
            }
            Spacer()

            
        } else {
            Text("Error")
        }
    }
}

#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    
    let trip = Trip(id: "1", ownerUsername: "conan", ownerId: "", name: "Cool trip", places: [], preferences: ["Food", "Landmarks"])
    TripDetailView()
        .environment(LocationViewModel(user: user))
        .environment(AppViewModel(user: user, currentTrip: trip))
}
