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
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    @Environment(Router.self) var router: Router

    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var tripCreationVM = tripCreationVM
        // MARK: - Preference List
        List {
            ForEach(tripCreationVM.preferences, id: \.preference) { item in
                let isSelected = tripCreationVM.isSelected(item)

                HStack {
                    // SF symbol
                    Image(systemName: item.icon)
                        .foregroundColor(isSelected ?
                                        .accentColor : .secondary)
                        .frame(width: 24)
                        .accessibilityHidden(true)

                    // Preference name
                    Text(item.preference)
                        .accessibilityIdentifier(item.preference + ".label")
                        
                    
                    Spacer()
                    
                    // Check circle
                    Image(systemName: isSelected ?
                          "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ?
                                        .accentColor : .gray)
                        .accessibilityLabel(isSelected ? "Preference selected" : "Select preference")
                        
                }
                // allows Spacer() content to register a tap
                .contentShape(Rectangle())
                
                // Change tap boolean when tapped
                .onTapGesture {
                    tripCreationVM.toggle(item)
                }
            }
        }
        .listStyle(.plain)
        
        
        // MARK: - "Next" Button

        .safeAreaInset(edge: .bottom) {
                Button("Next") {
                    
                    if router.tripCreationRoute.contains(TripCreationRoute.name) {
                        router.tripCreationRoute.append(TripCreationRoute.createRoute)
                    } else {
                        router.tripCreationRoute.append(TripCreationRoute.aiTripCreation)
                    }
                }
                .modifier(ButtonFormat())
                .accessibilityIdentifier("preferences.next")
            }
        
            // MARK: View Title
            .navigationTitle(Text("Trip Preferences"))

            //.navigationSubtitle("What will be the purpose of your daytrip?")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(.hidden, for: .tabBar)

    }
}

#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    NavigationStack {
        TripPreferenceView()
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())
            .environment(Router())
    }
}
