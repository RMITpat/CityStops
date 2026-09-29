
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
                ProgressView("Loading nearby places…")
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let errorMessage = segmentVM.errorMessage {
                VStack(alignment: .leading, spacing: 12) {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                    Button("Retry") {
                        Task { await load() }
                    }
                }
            } else if segmentVM.locations.isEmpty {
                Text("No places found nearby.")
                    .foregroundStyle(.secondary)
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
        .task { await load() }
    }

    private func load() async {
        await segmentVM.loadLocations(for: preference, near: coordinate)
    }
}
