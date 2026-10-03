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

    
    init(region: MKCoordinateRegion) {
        geminiService = GeminiServiceImpl(region: region)

    }
  
    
    func request(prompt: String) async throws -> AIResult {
        isLoading = true
        placesToRemove.removeAll()
        
       
        let aiTrip = try await geminiService.request(tripRequest: prompt)
            
        isLoading = false
    
        return aiTrip
        
            
        
    }
    
    func editTrip() async throws -> AIResult {
        isLoading = true
     
        let aiTrip = try await geminiService.editTrip(identifiers: placesToRemove)
            
        placesToRemove.removeAll()
       
        isLoading = false
        return aiTrip
        
    }
    
    func isBeingRemoved(place: MKMapItem) -> Bool {
        guard let identifier = place.identifier?.rawValue else {
            return false
        }
        
        return placesToRemove.contains(identifier)
    }
    
    func toggleRemove(place: MKMapItem) {
        guard let id = place.identifier?.rawValue else {
            return
        }
        
        if let index = placesToRemove.firstIndex(of: id) {
            placesToRemove.remove(at: index)
        } else {
            placesToRemove.append(id)
        }
    }
}
