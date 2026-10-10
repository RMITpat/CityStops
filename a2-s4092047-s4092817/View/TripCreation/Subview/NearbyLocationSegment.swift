
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
    /// The preference this view is displaying locations for
    let preference: Preference
    
    /// The coordinate used for reloading locations
    let coordinate: CLLocationCoordinate2D
        
    /// The selected places binding this View's controls will modify
    @Binding var selectedPlaces: [MapItem]
    
    /// OpenTripMapViewmodel used to access Open Trip Map API
    @Environment(OpenTripMapViewModel.self) private var otmVM
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            // MARK: Preference title
            Text(preference.preference)
                .font(.title2)
                .bold()
                .accessibilityAddTraits(.isHeader)
                .fixedSize(horizontal: false, vertical: true)
            
            if let status = otmVM.segmentLocations[preference.preference] {
                switch status {
                case .error(_):
                    // MARK: Error state
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
                    // MARK: Locations display
                    VStack(spacing: 12) {
                        if locations.isEmpty {
                            HStack(spacing: 8) {
                                Text("No places found nearby.")
                                    .foregroundStyle(.secondary)
                                    .accessibilityIdentifier("nearby.locations.empty")
                                Spacer()
                            }
                        }
                        // MARK: List of nearby locations
                        ForEach(locations, id: \.identifier) { item in
                            LocationCard(
                                location: item,
                                selectedPlaces: $selectedPlaces )
                        }
                    }
                }
            } else {
                HStack(spacing: 8) {
                    // MARK: Loading indicator
                    ProgressView()
                    Text("Loading nearby places…")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
            
            
        }
      
    }
}
