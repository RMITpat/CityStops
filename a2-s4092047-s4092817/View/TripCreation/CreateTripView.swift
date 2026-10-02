//
//  CreateTripView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 17/9/2026.
//

import SwiftUI
import MapKit

///
/// View for adding stops to a ``Trip``. Contains a Map and search bar through which users can search for locations by name. Results can be added as pins on the map.
/// - Uses ``LocationViewModel`` to pass stops to ``CreateRouteView``

struct CreateTripView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    @Environment(SearchTermViewModel.self) var searchTermVM: SearchTermViewModel
    @Environment(Router.self) var router: Router

    // The place search request inputted by the user
    @State var searchRequest: String = ""
    
    // The results of a place search
    @State var searchResults: [MKMapItem] = []
    
    enum Mode: String, CaseIterable, Identifiable {
        case first = "Nearby Stops"
        case second = "Search for Stops"
        var id: Self { self }
    }
    
    @State private var mode: Mode = .first
    
    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var tripCreationVM = tripCreationVM

        VStack {

            // MARK: View Title
            Text("Select Stops")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Keep both subviews alive so their state (and loaded results) survives switching
            ZStack (alignment: .top) {

                NearbyLocations()
                    .opacity(mode == .first ? 1 : 0)
                    .allowsHitTesting(mode == .first)
                    .accessibilityHidden(mode != .first)

                SearchLocations()
                    .opacity(mode == .second ? 1 : 0)
                    .allowsHitTesting(mode == .second)
                    .accessibilityHidden(mode != .second)
            }

            // Content fills the sheet and anchors to the top
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            // Picker bar
            .safeAreaInset(edge: .top, spacing: 8) {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
            }
        }
    }
}


#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    NavigationStack {
        CreateTripView()
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())
            .environment(SearchTermViewModel())
            .environment(Router())


    }
}
