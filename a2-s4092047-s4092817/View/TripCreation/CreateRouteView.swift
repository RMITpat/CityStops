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
    
    @State var otmVM: OpenTripMapViewModel
    
    init(vmFactory: ViewModelFactory) {
        _otmVM = State(initialValue: vmFactory.createOpenTripMapViewModel())
    }
    
    // Routes between selectionPlaces
    @State var routes: [MKRoute] = []
    @State var error: String?
    
    // Sheet state
    @State private var showStopsSheet = true
    
    // Gesture states
    @State private var gestureVM = GestureViewModel()
    @GestureState private var gestureState = ComplexGestureState.inactive
    
    
    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var tripCreationVM = tripCreationVM
        
        ZStack {
            // Ensures overlay appear / disappear covers entire screen
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // MARK: - Base View
            ScrollView {
                
                VStack {
                    
                    // MARK: Map interface - UIKit
                    UIKitMapView(
                        position: locationVM.currentLocation,
                        places: tripCreationVM.selectedPlaces.map({$0.mkMapItem}),
                        routes: routes,
                        showsUserLocation: true,
                        isPinSelectable: true,
                        interactionModes: gestureState.isLongPressComplete ? [] : .all
                    )
                    .accessibilityHidden(true)
                    .frame(height:400)
                    // Route between stops
                    .task {
                        await otmVM.generateSegments(
                            preferences: tripCreationVM.selectedPreferences,
                            coordinate: locationVM.currentRegion.center
                        )
                    }
                    .onChange(of: tripCreationVM.selectedPlaces) {
                        Task {
                            routes = try await locationVM.createTripRoutes(selectedPlaces: tripCreationVM.selectedPlaces)
                        }
                    }
                    .accessibilityLabel("Map of your route")
                    
                    // MARK: Choose stops sheet
                    .sheet(isPresented: $showStopsSheet) {
                        VStack {
                            CreateTripSheet(mode: tripCreationVM.selectedPreferences.isEmpty ? .second : .first)
                                .padding(.top, 24)
                                .environment(otmVM)
                            Button("Done") {
                                showStopsSheet.toggle()
                            }
                            .buttonStyle(.borderedProminent)
                            .font(.title2)
                            .controlSize(.large)
                            .accessibilityIdentifier("done.button")
                        }
                        .presentationDetents([.large])
                        // Lets you pan/zoom the map while the sheet is at small/medium size
                        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                        .presentationDragIndicator(.visible)
                    }
                    
                    // MARK: Scroll View of chosen locations
                    Text("Long press for edit trip options")
                        .font(.caption)
                        .foregroundStyle(.gray).fixedSize(horizontal: false, vertical: true)
                    VStack {
                        ForEach(tripCreationVM.selectedPlaces, id: \.identifier) { place in
                            VStack {
                                LocationCard(location: place,
                                             selectedPlaces: $tripCreationVM.selectedPlaces)
                                
                            }
                        }
                    }
                    .padding()
                }
                // prevent scrolling when long press is active
                .scrollDisabled(gestureState.isLongPressComplete)
                Spacer()
            }
               
                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
                
            
            
            // MARK: - Gesture Overlay
            if gestureState.isLongPressComplete {
                GestureOverlay(vm: gestureVM)
            }
        }
        // fade in when appearing
        .animation(.easeInOut(duration: 0.3), value: gestureState.isLongPressComplete)
        .contentShape(Rectangle())
        .simultaneousGesture(longPressThenDrag)
        .navigationTitle(Text(tripCreationVM.name))
        .task {
            // left swipe: cancel trip creation
            // right swipe: clear all locations from list
            gestureVM.onSuccessfulSwipe = { direction in
                switch direction {
                case .left:
                    router.tripCreationRoute.removeAll()

                case .right:
                    tripCreationVM.selectedPlaces.removeAll()
                }
            }
        }
        // MARK: "Open Sheet" button
        Button {
            showStopsSheet = true
        } label: {
            Text("Choose Locations")
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .accessibilityIdentifier("choose.locations")
        
        // MARK: "Finish" button
        .safeAreaInset(edge: .bottom) {
            Button("Finish") {
                Task {
                    do {
                        try await appVM.saveTrip(name: tripCreationVM.name, description: tripCreationVM.description, selectedPlaces: tripCreationVM.selectedPlaces, preferences: tripCreationVM.selectedPreferences.map {$0.preference })
                        
                        tripCreationVM.clear()
                        router.tripCreationRoute.removeAll()
                        appVM.refreshFeed()
                        appVM.refreshUserTrips()
                        router.selectedTab = .home
                        
                    } catch {
                        self.error = error.localizedDescription
                    }
                }
            }
            .accessibilityIdentifier("finish.button")
            .disabled(appVM.isSaving)
            .modifier(ButtonFormat())
        }
        
        }

    
    // MARK: Gesture definition
    private var longPressThenDrag: some Gesture {
        LongPressGesture(minimumDuration: gestureVM.longPressDuration)
            .sequenced(before: DragGesture(minimumDistance: 10))
            
            // Detect the gesture state (pressing, dragging)
            .updating($gestureState) { value, state, _ in
                switch value {
                    case .first(true):
                        state = .pressing
                    case .second(true, let drag):
                        state = .dragging(translation: drag?.translation ?? .zero)
                    default:
                        break
                }
            }
        
            // Update swiping translation to gestureVM
            .onChanged { value in
                if case .second(true, let drag?) = value {
                    gestureVM.updateDragDirection(translation: drag.translation)
                }
            }
            .onEnded { _ in
                gestureVM.endGesture()
            }
    }

}


#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")

    NavigationStack {
        CreateRouteView(vmFactory: ViewModelFactory())
            .environment(LocationViewModel(user: user))
            .environment(AppViewModel(user: user))
            .environment(TripCreationViewModel())
            .environment(Router())
            .environment(SearchTermViewModel())
    }
}
