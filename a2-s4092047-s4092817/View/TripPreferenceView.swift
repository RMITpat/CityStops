//
//  TripPreferenceView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 21/9/2026.
//

import SwiftUI

/// Lets user choose the purpose of the daytrip / preferences of locations that they intend to visit in the planned daytrip.

struct TripPreferenceView: View {
    @State private var tripPreferences = preferences

    var body: some View {
        VStack {
            List {
                ForEach($tripPreferences, id: \.preference) { $item in
                    HStack {
                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isChecked ? .blue : .gray)
                            .onTapGesture {
                                item.isChecked.toggle()
                            }
                        Text(item.preference)
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
