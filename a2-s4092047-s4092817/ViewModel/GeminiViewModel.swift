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
    
    var selectedPlaces: [MKMapItem] = [MKMapItem]()
    
    
    init(region: MKCoordinateRegion) {
        geminiService = GeminiServiceImpl(region: region)

    }
    func reset() {
        placesToRemove.removeAll()
        name.removeAll()
        description.removeAll()
        selectedPlaces.removeAll()
    }
    
    func request(prompt: String) {
        if prompt.isEmpty {
            return
        }
        isLoading = true
        reset()
        
        Task {
            do {
                let aiTrip = try await geminiService.request(tripRequest: prompt)
                
                selectedPlaces = aiTrip.0
                name = aiTrip.1
                description = aiTrip.2
                
            } catch {
                
            }
            
            isLoading = false
        }
        
        
            
        
    }
    
    func editTrip() {
        isLoading = true
        Task {
            do {
                let aiTrip = try await geminiService.editTrip(identifiers: placesToRemove)
                
                selectedPlaces = aiTrip.0
                name = aiTrip.1
                description = aiTrip.2
                
                placesToRemove.removeAll()
            } catch {
                
            }
            isLoading = false
        }
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
