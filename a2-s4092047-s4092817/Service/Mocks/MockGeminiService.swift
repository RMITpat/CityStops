//
//  MockGeminiService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import MapKit

/// Mock Gemini service that does not use Firebase AI Logic methods. Used in UI Tests
@MainActor
final class MockGeminiService : GeminiService {
    var modelName: GeminiModel = .flash6
    let mockResult = AIResult(tripName: "Test trip", description: "Test description", selectedPlaces: [])
    
    func request(tripRequest: String, preferences: [String]) async throws -> AIResult {
        return mockResult
    }
    
    func editTrip(identifiers: [MKMapItem.Identifier]) async throws -> AIResult {
        return mockResult
    }
    
    func addStops() async throws -> AIResult {
        return mockResult
    }
    
    func setModel(newModel: GeminiModel) {
        modelName = newModel
    }
    
    
}
