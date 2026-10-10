//
//  AITripCreationView.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import SwiftUI
import MapKit

/// The view on which users can input a prompt to ask our AI assistant Dora to create a trip
struct AITripCreationView: View {
    @Environment(TripCreationViewModel.self) var tripCreationVM: TripCreationViewModel
    @Environment(LocationViewModel.self) var locationVM: LocationViewModel

    @State private var geminiVM: GeminiViewModel
    
    @State private var prompt: String = ""
    
    @State private var error: String?
    @State private var routes: [MKRoute] = []

    init(region: MKCoordinateRegion, vmFactory: ViewModelFactory) {
        geminiVM = vmFactory.createGeminiViewModel(region: region)
    }
    
    
    var body: some View {
        
        VStack (alignment: .leading){
            HStack {
                Text("AI Trip Creation")
                    .font(.largeTitle).padding()
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Menu {
                    ForEach(GeminiModel.allCases, id: \.self) { model in
                        Button() {
                            geminiVM.setModel(model: model)
                            
                        } label: {
                            HStack {
                                Text(model.rawValue)
                                Spacer()
                                if geminiVM.currentModelName == model {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Model")
                        Image(systemName: "chevron.down")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.dora)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contentShape(Rectangle())
                }
            }
            
            Spacer()
            VStack (alignment: .center) {
                if !geminiVM.resultReturned {
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
                                .accessibilityIdentifier("dora.hi")
                            
                            Text("Where would you like to explore today?")
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .accessibilityIdentifier("dora.question")

                        }.frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                    
                    if let error {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.title3)
                    }
                
                } else {
                    AITripOverview()
                        .environment(geminiVM)
                }
            }
            Spacer()
            if !geminiVM.resultReturned && !geminiVM.isLoading {
                
                HStack {
                    TextField("Create a trip through my local parks....", text: $prompt, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("dora.input")
                    
                    
                    Button("", systemImage: "paperplane.circle.fill") {
                        Task {
                            do {
                                self.error?.removeAll()
                                try await tripCreationVM.fromAIResult(result: geminiVM.request(prompt: prompt, preferences: tripCreationVM.selectedPreferences))
                                try await routes = locationVM.createTripRoutes(selectedPlaces: tripCreationVM.selectedPlaces)
                            } catch {
                                self.error = "Failed to generate a trip"
                            }
                        }
                        
                    }
                    .accessibilityIdentifier("create.ai.trip")
                    .foregroundStyle(.dora)
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
    AITripCreationView(region: region, vmFactory: ViewModelFactory())
        .environment(LocationViewModel(user: user))
}
