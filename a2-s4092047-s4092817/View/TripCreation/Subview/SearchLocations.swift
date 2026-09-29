//
//  SearchLocations.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import SwiftUI
import MapKit

struct SearchLocations: View {
    // MARK: View Models
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    @Environment(SearchTermViewModel.self) var searchTermVM: SearchTermViewModel
    
    // The place search request inputted by the user
    @State var searchRequest: String = ""
    
    // The results of a place search
    @State var searchResults: [MKMapItem] = []
    
    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var tripCreationVM = tripCreationVM
        
        VStack {
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
        SearchLocations()
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())
            .environment(SearchTermViewModel())
    }
}
