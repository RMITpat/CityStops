//
//  TripPreferenceView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 21/9/2026.
//

import SwiftUI

/// Lets user choose the purpose of the ``Trip``; the preferences of locations that they intend to visit in the planned daytrip.

struct TripPreferenceView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @State var preferenceVM = PreferenceViewModel()
    let name: String

    var body: some View {
        @Bindable var locationVM = locationVM
        // MARK: - Preference List
        // TODO: - Create ViewModel for this View to store preferences for Trip model
        List {
            ForEach(preferenceVM.preferences, id: \.preference) { item in
                let isSelected = preferenceVM.isSelected(item)

                HStack {
                    // SF symbol
                    Image(systemName: item.icon)
                        .foregroundColor(isSelected ?
                                        .accentColor : .secondary)
                        .frame(width: 24)

                    // Preference name
                    Text(item.preference)
                    
                    Spacer()
                    
                    // Check circle
                    Image(systemName: isSelected ?
                          "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ?
                                        .accentColor : .gray)
                }
                // allows Spacer() content to register a tap
                .contentShape(Rectangle())
                
                // Change tap boolean when tapped
                .onTapGesture {
                    preferenceVM.toggle(item)
                }
            }
        }
        .listStyle(.plain)
        
        // Transfer preferences from the View's VM to Trip Creation VM
        .onChange(of: preferenceVM.selectedPreferences.map(\.preference)) {
            locationVM.preferences = preferenceVM.selectedPreferences.map(\.preference)
        }
        
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
        }
            // MARK: View Title
            .navigationTitle(Text("Trip Preferences"))
        // FIXME: NAV SUBTITLE BUGS THE DISPLAY MODE; MAKES IT DEFAULT TO INLINE RATHER THAN LARGE
            //.navigationSubtitle("What will be the purpose of your daytrip?")
            .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")
    NavigationStack {
        TripPreferenceView(name: "name").environment(LocationViewModel(user: user))
    }
}
