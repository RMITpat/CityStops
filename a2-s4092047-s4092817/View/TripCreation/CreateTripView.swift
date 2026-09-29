//
//  CreateTripView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 17/9/2026.
//

import SwiftUI
import MapKit

///
/// View for adding stops to a ``Trip``. Contains a Map and search bar through which users can search for locations by name. Results can be added as pins on the map.
/// - Uses ``LocationViewModel`` to pass stops to ``CreateRouteView``

struct CreateTripView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    
    
    var body: some View {
        @Bindable var locationVM = locationVM
        VStack {
            // TODO: Need to figure out if displaying map is suitable for interface, or take another approach
            // Map interface
            //                Map (position: $locationVM.currentLocation) {
            //                    ForEach(locationVM.selectedPlaces, id: \.self) { place in
            //                        Marker(item: place)
            //                            .mapItemDetailSelectionAccessory(.callout)
            //                    }
            //                }
            //                .frame(height:400)
            //                .onAppear {
            //                    locationVM.checkLocationAuthorization()
            //                }
            
            // MARK: "Search" Button
            Button("Search") {
                locationVM.searchPlaces()
            }
            .buttonStyle(.glassProminent)
            
            // MARK: Location search results
            ScrollView {
                VStack {
                    // Generate location detail cards
                    ForEach(locationVM.searchResults, id: \.identifier) { result in
                        LocationCardView(location: result, locationVM: locationVM)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        
        // MARK: "Next" Button
        .safeAreaInset(edge: .bottom) {
            NavigationLink(destination: CreateRouteView()) {
                Text("Next")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.glassProminent)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
            .navigationTitle(Text("Select Stops"))
            .navigationSubtitle(Text("Add stops to your trip!"))
        
            // MARK: Location Search Bar
            .searchable(
                text: $locationVM.searchRequest,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for a place",
            )
        }
}


#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")
    NavigationStack {
        CreateTripView().environment(LocationViewModel(user: user))
    }
}
