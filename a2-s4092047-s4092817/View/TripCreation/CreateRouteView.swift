//
//  CreateRouteView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 21/9/2026.
//

import SwiftUI
import MapKit

/// View that displays the shortest route that visits all chosen ``Trip`` stops.
/// Uses ``LocationViewModel`` to calculate route.
struct CreateRouteView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(AppViewModel.self) var appVM: AppViewModel

    var body: some View {
        @Bindable var locationVM = locationVM

        // Map interface
        Map (position: $locationVM.currentLocation) {
            ForEach(locationVM.selectedPlaces, id: \.self) { place in
                Marker(item: place)
                    .mapItemDetailSelectionAccessory(.callout)
            }
            ForEach(locationVM.routes, id: \.self) { route in
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
            
        }
        .frame(height:400)
        // Route between stops
        .onAppear {
            locationVM.createRoute()
            print(locationVM.routes.count)
        }
        // Scroll View of chosen locations
        ScrollView {
             VStack {
                 ForEach(locationVM.selectedPlaces, id: \.identifier) { result in
                     VStack {
                         // and any other details such as place type
                         Text(result.name ?? "no name")
                         Text(result.address?.fullAddress ?? "no name")
                        
                     }
                 }
             }
         }
        Spacer()
        // FIXME: TESTING PURPOSES ONLY, REMOVE THIS
        Text(locationVM.getTrip().toString())
        Button("Finish") {
            appVM.saveTrip(trip: locationVM.getTrip())
        }
        
    }
}

#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")
    NavigationStack {
        CreateRouteView()
            .environment(LocationViewModel(user: user))
            .environment(AppViewModel(user: user))
    }
}
