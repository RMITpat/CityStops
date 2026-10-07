//
//  TripCardInfo.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import SwiftUI

struct TripCardInfo: View {
    let trip: Trip
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(trip.name)
                        .font(.title2)
                        .bold()
                        .accessibilityIdentifier("\(trip.id).title")
                    Text(trip.preferences.sorted().joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .accessibilityIdentifier("\(trip.id).preferences")
                }
                Spacer()
                Text("By \(trip.ownerUsername)")
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
