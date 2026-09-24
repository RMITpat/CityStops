//
//  CreateRouteView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 21/9/2026.
//

import SwiftUI
import MapKit

/// View that displays the shortest route that visits all chosen daytrip stops.
/// Uses ``LocationViewModel`` to calculate route.
struct CreateRouteView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(AppViewModel.self) var appVM: AppViewModel

    // Routes between selectionPlaces
    @State var routes: [MKRoute] = []
    
    // Places selected by the user to be a part of the trip
    let selectedPlaces: [MKMapItem]
    
    var body: some View {
        @Bindable var locationVM = locationVM

        // Map interface
        Map (position: $locationVM.currentLocation) {
            ForEach(selectedPlaces, id: \.self) { place in
                Marker(item: place)
                    .mapItemDetailSelectionAccessory(.callout)
            }
            ForEach(routes, id: \.self) { route in
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
            
        }
        .frame(height:400)
        // Route between stops
        .task {
            do {
                routes = try await locationVM.createRoute(selectedPlaces: selectedPlaces)
            } catch {
                
            }
            
        }
        // Scroll View of chosen locations
        ScrollView {
             VStack {
                 ForEach(selectedPlaces, id: \.identifier) { result in
                     VStack {
                         // and any other details such as place type
                         Text(result.name ?? "no name")
                         Text(result.address?.fullAddress ?? "no name")
                        
                     }
                 }
             }
         }
        Spacer()
        Button("Finish") {
            appVM.saveTrip(name: locationVM.name, selectedPlaces: selectedPlaces, preferences: locationVM.preferences)
        }
        
    }
}

#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")

    NavigationStack {
        CreateRouteView(selectedPlaces: [])
            .environment(LocationViewModel(user: user))
            .environment(AppViewModel(user: user))
    }
}
