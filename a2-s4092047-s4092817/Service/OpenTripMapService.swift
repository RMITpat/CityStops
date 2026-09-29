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
                                     returnLimit: Int) async throws -> [OpenTripLocation] {
        
        var components = URLComponents(string: "https://api.opentripmap.com/0.1/en/places/radius")!
        components.queryItems = [
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "lon", value: String(location.longitude)),
            URLQueryItem(name: "lat", value: String(location.latitude)),
            URLQueryItem(name: "kinds", value: filter),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "limit", value: String(returnLimit)),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        
        
        // The following is API request + decoding with gen-AI print statements for debugging
        guard let url = components.url else { throw URLError(.badURL) }
        print("➡️ Request URL:", url.absoluteString)

        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse {
            print("⬅️ Status code:", http.statusCode)
        }
        print("⬅️ Raw body:", String(data: data, encoding: .utf8) ?? "<non-UTF8 data>")

        do {
            return try JSONDecoder().decode([OpenTripLocation].self, from: data)
        } catch {
            print("❌ Decoding error:", error)
            throw error
        }
        
        // regular API request + decoding
//        guard let url = components.url else { throw URLError(.badURL) }
//        
//        let (data, _) = try await URLSession.shared.data(from: url)
//        return try JSONDecoder().decode([OpenTripLocation].self, from: data)
    }
}
