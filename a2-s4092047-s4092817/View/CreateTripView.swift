//
//  CreateTripView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 17/9/2026.
//

import SwiftUI
import MapKit

struct CreateTripView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    let request = MKLocalSearch.Request()
    @State private var searchRequest: String = ""
    
    @State private var searchResults: [MKMapItem] = []
    @State private var tripPlaces: [MKMapItem] = []
    
    var body: some View {
        
        @Bindable var locationVM = locationVM
        
        Map (position: $locationVM.currentLocation) {
            ForEach(tripPlaces, id: \.self) { place in
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
                text: $searchRequest
            )
        Button("Search") {
            request.naturalLanguageQuery = searchRequest
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                guard let response = response else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }

                searchResults = response.mapItems
            }

            }
        ForEach(searchResults, id: \.identifier) { result in
            VStack {
                Text(result.name ?? "no name")
                Text(result.address?.fullAddress ?? "no name")
                Button("Add") {
                    tripPlaces.append(result)
                }
            }
        }
        Spacer()
    }
}

#Preview {
    CreateTripView()
}
