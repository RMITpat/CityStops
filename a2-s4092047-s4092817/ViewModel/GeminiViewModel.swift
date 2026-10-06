//
//  GeminiViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 1/10/2026.
//

import Foundation
import MapKit

/// The GeminIViewModel used during the AI trip creation process
@Observable class GeminiViewModel {
    /// Service used to communicate with Gemini
    let geminiService: GeminiService
    
    /// Is gemini currently processing something
    var isLoading: Bool = false
    
    /// The list of places to be replaced by the model, chosen by the user from a generated trip
    var placesToRemove: [MKMapItem.Identifier] = []

    /// The current model being used
    var currentModelName: GeminiModel
    
    var resultReturned: Bool = false
    
    /// Real init
    init(region: MKCoordinateRegion) {
        geminiService = GeminiServiceImpl(region: region)
        currentModelName = geminiService.modelName
    }
    
    ///Mock init
    init(region: MKCoordinateRegion, geminiService: GeminiService) {
        self.geminiService = geminiService
        currentModelName = geminiService.modelName
    }
  
    /// Start trip creation by providing the model with a prompt and selected preferences
    func request(prompt: String, preferences: [Preference]) async throws -> AIResult {
        isLoading = true
        
        // Reset placesToRemove, this is a new trip
        placesToRemove.removeAll()
        
        let preferenceStrings = preferences.map {
            $0.preference
        }
        
        let aiTrip = try await geminiService.request(tripRequest: prompt, preferences: preferenceStrings)
            
        isLoading = false
        resultReturned = true
        return aiTrip
        
            
        
    }

    /// Edit a created trip by asking the model to replace certain places with new ones
    func editTrip() async throws -> AIResult {
        isLoading = true
     
        let aiTrip = try await geminiService.editTrip(identifiers: placesToRemove)
            
        placesToRemove.removeAll()
       
        isLoading = false
        return aiTrip
        
    }
  
    /// Ask the model to add more stops to a generated trip
    func addStops() async throws -> AIResult {
        isLoading = true
        
        let aiTrip = try await geminiService.addStops()
        
        isLoading = false
        return aiTrip
     
    }
    
    /// Change the model being used if being rate limited
    func setModel(model: GeminiModel) {
        geminiService.setModel(newModel: model)
        currentModelName = model
    }
}
