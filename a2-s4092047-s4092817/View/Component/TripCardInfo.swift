//
//  TripCardInfo.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import SwiftUI

/// Displays a trip's name, preferences and creator name
struct TripCardInfo: View {
    /// The trip to display information for
    let trip: Trip
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    // MARK: Trip name
                    Text(trip.name)
                        .font(.title2)
                        .bold()
                        .accessibilityIdentifier("\(trip.id).title")
                        .accessibilityAddTraits(.isHeader)
                    
                    // MARK: Trip preferences
                    Text(trip.preferences.sorted().joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .accessibilityIdentifier("\(trip.id).preferences")
                }
                Spacer()
                // MARK: Trip creator name
                Text("By \(trip.ownerUsername)")
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
