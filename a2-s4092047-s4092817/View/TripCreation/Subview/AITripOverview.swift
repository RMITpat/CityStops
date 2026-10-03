//
//  AITripOverview.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 2/10/2026.
//

import SwiftUI
import MapKit

struct AITripOverview: View {
    @Environment(GeminiViewModel.self) var geminiVM: GeminiViewModel
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
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
                ProgressView("Regenerating places...")
                    .progressViewStyle(.circular)
                    .scaleEffect(1.3)
                    .frame(maxWidth: .infinity, alignment: .center)

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
//                                        try await tripCreationVM.fromAIResult(result: geminiVM.editTrip())

                                        try await tripCreationVM.fromAIResult(result: geminiVM.editTrip(currentRegion: locationVM.currentRegion))
                                        routes = try await locationVM.createRoute(selectedPlaces: tripCreationVM.selectedPlaces)
                                    } catch {
                                        self.error = "Failed to regenerate stops"
                                    }
                                }
                                
                            }
                            .disabled(geminiVM.placesToRemove.isEmpty || geminiVM.isLoading)
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
                    
                }.disabled(geminiVM.isLoading)
                .buttonStyle(.glassProminent)
            }
        
        .frame(alignment: .center)
      
    }
}

