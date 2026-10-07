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
        VStack (alignment: .leading) {
            // Title
            Text("Title")
                .font(.title2)
            Text("What would you like your trip to be called?")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("e.g. Asian Street Food Tour", text: $tripCreationVM.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 32)
                .accessibilityIdentifier("trip.title.input")
            
            //Description
            Text("Description")
                .font(.title2)
            Text("What is this trip about?")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $tripCreationVM.description)
                    .frame(minHeight: 120)
                    .padding(.horizontal, 2)
                    .scrollContentBackground(.hidden)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary.opacity(0.15))
                    }
                    .accessibilityIdentifier("trip.description.input")
            
            // Placeholder text; fixed padding to align with TextEditor
            if tripCreationVM.description.isEmpty {
                Text("e.g. A day out in the city to eat Asian street food!")
                    .foregroundStyle(.opacity(0.25))
                    .padding(.leading, 7)
                    .padding(.top, 8)
                    .allowsHitTesting(false)
                }
            }
        }
        .padding(.horizontal, 16)
        
        Spacer()
        
        // MARK: "Confirm" button
            .safeAreaInset(edge: .bottom) {
                Button("Confirm") {
                    router.tripCreationRoute.append(TripCreationRoute.preferences)
                }
                .modifier(ButtonFormat())
                .accessibilityIdentifier("confirm.trip.details")
            }
        
        .navigationTitle(Text("Trip Details"))
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
