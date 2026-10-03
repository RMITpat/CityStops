//
//  AITripOverview.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 2/10/2026.
//

import SwiftUI
import MapKit

struct AITripOverview: View {
    @Environment(GeminiViewModel.self) var gemini: GeminiViewModel
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel

    @State private var routes: [MKRoute] = []

    @State private var mode: Mode = .first

    enum Mode: String, CaseIterable, Identifiable {
        case first = "Details"
        case second = "Places"
        var id: Self { self }
    }
    
    var body: some View {
        ScrollView {
            Map {
                ForEach(gemini.selectedPlaces.indices, id: \.self) { index in
                    Marker(item: gemini.selectedPlaces[index])
                        .mapItemDetailSelectionAccessory(.callout)
                    ForEach(routes, id: \.self) { route in
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
            }
            .frame(height: 390)
            .onChange(of: gemini.selectedPlaces) {
                Task {
                    do {
                        print("gemini selected places changed")
                        routes = try await locationVM.createRoute(selectedPlaces: gemini.selectedPlaces)
                    } catch {
                        
                    }
                }
            }
            if gemini.isLoading {
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
                            Text(gemini.name).font(.title)
                            Text(gemini.description).font(.default)
                        }.padding()
                        
                    case .second:
                        
                        Button("Replace selected spots") {
                            gemini.editTrip()
                            
                        }
                        .disabled(gemini.placesToRemove.isEmpty || gemini.isLoading)
                        .buttonStyle(.glassProminent)
                        .tint(.dora)
                        
                        ForEach(gemini.selectedPlaces, id: \.self) { place in
                            VStack {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        
                                        Text(place.name ?? "")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text(place.address?.fullAddress ?? "")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1) // address should not be extremely long
                                    }
                                    Spacer()
                                    
                                    Button("",
                                           systemImage: gemini.isBeingRemoved(place: place) ? "checkmark.circle.fill" : "circle"
                                    ) {
                                        gemini.toggleRemove(place: place)
                                    }
                                    .font(.title)
                                    .disabled(gemini.isLoading)
                                    .foregroundColor(gemini.isBeingRemoved(place: place) ?
                                                    .accentColor : .gray
                                    )
                                    
                                }.padding()
                                
                            }
                            .contentShape(Rectangle())
                            .background(
                                
                                )
                            
                        }
                    }
                    
                }
            }
            

            
        }
        Spacer()
            HStack {
                Button("Start again") {
                    gemini.reset()
                    
                }.disabled(gemini.isLoading)
                .buttonStyle(.glassProminent)
                .tint(.dora)

                
                
                Button("Finish") {
                    
                }.disabled(gemini.isLoading)
                .buttonStyle(.glassProminent)
            }
        
        .frame(alignment: .center)
      
    }
}

