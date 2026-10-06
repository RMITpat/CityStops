//
//  NearbyLocations.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import SwiftUI
import CoreLocation
import MapKit

/// Subview for ``CreateTripSheet`` that shows nearby, relevant locations
/// based on the user's ``Preference`` selections in ``TripPreferenceView``.
struct NearbyLocations: View {

    // MARK: View Models
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel

    var body: some View {
        @Bindable var tripCreationVM = tripCreationVM

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if tripCreationVM.selectedPreferences.isEmpty {
                    Text("Select preferences for your trip to see nearby locations")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    
                }
                // show List of nearby locations for each preference selected from
                // ``TripPreferenceView``
                ForEach(
                    tripCreationVM.selectedPreferences,
                    id: \.preference
                ) { preference in
                    
                    NearbyLocationSegment(
                        preference: preference,
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
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    NavigationStack {
        NearbyLocations()
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())
    }
}
