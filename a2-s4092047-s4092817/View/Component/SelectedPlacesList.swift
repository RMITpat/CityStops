//
//  SelectedPlacesList.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 10/10/2026.
//

import SwiftUI
import MapKit

/// Reorderable list of the chosen ``Trip`` stops.
///
/// Subview used in ``CreateRouteView`` to show the stops that
/// the user is making, and allow them to remove / re-order them.
///
/// Re-ordering uses up / down buttons on each row that move the stop
/// one position at a time.
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

        VStack {
            ForEach(tripCreationVM.selectedPlaces, id: \.identifier) { place in
                HStack(spacing: 8) {
                    LocationCard(location: place,
                                 selectedPlaces: $tripCreationVM.selectedPlaces,
                                 placesToRemove: placesToRemove)

                    reorderButtons(for: place)
                }
                .buttonStyle(.plain) // enforce button-only interaction
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .deleteDisabled(true) // hides the red minus
            }
        }
    }

    // MARK: - Reorder buttons

    /// Up / down buttons. Each is disabled when the stop is at the corresponding "end" of the list.
    private func reorderButtons(for place: MapItem) -> some View {
        let name = place.mkMapItem.name ?? "location"
        let isFirst = tripCreationVM.selectedPlaces.first?.identifier == place.identifier
        let isLast = tripCreationVM.selectedPlaces.last?.identifier == place.identifier

        return VStack(spacing: 0) {
            Button {
                shift(place, by: -1)
            } label: {
                Image(systemName: "chevron.up")
                    .font(.body.weight(.semibold))
                    .frame(width: 44, height: 40)
                    .contentShape(Rectangle())
            }
            .disabled(isFirst)
            .accessibilityLabel("Move \(name) up")
            .accessibilityIdentifier("move.up." + name)

            Button {
                shift(place, by: 1)
            } label: {
                Image(systemName: "chevron.down")
                    .font(.body.weight(.semibold))
                    .frame(width: 44, height: 40)
                    .contentShape(Rectangle())
            }
            .disabled(isLast)
            .accessibilityLabel("Move \(name) down")
            .accessibilityIdentifier("move.down." + name)
        }
    }

    // MARK: - Reordering

    /// Moves ``MapItem`` up or down in the location list by one position.
    private func shift(_ place: MapItem, by offset: Int) {
        let places = tripCreationVM.selectedPlaces
        guard let from = places.firstIndex(where: { $0.identifier == place.identifier }) else { return }
        let to = from + offset
        guard places.indices.contains(to) else { return }

        withAnimation {
            tripCreationVM.selectedPlaces.move(
                fromOffsets: IndexSet(integer: from),
                toOffset: offset > 0 ? to + 1 : to
            )
        }
    }
}
