//
//  CreateTripView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 17/9/2026.
//

import SwiftUI
import MapKit

struct CreateTripView: View {
    @State private var cameraPosition: MapCameraPosition = .automatic
    private let locationManager = CLLocationManager()
    let request = MKLocalSearch.Request()
    @State private var searchRequest: String = ""
    
    @State private var searchResults: [MKMapItem] = []
    var body: some View {
        
        Map (position: $cameraPosition){
            UserAnnotation()
        }
        .frame(height:400)
        .onAppear {
          
            locationManager.requestWhenInUseAuthorization()
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
            }
        }
        Spacer()
    }
}

#Preview {
    CreateTripView()
}
