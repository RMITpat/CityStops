//
//  CreateTripSheet.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 17/9/2026.
//

import SwiftUI
import MapKit

///
/// View for adding stops to a ``Trip``. Contains a Map and search bar through which users can search for locations by name. Results can be added as pins on the map.
/// - Uses ``LocationViewModel`` to pass stops to ``CreateRouteView``

struct CreateTripSheet: View {
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
    
    @State var mode: Mode
    
    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var tripCreationVM = tripCreationVM

        VStack {
            // MARK: View Title
            Text("Select Stops")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .background(Color(.systemBackground))
            .padding(.horizontal, 16)
            
            switch mode {
            case .first:
                NearbyLocations()
                
            case .second:
                SearchLocations()
                
            }
        
          

            
        }// Content fills the sheet and anchors to the top
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    NavigationStack {
        CreateTripSheet(mode: .first)
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())
            .environment(SearchTermViewModel())
            .environment(Router())


    }
}
