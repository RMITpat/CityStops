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
    
    var placesToRemove: [MKMapItem.Identifier] = []

    var currentModelName: GeminiModel
    
    
    init(region: MKCoordinateRegion) {
        geminiService = GeminiServiceImpl(region: region)
        currentModelName = geminiService.modelName
    }
  
    
    func request(prompt: String, preferences: [Preference]) async throws -> AIResult {
        isLoading = true
        placesToRemove.removeAll()
        
        let preferenceStrings = preferences.map {
            $0.preference
        }
        
        let aiTrip = try await geminiService.request(tripRequest: prompt, preferences: preferenceStrings)
            
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
  
        
    func addStops() async throws -> AIResult {
        isLoading = true
        
        let aiTrip = try await geminiService.addStops()
        
        isLoading = false
        return aiTrip
     
    }
    
    func setModel(model: GeminiModel) {
        geminiService.setModel(newModel: model)
        currentModelName = model
    }
}
