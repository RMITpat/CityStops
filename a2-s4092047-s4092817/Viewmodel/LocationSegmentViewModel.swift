//
//  LocationSegmentViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//
import Foundation
import MapKit

/// Formats ``LocationCardView`` instances in ``NearbyLocationSegment``.
/// Provides values to be passed to REST API request (e.g. radius, limit of response count).

@MainActor
@Observable
final class LocationSegmentViewModel {

    // MARK: - Output states
    private(set) var locations: [MKMapItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let converter = OpenTripMapConverter()
    private let service = OpenTripMapService()

    // MARK: - Set REST API query values
    private let radius = 5000
    private let limit = 15
    private let maxResults = 3

    /// load OpenMapTrip API repsonse locations as ``MKMapItem``, if they exist in Apple's Map database.
    func loadLocations(for preference: Preference,
                       near coordinate: CLLocationCoordinate2D) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // fetch OpenMapTripAPI results
        do {
            let results = try await service.fetchNearbyPointsByCategory(
                location: coordinate,
                radius: radius,
                filter: preference.preferenceSearch,
                returnLimit: limit
            )

            // attempt to convert API results into MKMapItems, if they exist in Apple's database
            var mapItems: [MKMapItem] = []
            for place in results where !place.name.isEmpty {
                if mapItems.count >= maxResults { break }

                if let item = try? await converter.convertResponseToMapItem(response: place),
                   !mapItems.contains(where: { $0.identifier == item.identifier }) {
                    mapItems.append(item)
                }
            }
            locations = mapItems
            
            // if no locations for a preference are found, show error
        } catch {
            locations = []
            errorMessage = """
            Couldn't load places for \(preference.preference).
            \(error.localizedDescription)
            """
        }
    }
}
