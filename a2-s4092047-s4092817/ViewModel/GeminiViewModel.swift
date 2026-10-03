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

    
    init(region: MKCoordinateRegion) {
        geminiService = GeminiServiceImpl(region: region)

    }
  
    
//    func request(prompt: String, preferences: [Preference]) async throws -> AIResult {
//        isLoading = true
//        placesToRemove.removeAll()
//        
//        let preferenceStrings = preferences.map {
//            $0.preference
//        }
//        
//        let aiTrip = try await geminiService.request(tripRequest: prompt, preferences: preferenceStrings)
//            
//        isLoading = false
//    
//        return aiTrip
//        
//            
//        
//    }
    
    func request(prompt: String, currentRegion: MKCoordinateRegion) async throws -> AIResult {
        isLoading = true
        placesToRemove.removeAll()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Burger"
        request.region = currentRegion
        
        let response = try await MKLocalSearch(request: request).start()
        
        let places = response.mapItems.filter {
            $0.identifier != nil
        }
        
        
      
        let aiTrip = AIResult(tripName: "trip", description: "cool tripz", selectedPlaces: places)
            
        isLoading = false
    
        return aiTrip
        
            
        
    }
//    
//    func editTrip() async throws -> AIResult {
//        isLoading = true
//     
//        let aiTrip = try await geminiService.editTrip(identifiers: placesToRemove)
//            
//        placesToRemove.removeAll()
//       
//        isLoading = false
//        return aiTrip
//        
//    }
    
    func editTrip(currentRegion: MKCoordinateRegion) async throws -> AIResult {
        isLoading = true
     
        
       let request = MKLocalSearch.Request()
       request.naturalLanguageQuery = "shopping"
       request.region = currentRegion
       
       let response = try await MKLocalSearch(request: request).start()
       
       let places = response.mapItems.filter {
           $0.identifier != nil
       }
       
       
     
       let aiTrip = AIResult(tripName: "trip", description: "cool tripz", selectedPlaces: places)
           
            
        placesToRemove.removeAll()
       
        isLoading = false
        return aiTrip
        
    }
    
//    func isBeingRemoved(place: MKMapItem) -> Bool {
//        guard let identifier = place.identifier?.rawValue else {
//            return false
//        }
//        
//        return placesToRemove.contains(identifier)
//    }
//    
//    func toggleRemove(place: MKMapItem) {
//        guard let id = place.identifier?.rawValue else {
//            return
//        }
//        
//        if let index = placesToRemove.firstIndex(of: id) {
//            placesToRemove.remove(at: index)
//        } else {
//            placesToRemove.append(id)
//        }
//    }
}
