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
            // TODO: Need to figure out if displaying map is suitable for interface, or take another approach
            // Map interface
//            Map (position: $locationVM.currentLocation) {
//                ForEach(selectedPlaces, id: \.self) { place in
//                    Marker(item: place)
//                        .mapItemDetailSelectionAccessory(.callout)
//                }
//            }
//            .frame(height:400)
//            .onAppear {
//                locationVM.checkLocationAuthorization()
//            }
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            switch mode {
            case .first:  NearbyLocations()
            case .second: SearchLocations()
            }
            
        // MARK: Search history
            if searchRequest.isEmpty {
                
                    VStack(alignment: .leading) {
                        Text("Recently searched:")
                            .font(.title2)
                        
                        // Past searches
                        ForEach(searchTermVM.pastSearches, id: \.id) { term in
                            HStack {
                                Image(systemName: "clock.fill")
                                Text(term.term)
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.primary)
                                    
                                Spacer()
                                Button("", systemImage: "xmark.circle.fill") {
                                    searchTermVM.delete(searchTerm: term)
                                }.font(.title3)
                            }
                            .padding()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                searchRequest = term.term
                            }
                            Divider()
                        }
                    }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // MARK: "Search" Button
            Button("Search") {
                Task {
                    do {
                        searchResults = try await locationVM.searchPlaces(searchRequest: searchRequest)
                    } catch {
                        // TODO: display errors somewhere
                    }
                }
                searchTermVM.insert(searchTerm: searchRequest)
            }
            .buttonStyle(.glassProminent)
            
            
            // MARK: Location search results
            ScrollView {
                VStack {
                    // Generate location detail cards
                    ForEach(searchResults, id: \.identifier) { result in
                        LocationCardView(location: result, selectedPlaces: $tripCreationVM.selectedPlaces)
                    }
                }
            }
            
            .padding(.horizontal, 16)
        }
        .onAppear {
            searchTermVM.fetch()
        }
        
        // MARK: "Next" Button
        .safeAreaInset(edge: .bottom) {
           
            Button("Next") {
                router.tripCreationRoute.append(TripCreationRoute.createRoute)
            }
            .controlSize(.large)
            .buttonStyle(.glassProminent)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
            .navigationTitle(Text("Select Stops"))
            .navigationSubtitle(Text("Add stops to your trip!"))
        
            // MARK: Location Search Bar
            .searchable(
                text: $searchRequest,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for a place",
            )
        }
}


#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")
    NavigationStack {
        CreateTripView()
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())
            .environment(SearchTermViewModel())
            .environment(Router())

    }
}
