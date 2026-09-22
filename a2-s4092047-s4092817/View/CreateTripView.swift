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
/// - Uses ``LocationViewModel`` to pass stops to ``CreateRouteView``

struct CreateTripView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    
    
    var body: some View {
        @Bindable var locationVM = locationVM
            VStack {
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
                
                // Location Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField(
                        "Search a place",
                        text: $locationVM.searchRequest
                    )
                    if !locationVM.searchRequest.isEmpty {
                        Button {
                            locationVM.searchRequest = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Button("Search") {
                    locationVM.searchPlaces()
                }
                
                // Search options
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

                .safeAreaInset(edge: .bottom) {
                    NavigationLink(destination: CreateRouteView()) {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .buttonStyle(.glassProminent)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .background(.bar)
                }}
            .navigationTitle(Text("Select Stops"))
            .navigationSubtitle(Text("Add stops to your trip!"))
        }
}

#Preview {
    NavigationStack {
        CreateTripView().environment(LocationViewModel())
    }
}
