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
    @State var searchRequest: String = ""
    
    // The results of a place search
    @State var searchResults: [MKMapItem] = []
    
    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var tripCreationVM = tripCreationVM
        
        VStack {
            // MARK: Custom Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search for a place", text: $searchRequest)
                    .textFieldStyle(.plain)

                if !searchRequest.isEmpty {
                    Button {
                        searchRequest = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
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
                            startSearch()
                        }
                        Divider()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // MARK: "Search" Button
            Button("Search") {
                startSearch()
            }
            .buttonStyle(.glassProminent)
            
            // MARK: Location search results
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
        .padding(.horizontal, 12)

        .onAppear {
            searchTermVM.fetch()
        }
        

//        // MARK: Location Search Bar
//        .searchable(
//            text: $searchRequest,
//            placement: .automatic,
//            prompt: "Search for a place",
//        )
    }
    
    
    func startSearch() {
           searchResults.removeAll()
           Task {
               do {
                   searchResults = try await locationVM.searchPlaces(searchRequest: searchRequest)
               } catch {
                   // TODO: display errors somewhere
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
