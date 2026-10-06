////
////  LocationSegmentViewModel.swift
////  a2-s4092047-s4092817
////
////  Created by Riley Tran on 29/9/2026.
////
//import Foundation
//import MapKit
//
///// Formats ``LocationCard`` instances in ``NearbyLocationSegment``.
///// Provides values to be passed to REST API request (e.g. radius, limit of response count).
//
//@MainActor
//@Observable
//final class LocationSegmentViewModel {
//
//    // MARK: - Output states
//    private(set) var locations: [MKMapItem] = []
//    private(set) var isLoading = false
//    private(set) var errorMessage: String?
//
//    // var for checking if locations in View have loaded once; prevents multiple API calls
//    private var hasLoaded = false
//
//    // MARK: - Dependencies
//    private let converter = OpenTripMapConverter()
//    private let service = OpenTripMapServiceImpl()
//
//    // MARK: - Preset REST API query values
//    private let radius = 5000
//    private let limit = 15
//    private let maxResults = 3
//
//    /// runs API calls only if the View is pushed into the ``NavigationStack`` for the first time, to prevent duplicate calls.
//    /// This allows API responses to persist if the user backtracks into the View.
//    func loadIfNeeded(for preference: Preference,
//                      near coordinate: CLLocationCoordinate2D) async {
//        guard !hasLoaded, !isLoading else { return }
//        await loadLocations(for: preference, near: coordinate)
//    }
//
//    /// always fetches API response data; called directly by user interface when API call error occurs.
//    func loadLocations(for preference: Preference,
//                       near coordinate: CLLocationCoordinate2D) async {
//        isLoading = true
//        errorMessage = nil
//        defer { isLoading = false }
//
//        do {
//            let results = try await service.fetchNearbyPointsByCategory(
//                location: coordinate,
//                radius: radius,
//                filter: preference.preferenceSearch,
//                returnLimit: limit
//            )
//
//            var mapItems: [MKMapItem] = []
//            for place in results where !place.name.isEmpty {
//                if mapItems.count >= maxResults { break }
//
//                if let item = try? await converter.convertResponseToMapItem(response: place),
//                   !mapItems.contains(where: { $0.identifier == item.identifier }) {
//                    mapItems.append(item)
//                }
//            }
//            locations = mapItems
//            hasLoaded = true   // only mark "done" on success
//
//        } catch {
//            // .task cancels when the view disappears; don't show that as an error
//            if Task.isCancelled || (error as? URLError)?.code == .cancelled { return }
//
//            locations = []
//            errorMessage = """
//            Couldn't load places for \(preference.preference).
//            \(error.localizedDescription)
//            """
//        }
//    }
//}
