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
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .font(.title3)

            
            TextField("e.g. Asian Street Food Tour", text: $tripCreationVM.name, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityIdentifier("trip.title.input")
                .fixedSize(horizontal: false, vertical: true)
            
            if let nameError = tripCreationVM.nameError {
                Text(nameError).foregroundColor(.red).font(.footnote)
            }
            
            //Description
            Text("Description")
                .font(.title2)
                .padding(.top, 32)

            Text("What is this trip about?")
                .font(.caption)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
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
                    .accessibilityLabel("Input your trip's description")
            
            // Placeholder text; fixed padding to align with TextEditor
            if tripCreationVM.description.isEmpty {
                Text("e.g. A day out in the city to eat Asian street food!")
                    .padding(.leading, 7)
                    .padding(.top, 8)
                    .allowsHitTesting(false)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(.secondary)
                    .font(.title3)
                }

            }
            if let descError = tripCreationVM.descriptionError {
                Text(descError).foregroundColor(.red).font(.footnote)
            }
        }
        .padding(.horizontal, 16)
        
        Spacer()
        
        // MARK: "Confirm" button
            .safeAreaInset(edge: .bottom) {
                Button("Confirm") {
                    if tripCreationVM.validateNameDesc() {
                        router.tripCreationRoute.append(TripCreationRoute.preferences)
                    }
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
