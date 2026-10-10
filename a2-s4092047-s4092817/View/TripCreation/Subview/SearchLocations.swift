//
//  SearchLocations.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import SwiftUI
import MapKit

/// Subview for ``CreateTripSheet`` that allows the user to search for locations in their
/// Trip vicinity.
struct SearchLocations: View {
    // MARK: View Models
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    @Environment(SearchTermViewModel.self) var searchTermVM: SearchTermViewModel
    
    // The place search request inputted by the user
    @State private var searchRequest: String = ""
    
    // The results of a place search
    @State private var searchResults: [MapItem]?
    
    @State private var errorMessage: String?
    
    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var tripCreationVM = tripCreationVM
        
        VStack {
            // MARK: Custom Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                TextField("Search for a place", text: $searchRequest, axis: .vertical)
                    .textFieldStyle(.plain)
                    .accessibilityAddTraits(.isSearchField)
                    .accessibilityIdentifier("search.places")
                 


                if !searchRequest.isEmpty {
                    Button {
                        searchRequest = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Clear")
                            .accessibilityHint("Clears the search bar")

                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            // MARK: "Search" Button
            Button("Search") {
                startSearch()
            }
            .modifier(ButtonFormat())
            .accessibilityIdentifier("search.button")
            .accessibilityHint("Searches for places nearby you")
            
            // MARK: Search history
            if searchRequest.isEmpty {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Recently searched:")
                            .font(.title2)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)
                        
                        // Past searches
                        ForEach(searchTermVM.pastSearches, id: \.id) { term in
                            HStack {
                                Image(systemName: "clock.fill")
                                    .accessibilityHidden(true)
                                
                                Text(term.term)
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                Button("", systemImage: "xmark.circle.fill") {
                                    searchTermVM.delete(searchTerm: term)
                                }.font(.title3)
                                    .accessibilityLabel("Remove the recently searched term, \(term.term)")
                            }
                            .padding()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                searchRequest = term.term
                                startSearch()
                            }
                            Divider()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
        
            // MARK: Search error message
            if let errorMessage  {
                Text(errorMessage).foregroundColor(.red).font(.footnote)
                    .accessibilityIdentifier("search.error")

            }
            
            // MARK: Location search results
            if let searchResults {
                if searchResults.isEmpty {
                    Text("No results")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("empty.search")
                }
                ScrollView {
                    VStack {
                        // Generate location detail cards
                        ForEach(searchResults, id: \.identifier) { result in
                            LocationCard(location: result,
                                         selectedPlaces: $tripCreationVM.selectedPlaces
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)

            }
        }
        .padding(.horizontal, 12)

        .onAppear {
            searchTermVM.fetch()
        }
        
    }
    
    
    func startSearch() {
           searchResults = nil
            errorMessage = nil
           Task {
               do {
                   searchResults = try await locationVM.searchPlaces(searchRequest: searchRequest)
               } catch {
                   errorMessage = "Failed to search for places."
               }
           }
           searchTermVM.insert(searchTerm: searchRequest)
       }

}


#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    NavigationStack {
        SearchLocations()
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())
            .environment(SearchTermViewModel())
    }
}
