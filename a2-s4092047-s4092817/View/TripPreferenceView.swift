//
//  TripPreferenceView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 21/9/2026.
//

import SwiftUI

/// Lets user choose the purpose of the daytrip / preferences of locations that they intend to visit in the planned daytrip.

struct TripPreferenceView: View {
    // TODO: THIS IS PLACEHOLDER DATA; PROPER IMPLEMENTATION WILL BE A LIST OF "PREFERENCES" THAT IS STORED AS PART OF "DAYTRIP" MODEL
    @State private var items: [ChecklistItem] = [
        ChecklistItem(title: "Choose locations for a daytrip plan"),
        ChecklistItem(title: "Add stops to a route"),
        ChecklistItem(title: "Share itinerary with friends")
    ]

    var body: some View {
        VStack {
            List {
                ForEach($items) { $item in
                    HStack {
                        Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                            .foregroundColor(item.isChecked ? .blue : .gray)
                            .onTapGesture {
                                item.isChecked.toggle()
                            }
                        Text(item.title)
                            .strikethrough(item.isChecked)
                    }
                }
            }
            NavigationLink(destination: CreateTripView()) {
                Text("Next")
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            
            .navigationTitle(Text("Trip Preferences"))
            .navigationSubtitle(Text("What is the purpose of your daytrip?"))
        }
    }
}

// TODO: PLACEHOLDER FOR CHECKING FUNCTIONALITY
struct ChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    var isChecked: Bool = false
}


//
//
//
#Preview {
    NavigationStack {
        TripPreferenceView()
    }
}
