//
//  OpenTripMapService.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//
///
/// The REST API service, OpenTripMap, that fetches locations and landmarks via
/// the type of location (i.e. landmark, food, shopping).
///
/// Adapted from Week 8 Lectorial code.
///
import SwiftUI
import CoreLocation

class OpenTripMapService {
    private let apiKey: String
    
    init() {
        // Load API key from Secrets.plist
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["OpenTripMapAPIKey"] as? String {
            self.apiKey = key
        } else {
            fatalError("Missing OpenTripMapAPIKey in Secrets.plist")
        }
    }
    
    /// fetches the top-rated nearby locations to a given point, filtered by the "kind" of location (e.g. Restaurant, Historic building, Shop etc.)
    func fetchNearbyPointsByCategory(for location: CLLocationCoordinate2D,
                                 radius: Int,
                                 filter: String,
                                 returnLimit: Int) async throws -> OpenTripLocation {
        
        let encodedLat = location.latitude
        let encodedLong = location.longitude
        
        let url = URL(string: """
                                https://api.opentripmap.com/0.1/en/places/radius?
                                    radius=\(radius)
                                    &lon=\(encodedLong)
                                    &lat=\(encodedLat)
                                    &kinds=\(filter)
                                    &rate=3
                                    &format=json
                                    &limit=\(returnLimit)
                                    &apikey=\(apiKey)
                              """)!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(OpenTripLocation.self, from: data)
    }
}
