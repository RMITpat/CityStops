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
        VStack (alignment: .leading) {
            Text("What is the purpose of your daytrip?")
                .font(.footnote)
                .padding(.horizontal, 16)

            // List of Preference options
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
            .listStyle(.plain)
            .safeAreaInset(edge: .bottom) {
                NavigationLink(destination: CreateTripView()) {
                    Text("Next")
                }
                .frame(maxWidth: .infinity)
                .controlSize(.large)
                .buttonStyle(.glassProminent)
                .padding(.vertical, 16)
            }
            .navigationTitle(Text("Trip Preferences"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

//
//
//
#Preview {
    NavigationStack {
        TripPreferenceView()
    }
}
