//
//  NearbyLocations.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import SwiftUI
import CoreLocation
import MapKit

/// Subview for ``CreateTripView`` that shows nearby, relevant locations
/// based on the user's ``Preference`` selections in ``TripPreferenceView``.
struct NearbyLocations: View {

    // MARK: View Models

    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel

    var body: some View {
        @Bindable var tripCreationVM = tripCreationVM

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                ForEach(
                    tripCreationVM.selectedPreferences,
                    id: \.preference
                ) { preference in

                    NearbyLocationSegment(
                        preference: preference.preferenceSearch,
                        coordinate: locationVM.currentRegion.center,
                        selectedPlaces: $tripCreationVM.selectedPlaces
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
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
