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
        // MARK: - Preference List
        // TODO: - Create ViewModel for this View to store preferences for Trip model
        List {
            ForEach($tripPreferences, id: \.preference) { $item in
                HStack {
                    // SF symbol
                    Image(systemName: item.icon)
                        .foregroundColor(item.isChecked ?
                                        .accentColor : .secondary)
                        .frame(width: 24)

                    // Preference name
                    Text(item.preference)
                    
                    Spacer()
                    
                    // Check circle
                    Image(systemName: item.isChecked ?
                          "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isChecked ?
                                        .accentColor : .gray)
                }
                // Change tap boolean when tapped
                .onTapGesture {
                    item.isChecked.toggle()
                }
            }
        }
        .listStyle(.plain)
        
        // MARK: - "Next" Button
        // TODO: - Create wrapper for all bottom buttons (reusable view / wrapper)
        .safeAreaInset(edge: .bottom) {
            NavigationLink(destination: CreateTripView()) {
                Text("Next")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.glassProminent)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .background(.bar)
        }
            // MARK: View Title
            .navigationTitle(Text("Trip Preferences"))
        // FIXME: NAV SUBTITLE BUGS THE DISPLAY MODE; MAKES IT DEFAULT TO INLINE RATHER THAN LARGE
            //.navigationSubtitle("What will be the purpose of your daytrip?")
            .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        TripPreferenceView()
    }
}
