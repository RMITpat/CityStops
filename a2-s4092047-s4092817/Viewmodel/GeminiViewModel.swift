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
    
    init(region: MKCoordinateRegion) {
        geminiService = GeminiServiceImpl(region: region)

    }
    
    
    func request() {
        Task {
            do {
                let places = try await geminiService.request()
                print(places.count)
                for place in places {
                    print(place.name ?? "No place name")
                    print(place.pointOfInterestCategory?.rawValue ?? "No category")
                }
            } catch {
                
            }
        }
    }
}
