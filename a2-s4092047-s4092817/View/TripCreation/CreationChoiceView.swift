//
//  CreationChoiceView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 21/9/2026.
//

import SwiftUI

/// View that allows user to choose between manually creating a ``Trip``, or
/// use ML features to plan a ``Trip``for them.
struct CreationChoiceView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(Router.self) var router: Router

    var body: some View {
        @Bindable var locationVM = locationVM
            VStack {
                Text("How would you like to create your daytrip?")
                    .bold()
                
                Button("Plan it myself") {
                    router.tripCreationRoute.append(TripCreationRoute.name)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                
                
                Text("or")
                    .fontWeight(.light)
                
                //TODO: Implement AI / ML daytrip creation feature
                NavigationLink(destination: CreateTripView()
                ) {
                    Text("Let AI decide for me")
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                
            }
            .navigationTitle(Text("Create a Daytrip"))
            .navigationBarTitleDisplayMode(.large)
            
       

    }

        
}
#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")
    NavigationStack {
        CreationChoiceView()
            .environment(LocationViewModel(user: user))
            .environment(TripCreationViewModel())

    }
}
