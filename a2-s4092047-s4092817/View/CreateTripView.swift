//
//  CreateTripView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 17/9/2026.
//

import SwiftUI
import MapKit

///
/// View for adding stops to a trip. Contains a Map and search bar through which users can search for locations by name. Results can be added as pins on the map.
/// - Uses the LocationViewModel vm

struct CreateTripView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    
    
    var body: some View {
        
        @Bindable var locationVM = locationVM
        NavigationStack {
            VStack {
                Map (position: $locationVM.currentLocation) {
                    ForEach(locationVM.selectedPlaces, id: \.self) { place in
                        Marker(item: place)
                            .mapItemDetailSelectionAccessory(.callout)
                    }
                }
                .frame(height:400)
                .onAppear {
                    locationVM.checkLocationAuthorization()
                }
                
                TextField(
                    "Search a place",
                    text: $locationVM.searchRequest
                )
                
                Button("Search") {
                    locationVM.searchPlaces()
                }
                ScrollView {
                    VStack {
                        ForEach(locationVM.searchResults, id: \.identifier) { result in
                            VStack {
                                Text(result.name ?? "no name")
                                Text(result.address?.fullAddress ?? "no name")
                                Button("Add") {
                                    locationVM.selectedPlaces.append(result)
                                }
                            }
                        }
                    }
                }
                Spacer()
                NavigationLink (destination: CreateRouteView()) {
                    Text("Next")
                    
                }
            }
        }
    }
}

#Preview {
    CreateTripView().environment(LocationViewModel())
}
