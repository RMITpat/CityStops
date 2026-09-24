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
    var body: some View {
        @Bindable var locationVM = locationVM
        
        // MARK: Name input field
        VStack {
            TextField("e.g. Asian Street Food Tour", text: $locationVM.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal, 16)
        
        Spacer()
        
        // MARK: "Confirm" button
        .safeAreaInset(edge: .bottom) {
            NavigationLink(destination: TripPreferenceView()) {
                Text("Confirm")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.glassProminent)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        
        .navigationTitle(Text("Name your Trip"))
        .navigationSubtitle(Text("What would you like your trip to be called?"))
    }
}

#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")
    NavigationStack {
        TripNameView().environment(LocationViewModel(user: user))
    }
}
