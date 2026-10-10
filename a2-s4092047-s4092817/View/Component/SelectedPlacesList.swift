//
//  SelectedPlacesList.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 10/10/2026.
//

import SwiftUI

/// Reorderable list of the chosen ``Trip`` stops.
///
/// Subview used in ``CreateRouteView`` to show the stops that
/// the user is making, and allow them to remove / re-order them.
struct SelectedPlacesList: View {
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel

    /// True while the long-press gesture overlay is active (disables list interaction when interacting with custom gesture).
    /// Defaults to false for screens with no gesture overlay.
    var isScrollDisabled: Bool = false
    
    /// Places currently marked for AI replacement.
    /// Pass nil (default) for lists without replacement feature, like ``CreateRouteView``.
    var placesToRemove: Binding<[String]>? = nil

    var body: some View {
        @Bindable var tripCreationVM = tripCreationVM

        List {
            ForEach(tripCreationVM.selectedPlaces, id: \.identifier) { place in
                LocationCard(location: place,
                             selectedPlaces: $tripCreationVM.selectedPlaces,
                             placesToRemove: placesToRemove)
                .buttonStyle(.plain) // enforce button-only interaction
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .deleteDisabled(true) // hides the red minus
            }
            .onMove { source, destination in
                tripCreationVM.selectedPlaces.move(fromOffsets: source, toOffset: destination)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        // Always show the three-line handle
        .environment(\.editMode, .constant( .active))
        .scrollDisabled(isScrollDisabled)
    }
}
