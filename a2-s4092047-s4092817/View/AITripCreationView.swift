//
//  AITripCreationView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import SwiftUI
import MapKit

struct AITripCreationView: View {
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel

    @State private var geminiVM: GeminiViewModel
    
    @State private var prompt: String = ""
    
    @State private var error: String?
    @State private var routes: [MKRoute] = []

    init(region: MKCoordinateRegion) {
        geminiVM = GeminiViewModel(region: region)
    }
    
    
    var body: some View {
        VStack (alignment: .leading){
            Text("AI Trip Creation")
                .font(.largeTitle).padding()
            
            Spacer()
            VStack (alignment: .center) {
                if tripCreationVM.selectedPlaces.isEmpty {
                    if geminiVM.isLoading {
                        ProgressView("Curating the perfect trip...")
                            .progressViewStyle(.circular)
                            .scaleEffect(1.3)
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
                    
                    if let error {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.title3)
                    }
                
                } else {
                    AITripOverview(routes: $routes)
                        .environment(geminiVM)
                }
            }
            Spacer()
            if tripCreationVM.selectedPlaces.isEmpty && !geminiVM.isLoading {
                
                HStack {
                    TextField("Create a trip through my local parks....", text: $prompt, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                    
                    
                    Button("", systemImage: "paperplane.circle.fill") {
                        Task {
                            do {
                                self.error?.removeAll()
//                                try await tripCreationVM.fromAIResult(result: geminiVM.request(prompt: prompt, preferences: tripCreationVM.selectedPreferences))
                                try await tripCreationVM.fromAIResult(result: geminiVM.request(prompt: prompt, currentRegion: locationVM.currentRegion))
                                try await routes = locationVM.createRoute(selectedPlaces: tripCreationVM.selectedPlaces)
                            } catch {
                                self.error = "Failed to generate a trip"
                            }
                        }
                        
                    }
                    .font(.largeTitle)
                    .disabled(geminiVM.isLoading)
                }.padding()

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
