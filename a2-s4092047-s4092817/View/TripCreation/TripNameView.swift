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
        // MARK: Name input field
        
        VStack {
            TextField("e.g. Asian Street Food Tour", text: $tripCreationVM.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal, 16)
        
        Spacer()
        
        // MARK: "Confirm" button
        .safeAreaInset(edge: .bottom) {
            
            Button("Confirm") {
                router.tripCreationRoute.append(TripCreationRoute.preferences)
            }
            .controlSize(.large)
            .buttonStyle(.glassProminent)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        
        .navigationTitle(Text("Name your Trip"))
        .navigationSubtitle(Text("What would you like your trip to be called?"))
        .toolbar(.hidden, for: .tabBar)

    }

}

#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")
    NavigationStack {
        TripNameView()
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())
            .environment(Router())

    }
}
