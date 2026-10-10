//
//  RouteMapSection.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 10/10/2026.
//

import SwiftUI
import MapKit

/// Map showing the chosen ``Trip`` stops and the routes between them.
/// Subview used in ``CreateRouteView`` to display the route and stops that
/// the user is making.
struct RouteMapSection: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel

    /// True while the long-press gesture overlay is active (disables map interaction when interacting with custom gesture).
    let isGestureActive: Bool

    /// Routes between selectedPlaces.
    @State private var routes: [MKRoute] = []

    var body: some View {
        UIKitMapView(
            position: locationVM.currentLocation,
            places: tripCreationVM.selectedPlaces.map({$0.mkMapItem}),
            routes: routes,
            showsUserLocation: true,
            isPinSelectable: true,
            interactionModes: isGestureActive ? [] : .all
        )
        // Re-runs whenever the places change and/or are reordered.
        // The previous calculation is cancelled
        // automatically if the places change again, and it also runs on appear.
        .task(id: tripCreationVM.selectedPlaces) {
            // try? leaves the existing routes in place if the task is
            // cancelled or the calculation fails.
            if let newRoutes = try? await locationVM.createTripRoutes(
                selectedPlaces: tripCreationVM.selectedPlaces
            ) {
                routes = newRoutes
            }
        }
    }
}
