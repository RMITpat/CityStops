//
//  TripNameView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 24/9/2026.
//

import SwiftUI

/// Allows user to choose a name for the ``Trip``.
struct TripNameView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    @Environment(Router.self) var router: Router

    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var tripCreationVM = tripCreationVM
        
        // MARK: Input fields
        VStack {
            TextField("e.g. Asian Street Food Tour", text: $tripCreationVM.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
            
            TextField("e.g. A day out in the city to eat delicious Asian street food!", text: $tripCreationVM.description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
        }
        
        Spacer()
        
        // MARK: "Confirm" button
            .safeAreaInset(edge: .bottom) {
                Button("Confirm") {
                    router.tripCreationRoute.append(TripCreationRoute.preferences)
                }
                .modifier(ButtonFormat())
            }
        
        .navigationTitle(Text("Name your Trip"))
        .navigationSubtitle(Text("What would you like your trip to be called?"))
        .toolbar(.hidden, for: .tabBar)

    }

}

#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    NavigationStack {
        TripNameView()
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())
            .environment(Router())

    }
}
