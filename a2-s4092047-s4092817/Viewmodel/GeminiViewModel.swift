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
    
    var placesToRemove: [String] = []
    
    var name: String = ""
    var description: String = ""
    
    init(region: MKCoordinateRegion) {
        geminiService = GeminiServiceImpl(region: region)

    }
    
    
    func request(prompt: String) async throws -> [MKMapItem] {
        isLoading = true
        placesToRemove.removeAll()
        let aiTrip = try await geminiService.request(tripRequest: prompt)
        
        let places = aiTrip.0
        name = aiTrip.1
        description = aiTrip.2
        
        isLoading = false
        
        return places
        
//        try await Task.sleep(for: .seconds(5))
//        isLoading = false
//        return []
            
        
    }
    
    func editTrip() async throws -> [MKMapItem] {
        isLoading = true
        let aiTrip = try await geminiService.editTrip(identifiers: placesToRemove)
        
        let places = aiTrip.0
        name = aiTrip.1
        description = aiTrip.2
        
        isLoading = false
        
        return places
    }
}
