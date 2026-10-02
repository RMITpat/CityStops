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

    var body: some View {
        VStack (alignment: .leading){
            Text("AI Trip Creation")
                .font(.largeTitle).padding()
            
            Spacer()
            VStack (alignment: .center) {
                if selectedPlaces.isEmpty {
                    VStack {
                        Text("Hi, I'm Dora.")
                            .multilineTextAlignment(.center)
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Where would you like to explore today?")
                            .font(.title)
                            .multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity, alignment: .center)
                } else if gemini.isLoading {
                    ProgressView()
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
                            ProgressView()
                        }
                        VStack {
                            ForEach(selectedPlaces, id: \.self) { place in
                                VStack {
                                    Text(place.name ?? "")
                                    Text(place.address?.fullAddress ?? "")
                                }
                            }
                        }
                        
                    }
                }
            }
            Spacer()
            if selectedPlaces.isEmpty {

                HStack {
                    TextField("Create a trip through my local parks....", text: $prompt, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                    
                    
                    Button("", systemImage: "paperplane.circle.fill") {
                        Task {
                            do {
                                //                        selectedPlaces = try await gemini.request(prompt: prompt)
                                gemini.isLoading = true
                                
                                try await Task.sleep(for: (.seconds(3)))
                                selectedPlaces = try await Array(locationVM.searchPlaces(searchRequest: "burger restaurants").prefix(5))
                                
                                routes = try await locationVM.createRoute(selectedPlaces: selectedPlaces)
                                
                                gemini.isLoading = false
                            }catch {
                                
                            }
                        }
                    }.font(.largeTitle)
                }.padding()

                } else {
                    Button("Create a different trip") {
                        selectedPlaces.removeAll()
                        routes.removeAll()
                    }
                    Button("Choose different spots") {
                        Task {
                            do {
                                //                        selectedPlaces = try await gemini.request(prompt: prompt)
                                routes = try await locationVM.createRoute(selectedPlaces: selectedPlaces)
                            } catch {
                                
                            }
                        }
                    }
                    Button("Continue") {
                        
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
