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
    /// LocationViewModel for accessing MapKit methods
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    
    /// App viewmodel for interacting with Firebase
    @Environment(AppViewModel.self) var appVM: AppViewModel
    
    /// TripCreationViewModel for holding trip creation state and helper methods
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    
    /// Router for view navigation
    @Environment(Router.self) var router: Router
    
    /// OpenTripMapViewModel for accessing Open Trip Map API
    @State var otmVM: OpenTripMapViewModel
    
    init(vmFactory: ViewModelFactory) {
        _otmVM = State(initialValue: vmFactory.createOpenTripMapViewModel())
    }
    
    /// Error message
    @State var error: String?
    
    /// Sheet state
    @State private var showStopsSheet = true
    
    /// Gesture state
    @State private var gestureVM = GestureViewModel()
    /// Gesture state
    @GestureState private var gestureState = ComplexGestureState.inactive
    
    
    var body: some View {
        @Bindable var locationVM = locationVM
        @Bindable var tripCreationVM = tripCreationVM
        
        ZStack {
            // Ensures overlay appear / disappear covers entire screen
            Color(.systemBackground)
                .ignoresSafeArea()
            ScrollView {
            // MARK: - Base View
                VStack {
                    
                    // MARK: Map interface - UIKit
                    RouteMapSection(isGestureActive: gestureState.isLongPressComplete)
                    
                    // MARK: Gesture trigger
                    // Gesture only triggers if it happens over the map.
                    // Implemented to prevent clashes with List gestures.
                        .simultaneousGesture(longPressThenDrag)
                        .accessibilityHidden(true)
                        .frame(height:375)
                    // Route between stops
                        .task {
                            await otmVM.generateSegments(
                                preferences: tripCreationVM.selectedPreferences,
                                coordinate: locationVM.currentRegion.center
                            )
                        }
                        .accessibilityLabel("Map of your route")
                    
                    // MARK: Gesture instruction
                    Text("Long press map for edit trip options")
                        .font(.caption)
                        .foregroundStyle(.gray).fixedSize(horizontal: false, vertical: true)
                    
                    // MARK: List of chosen locations
                    SelectedPlacesList(isScrollDisabled: gestureState.isLongPressComplete)
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
                }
                
            // MARK: error message
                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
                
        }
        .contentShape(Rectangle())
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
                .accessibilitySortPriority(2)
                
            }
            .presentationDetents([.large])
            // Lets you pan/zoom the map while the sheet is at small/medium size
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .presentationDragIndicator(.visible)
        }
        
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
            .accessibilityHint("Save this trip and return to the home feed")
            .disabled(appVM.isSaving)
            .modifier(ButtonFormat())
        }
        
        // MARK: - Gesture Overlay
        // Applied last so it wraps both the content and the safe area inset
        .overlay {
            if gestureState.isLongPressComplete {
                GestureOverlay(vm: gestureVM)
                    .ignoresSafeArea()
            }
        }
        // fade in when appearing
        .animation(.easeInOut(duration: 0.3), value: gestureState.isLongPressComplete)
        
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
