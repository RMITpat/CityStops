//
//  TripFeed.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 27/9/2026.
//

import SwiftUI

///
/// A customisable and reusable TripFeed to display either the home trip feed or your created trips
struct TripFeed: View {
    
    let trips: [Trip]
    let isLoading: Bool
    @Binding var route: [FeedRoute]
    let onRefresh: () -> Void
    let loadTrips: () -> Void
    
    var showBookmark: Bool = true
    var body: some View {

        ScrollView {
            LazyVStack {
                ForEach(trips, id: \.id) { trip in
                    TripCard(trip: trip, navRoute: $route, showBookmark: showBookmark)
                    
                    Divider()
                }
                
                // Invisible element. Since LazyVStacks only load elements when necessary, when this appears it mean the user has scrolled to the bottom of the ScrollView.
                // Hence, load more trips.
                Text("")
                    .onAppear { loadTrips() }
                if (isLoading) {
                    ProgressView()
                }
                Spacer()
            }
        }
        .refreshable {
            onRefresh()
        }
    }
}
