
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
    
    @Binding var selectedPlaces: [MKMapItem]
    
    // MARK: View Models
    @State private var segmentVM = LocationSegmentViewModel()

    var body: some View {
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
            } else if let errorMessage = segmentVM.errorMessage {
                HStack(spacing: 8) {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                    Button("Retry") {
                        Task { await segmentVM.loadLocations(for: preference, near: coordinate) }
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
                        LocationCardView(
                            location: item,
                            selectedPlaces: $selectedPlaces
                        )
                    }
                }
            }
        }
        .task { await segmentVM.loadIfNeeded(for: preference, near: coordinate) }
    }
}
