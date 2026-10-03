//
//  AITripOverview.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 2/10/2026.
//

import SwiftUI
import MapKit

/// The created AI Trip, with  buttons for editing and adding to the created trip
struct AITripOverview: View {
    @Environment(GeminiViewModel.self) var geminiVM: GeminiViewModel
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    @Environment(AppViewModel.self) var appVM: AppViewModel

    @Environment(Router.self) var router: Router

    @Binding var routes: [MKRoute]

    @State private var mode: Mode = .first

    @State private var error: String?
    enum Mode: String, CaseIterable, Identifiable {
        case first = "Details"
        case second = "Places"
        var id: Self { self }
    }
    
    var body: some View {
        @Bindable var locationVM = locationVM

        @Bindable var tripCreationVM = tripCreationVM
        @Bindable var geminiVM = geminiVM
        ScrollView {
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
            .frame(height: 390)
            
            if geminiVM.isLoading {
                ProgressView("Tweaking trip...")
                    .progressViewStyle(.circular)
                    .scaleEffect(1.3)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
                
            } else {
                VStack {
                    Picker("Mode", selection: $mode) {
                        ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    
                    switch mode {
                    case .first:
                        VStack(alignment: .leading) {
                            Text(tripCreationVM.name).font(.title)
                            Text(tripCreationVM.description).font(.default)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        
                    case .second:
                        HStack {
                            Button("Replace selected spots") {
                                Task {
                                    do {
                                        try await tripCreationVM.fromAIResult(result: geminiVM.editTrip())
                                        self.error?.removeAll()
                                        
                                        routes = try await locationVM.createRoute(selectedPlaces: tripCreationVM.selectedPlaces)
                                    } catch {
                                        self.error = "Failed to regenerate stops"
                                    }
                                }
                                
                            }
                            .disabled(geminiVM.placesToRemove.isEmpty || geminiVM.isLoading)
                            .buttonStyle(.glassProminent)
                            .tint(.dora)
                            
                            Button("Add more spots") {
                                Task {
                                    do {
                                        self.error?.removeAll()
                                        
                                        try await tripCreationVM.fromAIResult(result: geminiVM.addStops())
                                        
                                        routes = try await locationVM.createRoute(selectedPlaces: tripCreationVM.selectedPlaces)
                                    } catch {
                                        self.error = "Failed to add more stops"
                                    }
                                }
                                
                            }
                            .disabled(geminiVM.isLoading)
                            .buttonStyle(.glassProminent)
                            .tint(.dora)
                            
                            if let error {
                                Text(error)
                                    .foregroundStyle(.red)
                                    .font(.title3)
                            }
                        }
                        
                        ForEach(tripCreationVM.selectedPlaces, id: \.self) { place in
                            VStack {
                                LocationCard(location: place,
                                             selectedPlaces: $tripCreationVM.selectedPlaces, placesToRemove: $geminiVM.placesToRemove)
                                
                            }
                            
                        }
                    }
                    
                }
            }
            
            
            
        }
        
        
        
        Spacer()
        HStack {
            Button("Start again") {
                geminiVM.placesToRemove.removeAll()
                tripCreationVM.clear()
                router.tripCreationRoute = [TripCreationRoute.preferences]
                
            }.disabled(geminiVM.isLoading)
                .buttonStyle(.glassProminent)
                .tint(.dora)
            
            
            
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
            }.disabled(appVM.isSaving)
                .buttonStyle(.glassProminent)
        }
        
        .frame(alignment: .center)
    }
  

}

