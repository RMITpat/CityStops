//
//  CreateRouteView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 21/9/2026.
//

import SwiftUI
import MapKit

/// View that displays the shortest route that visits all chosen ``Trip`` stops.
/// Uses ``LocationViewModel`` to calculate route.
struct CreateRouteView: View {
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(AppViewModel.self) var appVM: AppViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    @Environment(Router.self) var router: Router
    
    @State var createRouteVM = CreateRouteViewModel()

    // Routes between selectionPlaces
    @State var routes: [MKRoute] = []
    @State var error: String?
    
    // Sheet state
    @State private var showStopsSheet = true
    
    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var tripCreationVM = tripCreationVM

        // Map interface
        Map (position: $locationVM.currentLocation) {
            ForEach(tripCreationVM.selectedPlaces, id: \.self) { place in
                Marker(item: place)
                    .mapItemDetailSelectionAccessory(.callout)
            }
            ForEach(routes, id: \.self) { route in
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
            
        }
        .frame(height:400)
        // Route between stops
        .task {
            do {
                routes = try await locationVM.createRoute(selectedPlaces: tripCreationVM.selectedPlaces)
            } catch {
                self.error = error.localizedDescription
            }

        }
        .task {
            await createRouteVM.preload(
                preferences: tripCreationVM.selectedPreferences,
                near: locationVM.currentRegion.center
            )
        }
        
        // MARK: Choose stops sheet
        .sheet(isPresented: $showStopsSheet) {
            VStack {
                CreateTripSheet(mode: tripCreationVM.selectedPreferences.isEmpty ? .second : .first)
                .padding(.top, 24)
                
                .safeAreaInset(edge: .bottom) {
                    Button("Done") {
                        showStopsSheet.toggle()
                    }
                    .modifier(ButtonFormat())
                }
            }
            .environment(createRouteVM) 
            .presentationDetents([.large])
            // Lets you pan/zoom the map while the sheet is at small/medium size
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled()
        }
        
        // MARK: Scroll View of chosen locations
        ScrollView {
             VStack {
                 ForEach(tripCreationVM.selectedPlaces, id: \.identifier) { place in
                     VStack {
                         LocationCard(location: place,
                                          selectedPlaces: $tripCreationVM.selectedPlaces)
                        
                     }
                 }
             }.padding()
         }
        Spacer()
        
        // MARK: "Open Sheet" button
        Button("Choose Locations") {
            showStopsSheet = true
        }
        
        // MARK: "Finish" button
        .safeAreaInset(edge: .bottom) {
            Button("Finish") {
                Task {
                    do {
                        try await appVM.saveTrip(name: tripCreationVM.name, description: tripCreationVM.description, selectedPlaces: tripCreationVM.selectedPlaces, preferences: tripCreationVM.selectedPreferences.map {$0.preference })
                        
                        tripCreationVM.clear()
                        router.tripCreationRoute.removeAll()
                        router.selectedTab = .create
                    } catch {
                        self.error = error.localizedDescription
                    }
                }
            }
            .disabled(appVM.isSaving)
            .modifier(ButtonFormat())
        }
        if let error {
            Text(error)
                .font(.footnote)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
        
    }
}

#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")

    NavigationStack {
        CreateRouteView()
            .environment(LocationViewModel(user: user))
            .environment(AppViewModel(user: user))
            .environment(TripCreationViewModel())
            .environment(Router())
            .environment(SearchTermViewModel())
    }
}
