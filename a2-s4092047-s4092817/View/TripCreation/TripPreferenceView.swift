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
        // TODO: - Create ViewModel for this View to store preferences for Trip model
        List {
            ForEach(tripCreationVM.preferences, id: \.preference) { item in
                let isSelected = tripCreationVM.isSelected(item)

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
                    tripCreationVM.toggle(item)
                }
            }
        }
        .listStyle(.plain)
        
        
        // MARK: - "Next" Button
        // TODO: - Create wrapper for all bottom buttons (reusable view / wrapper)
        .safeAreaInset(edge: .bottom) {
         
            Button("Next") {
                router.tripCreationRoute.append(TripCreationRoute.createTrip)
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
        TripPreferenceView()
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())
    }
}
