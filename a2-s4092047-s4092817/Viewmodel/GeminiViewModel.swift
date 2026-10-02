//
//  GeminiViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import Foundation
import MapKit

@Observable class GeminiViewModel {
    let geminiService: GeminiService
    
    var isLoading: Bool = false
    init(region: MKCoordinateRegion) {
        geminiService = GeminiServiceImpl(region: region)

    }
    
    
    func request(prompt: String) async throws -> [MKMapItem]{
        isLoading = true
        
        let places = try await geminiService.request(prompt: prompt)
        
        print(places.count)
        
        for place in places {
            print(place.name ?? "No place name")
            print(place.pointOfInterestCategory?.rawValue ?? "No category")
        }
        //selectedPlaces = places
        isLoading = false
        
        return places
            
        
    }
}
