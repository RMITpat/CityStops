//
//  NearbyLocations.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import SwiftUI
import CoreLocation
import MapKit

/// Subview for ``CreateTripView`` that shows nearby, relevant locations based on
/// user's ``Preference`` selections in ``TripPreferenceView``.
struct NearbyLocations: View {
    // MARK: View Models
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    
    private let converter = OpenTripMapConverter()
    private let service = OpenTripMapService()
    
    // TODO: Replace with the user's real location
        var coordinate = CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
        var category = "restaurants"
        var radius = 3000
        var limit = 20

    // States for View
    @State private var locations: [MKMapItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

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
                        ScrollView {
                            VStack {
                                ForEach(locations, id: \.identifier) { item in
                                    LocationCardView(
                                        location: item,
                                        selectedPlaces: $tripCreationVM.selectedPlaces
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
            }
            .task {
                await loadLocations()
            }
        }

    // TODO: Move to ViewModel
    private func loadLocations() async {
        let maxResults = 5
            isLoading = true
            errorMessage = nil
            
            do {
                let results = try await service.fetchNearbyPointsByCategory(
                    for: coordinate,
                    radius: radius,
                    filter: category,
                    returnLimit: limit
                )
                
                var mapItems: [MKMapItem] = []
                for place in results where !place.name.isEmpty {
                    // Stop once we have enough
                    if mapItems.count >= maxResults { break }
                    
                    // try? so one failed lookup doesn't discard the others
                    if let item = try? await converter.convertResponseToMapItem(response: place),
                       !mapItems.contains(where: { $0.identifier == item.identifier }) {
                        mapItems.append(item)
                    }
                }
                locations = mapItems
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
