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
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    @Environment(Router.self) var router: Router

    // Routes between selectionPlaces
    @State var routes: [MKRoute] = []
    
    @State var error: String?
    
    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var tripCreationVM = tripCreationVM

        // Map interface
        Map (position: $locationVM.currentLocation) {
            ForEach(tripCreationVM.selectedPlaces, id: \.self) { place in
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
                routes = try await locationVM.createRoute(selectedPlaces: tripCreationVM.selectedPlaces)
            } catch {
                self.error = error.localizedDescription
            }
            
        }
        // Scroll View of chosen locations
        ScrollView {
             VStack {
                 ForEach(tripCreationVM.selectedPlaces, id: \.identifier) { result in
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
            Task {
                do {
                    try await appVM.saveTrip(name: tripCreationVM.name, selectedPlaces: tripCreationVM.selectedPlaces, preferences: tripCreationVM.preferences.map {$0.preference })
                    router.tripCreationRoute.removeLast(router.tripCreationRoute.count)
                    router.selectedTab = .home
                } catch {
                    self.error = error.localizedDescription
                }
            }
        }
        if let error {
            Text(error)
                .font(.footnote)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
        
    }
}

#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")

    NavigationStack {
        CreateRouteView()
            .environment(LocationViewModel(user: user))
            .environment(AppViewModel(user: user))
            .environment(TripCreationViewModel())

    }
}
