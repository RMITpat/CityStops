
//
//  NearbyLocationSegment.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import SwiftUI
import MapKit

/// Displays nearby locations for one``Preference``.
/// Uses ``LocationSegmentViewModel`` to facilitate parsing + display
/// of REST API responses.
struct NearbyLocationSegment: View {
    let preference: Preference
    let coordinate: CLLocationCoordinate2D
    
    @State private var locations: [MKMapItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Binding var selectedPlaces: [MKMapItem]
    
    // MARK: View Models
    @Environment(CreateRouteViewModel.self) private var createRouteVM
    @Environment(OpenTripMapViewModel.self) private var otmVM
    
    var body: some View {
        let segmentVM = createRouteVM.segmentVM(for: preference)
        
        VStack(alignment: .leading, spacing: 12) {
            // Preference title
            Text(preference.preference)
                .font(.title2)
                .bold()
            
            // Loading interface / error state message
            if segmentVM.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading nearby places…")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            } else if let errorMessage {
                HStack(spacing: 8) {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                
                    Button("Retry") {
                        Task {
                            
                            do {
                                isLoading = true
                                locations = try await otmVM.loadLocations(for: preference, near: coordinate)
                            } catch {
                                self.errorMessage = """
                                Couldn't load places for \(preference.preference).
                                \(error.localizedDescription)
                                """
                            }
                            isLoading = false
                        }
                    }
                    Spacer()
                }
            } else if segmentVM.locations.isEmpty {
                HStack(spacing: 8) {
                    Text("No places found nearby.")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                VStack(spacing: 12) {
                    
                    // List of nearby locations
                    ForEach(segmentVM.locations, id: \.identifier) { item in
                        LocationCard(
                            location: item,
                            selectedPlaces: $selectedPlaces )
                        
                    }
                }
            }
        }
        // Safety net: no-ops if the root view's preload already loaded this preference
        .task { await segmentVM.loadIfNeeded(for: preference, near: coordinate) }
    }
}
