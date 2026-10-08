
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
        
    @Binding var selectedPlaces: [MapItem]
    
    // MARK: View Models
    @Environment(OpenTripMapViewModel.self) private var otmVM
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            // Preference title
            Text(preference.preference)
                .font(.title2)
                .bold()
            
            if let status = otmVM.segmentLocations[preference.preference] {
                switch status {
                case .error(let error):
                    HStack(spacing: 8) {
                        Text("Couldn't load places for \(preference.preference).")
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("nearby.locations.error")
                    
                        Button("Retry") {
                            Task {
                                await otmVM.loadLocations(for: preference, near: coordinate)
                            }
                        }
                        .accessibilityIdentifier("nearby.locations.retry")
                        .accessibilityLabel("Attempt fetching nearby locations again")
                        Spacer()
                    }
                case .success(let locations):
                    VStack(spacing: 12) {
                        if locations.isEmpty {
                            HStack(spacing: 8) {
                                Text("No places found nearby.")
                                    .foregroundStyle(.secondary)
                                    .accessibilityIdentifier("nearby.locations.empty")
                                Spacer()
                            }
                        }
                        // List of nearby locations
                        ForEach(locations, id: \.identifier) { item in
                            LocationCard(
                                location: item,
                                selectedPlaces: $selectedPlaces )
                        }
                    }
                }
            } else {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading nearby places…")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
            
            
        }
      
    }
}
