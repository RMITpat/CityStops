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
    let mockResult = AIResult(tripName: "Test trip", description: "Test description", selectedPlaces: [
        MockMapKitService.makeDummyMapItem(
            identifier: "mock-mca-australia",
            name: "Museum of Contemporary Art Australia",
            latitude: -33.8731,
            longitude: 151.2065,
            address: "George Street, Sydney NSW"
        ),
        MockMapKitService.makeDummyMapItem(
            identifier: "mock-the-rocks",
            name: "The Rocks",
            latitude: -33.8696,
            longitude: 151.2069,
            address: "The Rocks, Sydney NSW"
        ),
    ])
    
    func request(tripRequest: String, preferences: [String]) async throws -> AIResult {
        return mockResult
    }
    
    func editTrip(identifiers: [String], selectedPlaces: [MapItem]) async throws -> AIResult {
        return mockResult
    }
    
    func addStops(selectedPlaces: [MapItem]) async throws -> AIResult {
        return mockResult
    }
    
    func setModel(newModel: GeminiModel) {
        modelName = newModel
    }
    
    
}
