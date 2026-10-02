//
//  AITripCreationView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import SwiftUI
import MapKit

struct AITripCreationView: View {
    @State private var gemini: GeminiViewModel
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    
    @State private var prompt: String = ""
    @State private var selectedPlaces: [MKMapItem] = [MKMapItem]()
    @State var routes: [MKRoute] = []
    
    
    init(region: MKCoordinateRegion) {
        gemini = GeminiViewModel(region: region)
    }

    var body: some View {
        ScrollView {
            Map {
                ForEach(selectedPlaces.indices, id: \.self) { index in
                    Marker(item: selectedPlaces[index])
                        .mapItemDetailSelectionAccessory(.callout)
                    ForEach(routes, id: \.self) { route in
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
            }
            .frame(height: 425)

            if gemini.isLoading {
                ProgressView()
            }
            VStack {
                ForEach(selectedPlaces, id: \.self) { place in
                    VStack {
                        Text(place.name ?? "")
                        Text(place.address?.fullAddress ?? "")
                    }
                }
            }
            TextField("trip prompt", text: $prompt)
            
            Button("ai button") {
                Task {
                    do {
                        selectedPlaces = try await gemini.request(prompt: prompt)
                        routes = try await locationVM.createRoute(selectedPlaces: selectedPlaces)
                    }catch {
                        
                    }
                }
            }
        }
    }
}
//
//#Preview {
//    AITripCreationView()
//}
