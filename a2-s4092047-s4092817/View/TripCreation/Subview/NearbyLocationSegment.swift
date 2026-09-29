
//
//  NearbyLocationSegment.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import SwiftUI
import MapKit

/// Displays nearby locations for one preference.
struct NearbyLocationSegment: View {

    let preference: String
    let coordinate: CLLocationCoordinate2D

    @Binding var selectedPlaces: [MKMapItem]

    private let converter = OpenTripMapConverter()
    private let service = OpenTripMapService()

    private let radius = 3000
    private let limit = 10
    private let maxResults = 5

    @State private var locations: [MKMapItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(preference)
                .font(.title2)
                .bold()

            if isLoading {
                ProgressView("Loading nearby places…")
                    .frame(maxWidth: .infinity, alignment: .leading)

            } else if let errorMessage {
                VStack(alignment: .leading, spacing: 12) {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)

                    Button("Retry") {
                        Task {
                            await loadLocations()
                        }
                    }
                }

            } else if locations.isEmpty {
                Text("No places found nearby.")
                    .foregroundStyle(.secondary)

            } else {
                VStack(spacing: 12) {
                    ForEach(locations, id: \.identifier) { item in
                        LocationCardView(
                            location: item,
                            selectedPlaces: $selectedPlaces
                        )
                    }
                }
            }
        }
        .task {
            await loadLocations()
        }
    }

    // TODO: Move to ViewModel
    private func loadLocations() async {
        isLoading = true
        errorMessage = nil

        do {
            // Make a separate API request for this preference
            let results = try await service.fetchNearbyPointsByCategory(
                for: coordinate,
                radius: radius,
                filter: preference,
                returnLimit: limit
            )

            var mapItems: [MKMapItem] = []

            for place in results where !place.name.isEmpty {

                // Stop once we have enough results
                if mapItems.count >= maxResults {
                    break
                }

                // Convert the API result into an MKMapItem
                if let item = try? await converter
                    .convertResponseToMapItem(response: place),
                   !mapItems.contains(where: {
                       $0.identifier == item.identifier
                   }) {
                    mapItems.append(item)
                }
            }

            locations = mapItems

        } catch {
            errorMessage = """
            Couldn't load places for \(preference).
            \(error.localizedDescription)
            """
        }

        isLoading = false
    }
}
