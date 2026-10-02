//
//  SaveTripButton.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import SwiftUI

struct SaveTripButton: View {
    @Environment(AppViewModel.self) var appVM: AppViewModel
    let trip: Trip
    
    var body: some View {
        Button(trip.savedByUser ? "Saved" : "Save", systemImage: trip.savedByUser ? "bookmark.fill" : "bookmark") {
            Task {
                do {
                    if trip.savedByUser {
                        try await appVM.deleteTripBookmark(tripId: trip.id)

                    } else {
                        try await appVM.bookmarkTrip(tripId: trip.id)

                    }
                } catch {
                    
                }
            }

        }.font(.title2)
    }
}

