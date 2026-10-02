//
//  AITripCreationView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import SwiftUI
import MapKit

struct AITripCreationView: View {
    @State private var gemini: GeminiViewModel
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel
    
    @State private var prompt: String = ""
    @State private var selectedPlaces: [MKMapItem] = [MKMapItem]()
    @State var routes: [MKRoute] = []
    
    
    init(region: MKCoordinateRegion) {
        gemini = GeminiViewModel(region: region)
    }
    @State private var mode: Mode = .first

    enum Mode: String, CaseIterable, Identifiable {
        case first = "Details"
        case second = "Places"
        var id: Self { self }
    }
    
    var body: some View {
        VStack (alignment: .leading){
            Text("AI Trip Creation")
                .font(.largeTitle).padding()
            
            Spacer()
            VStack (alignment: .center) {
                if selectedPlaces.isEmpty {
                    if gemini.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                    } else {
                        VStack {
                            Text("Hi, I'm Dora.")
                                .multilineTextAlignment(.center)
                                .font(.largeTitle)
                                .bold()
                            
                            Text("Where would you like to explore today?")
                                .font(.title)
                                .multilineTextAlignment(.center)
                        }.frame(maxWidth: .infinity, alignment: .center)
                    }
                
                } else {
                    ScrollView {
                        Map {
                            ForEach(selectedPlaces.indices, id: \.self) { index in
                                Marker(item: selectedPlaces[index])
                                    .mapItemDetailSelectionAccessory(.callout)
                                ForEach(routes, id: \.self) { route in
                                    MapPolyline(route)
                                        .stroke(.blue, lineWidth: 5)
                                }
                            }
                        }
                        .frame(height: 425)
                        
                        if gemini.isLoading {
                            VStack {
                                Text("Curating the perfect trip...")
                                ProgressView()
                                
                            }
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
                                    }
                                case .second:
                                    ForEach(selectedPlaces, id: \.self) { place in
                                        VStack {
                                            if let id = place.identifier?.rawValue, gemini.placesToRemove.contains(id)  {
                                                Text("REMOVED")
                                            }
                                            HStack {
                                                Text(place.name ?? "")
                                                Text(place.address?.fullAddress ?? "")
                                            }
                                            Button("Remove") {
                                                guard let id = place.identifier?.rawValue else {
                                                    return
                                                }
                                                
                                                if let index = gemini.placesToRemove.firstIndex(of: id) {
                                                    gemini.placesToRemove.remove(at: index)
                                                } else {
                                                    gemini.placesToRemove.append(id)
                                                }
                                            }.disabled(gemini.isLoading)
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                    }
                }
            }
            Spacer()
            if selectedPlaces.isEmpty && !gemini.isLoading{

                HStack {
                    TextField("Create a trip through my local parks....", text: $prompt, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                    
                    
                    Button("", systemImage: "paperplane.circle.fill") {
                        prompt.removeAll()
                        Task {
                            do {
                                selectedPlaces = try await gemini.request(prompt: prompt)
//                                selectedPlaces = try await locationVM.searchPlaces(searchRequest: "burger")
                                routes = try await locationVM.createRoute(selectedPlaces: selectedPlaces)
                                
                            }catch {
                                
                            }
                        }
                    }
                    .font(.largeTitle)
                    .disabled(gemini.isLoading)
                }.padding()

                } else {
                    VStack {
                        HStack {
                            Button("Create a different trip") {
                                selectedPlaces.removeAll()
                                routes.removeAll()
                            }.disabled(gemini.isLoading)
                            
                            Button("Replace selected spots") {
                                Task {
                                    do {
                                        selectedPlaces = try await gemini.editTrip()
                                        routes = try await locationVM.createRoute(selectedPlaces: selectedPlaces)
                                    } catch {
                                        
                                    }
                                }
                            }.disabled(gemini.placesToRemove.isEmpty || gemini.isLoading)
                        }
                        Button("Finish") {
                            
                        }.disabled(gemini.isLoading)
                    }
                }
                
        }
    }
}

#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    
    let location = CLLocationCoordinate2D(
        latitude: -37.8136,
        longitude: 144.9631
    )

    let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan())
    AITripCreationView(region: region)
        .environment(LocationViewModel(user: user))
}
