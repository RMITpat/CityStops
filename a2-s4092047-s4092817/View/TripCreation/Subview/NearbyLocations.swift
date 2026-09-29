//
//  NearbyLocations.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import SwiftUI
import CoreLocation

/// Subview for ``CreateTripView`` that shows nearby, top-rated locations based on
/// user's ``Preference`` selections in ``TripPreferenceView``.
struct NearbyLocations: View {
    // MARK: View Models
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    
    // Replace with the user's real location when you have it
        var coordinate = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
        var category = "foods"   // e.g. "foods", "shops", "historic"
        var radius = 1000
        var limit = 5

        @State private var locations: [OpenTripLocation] = []
        @State private var isLoading = false
        @State private var errorMessage: String?

        private let service = OpenTripMapService()

        var body: some View {
            @Bindable var locationVM = locationVM
            @Bindable var tripCreationVM = tripCreationVM
            

                Group {
                    if isLoading {
                        ProgressView("Loading nearby places…")
                    } else if let errorMessage {
                        VStack(spacing: 12) {
                            Text(errorMessage)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Retry") { Task { await loadLocations() } }
                        }
                        .padding()
                    } else if locations.isEmpty {
                        Text("No places found nearby.")
                            .foregroundStyle(.secondary)
                    } else {
                        List(locations) { place in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.name)
                                    .font(.headline)

                                Text(String(format: "%.4f, %.4f", place.lat, place.lon))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                        .listStyle(.plain)
                    }
            }
            .task {
                await loadLocations()
            }
        }

        private func loadLocations() async {
            isLoading = true
            errorMessage = nil

            do {
                let results = try await service.fetchNearbyPointsByCategory(
                    for: coordinate,
                    radius: radius,
                    filter: category,
                    returnLimit: limit
                )
                // The API sometimes returns unnamed entries; hide them
                locations = results.filter { !$0.name.isEmpty }
            } catch {
                errorMessage = "Couldn't load places.\n\(error.localizedDescription)"
            }

            isLoading = false
        }
    }

#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")
    NavigationStack {
        NearbyLocations()
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())
    }
}
