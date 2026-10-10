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
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    @Environment(AppViewModel.self) var appVM: AppViewModel

    @Environment(Router.self) var router: Router

    @State private var mode: Mode = .first

    @State private var error: String?
    enum Mode: String, CaseIterable, Identifiable {
        case first = "Details"
        case second = "Places"
        var id: Self { self }
    }
    
    var body: some View {
        @Bindable var tripCreationVM = tripCreationVM
        @Bindable var geminiVM = geminiVM
        VStack {
            RouteMapSection()
            .accessibilityHidden(true)
            .frame(height: 375)
            
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
                    .accessibilitySortPriority(3)
                    
                    switch mode {
                    case .first:
                        VStack(alignment: .leading) {
                            TextField("e.g. Asian Street Food Tour", text: $tripCreationVM.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 32)
                                .font(.title)
                                .accessibilityIdentifier("ai.title")
                                .accessibilityLabel("Edit the ai generated title")
                            
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
                                .accessibilityIdentifier("ai.description")
                                .accessibilityLabel("Edit the ai generated decription")
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
                                        
                                    } catch {
                                        self.error = "Failed to regenerate stops"
                                    }
                                }
                                
                            }
                            .disabled(geminiVM.placesToRemove.isEmpty || geminiVM.isLoading)
                            .buttonStyle(.glassProminent)
                            .tint(.dora)
                            .accessibilityIdentifier("replace.spots")
                            .accessibilityHint("Ask AI to replace the spots you have selected")

                            
                            Button("Add more spots") {
                                Task {
                                    do {
                                        self.error?.removeAll()
                                        
                                        try await tripCreationVM.fromAIResult(result: geminiVM.addStops())
                                        
                                    } catch {
                                        self.error = "Failed to add more stops"
                                    }
                                }
                                
                            }
                            .disabled(geminiVM.isLoading)
                            .buttonStyle(.glassProminent)
                            .tint(.dora)
                            .accessibilityIdentifier("add.spots")
                            .accessibilityHint("Ask AI to come up with more spots to this trip")

                            
                            if let error {
                                Text(error)
                                    .foregroundStyle(.red)
                                    .font(.title3)
                            }
                        }
                        
                        // MARK: List of chosen locations
                        SelectedPlacesList(placesToRemove: $geminiVM.placesToRemove)
                    }
                    
                }
            }
            
            
            
            
            
            
            
            Spacer()
            
            HStack {
                Button("Start again") {
                    geminiVM.placesToRemove.removeAll()
                    geminiVM.resultReturned = false
                    tripCreationVM.clear()
                    router.tripCreationRoute = [TripCreationRoute.preferences]
                    
                }.disabled(geminiVM.isLoading)
                    .buttonStyle(.glassProminent)
                    .tint(.dora)
                    .accessibilityIdentifier("start.again")
                    .accessibilityHint("Discard this trip and start again at preference selection")
                    .accessibilitySortPriority(2)
                
                
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
                }.disabled(appVM.isSaving)
                    .buttonStyle(.glassProminent)
                    .accessibilityIdentifier("finish.button")
                    .accessibilityHint("Save this trip and return to the home feed")
                    .accessibilitySortPriority(1)

            }
            .frame(alignment: .center)
        }
    }
  

}

