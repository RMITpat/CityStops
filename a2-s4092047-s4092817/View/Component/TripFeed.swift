//
//  TripFeed.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 27/9/2026.
//

import SwiftUI

///
/// A customisable and reusable TripFeed to display a feed of trips
struct TripFeed: View {
    /// Trips to display
    let trips: [Trip]
    
    /// Whether the trips are loading
    let isLoading: Bool
    
    /// The route to navigate back to
    @Binding var route: [FeedRoute]
    
    /// What method to call when the user refreshes
    let onRefresh: () -> Void
    
    /// What method to call when the user loads more trips with pagination
    let loadTrips: () -> Void
    
    var body: some View {

        ScrollView {
            LazyVStack {
                
                ForEach(trips, id: \.id) { trip in
                    // MARK: Trip card
                    TripCard(trip: trip, navRoute: $route)
                    
                    Divider()
                }
                
                // Invisible element. Since LazyVStacks only load elements when necessary, when this appears it mean the user has scrolled to the bottom of the ScrollView.
                // Hence, load more trips.
                Text("")
                    .onAppear { loadTrips() }
                
                if (isLoading) {
                    // MARK: Loading indicator
                    ProgressView()
                }
                Spacer()
            }
        }
        // MARK: On refresh
        .refreshable {
            onRefresh()
        }
    }
}
