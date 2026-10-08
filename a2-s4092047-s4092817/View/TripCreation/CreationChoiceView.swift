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
    @Environment(ViewModelFactory.self) var vmFactory: ViewModelFactory
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(Router.self) var router: Router
    @State var tripCreationVM: TripCreationViewModel = TripCreationViewModel()

    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var router = router

        NavigationStack(path: $router.tripCreationRoute) {
            
            VStack {
                Text("How would you like to create your daytrip?")
                    .bold()
                
                Button("Plan it myself") {
                    tripCreationVM.clear()
                    router.tripCreationRoute.append(TripCreationRoute.name)
                }
                .accessibilityIdentifier("plan.myself")
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                
                Text("or")
                    .fontWeight(.light)
                
                
                Button("Ask Dora to assist") {
                    tripCreationVM.clear()
                    router.tripCreationRoute.append(TripCreationRoute.preferences)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .tint(.dora)
                
            }
            .onAppear {
                locationVM.checkLocationAuthorization()
            }
            .navigationTitle(Text("Create a Daytrip"))
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: TripCreationRoute.self) { route in
            switch route {
                case .name: TripNameView()
                case .preferences: TripPreferenceView()
                case .createRoute: CreateRouteView(vmFactory: vmFactory)
            case .aiTripCreation: AITripCreationView(region: locationVM.currentRegion, vmFactory: vmFactory)
            }
        }
        }
        .environment(tripCreationVM)

       

    }

        
}
#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    NavigationStack {
        CreationChoiceView()
            .environment(LocationViewModel(user: user))
            .environment(Router())
            .environment(ViewModelFactory())

    }
}
