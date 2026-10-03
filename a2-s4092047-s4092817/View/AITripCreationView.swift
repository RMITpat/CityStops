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
    
    @State private var prompt: String = ""
    

    init(region: MKCoordinateRegion) {
        gemini = GeminiViewModel(region: region)
    }
    
    
    var body: some View {
        VStack (alignment: .leading){
            Text("AI Trip Creation")
                .font(.largeTitle).padding()
            
            Spacer()
            VStack (alignment: .center) {
                if gemini.selectedPlaces.isEmpty {
                    if gemini.isLoading {
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
                
                } else {
                    AITripOverview()
                        .environment(gemini)
                }
            }
            Spacer()
            if gemini.selectedPlaces.isEmpty && !gemini.isLoading {
                
                HStack {
                    TextField("Create a trip through my local parks....", text: $prompt, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                    
                    
                    Button("", systemImage: "paperplane.circle.fill") {
                        gemini.request(prompt: prompt)
                        
                    }
                    .font(.largeTitle)
                    .disabled(gemini.isLoading)
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
