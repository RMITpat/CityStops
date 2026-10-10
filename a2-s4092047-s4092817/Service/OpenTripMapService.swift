//
//  OpenTripMapService.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import SwiftUI
import CoreLocation

/// The REST API service, OpenTripMap, that fetches locations and landmarks via
/// the type of location (i.e. landmark, food, shopping).
///
/// Adapted from Week 8 Lectorial code.
///
/// See ``OpenTripMapServiceImpl`` for the real implementation in the app.
protocol OpenTripMapService {
    /// Fetches nearby locations within a specified radius, filtered by category.
    ///
    /// - Parameters:
    ///   - location: The geographic coordinates to search around.
    ///   - radius: The search radius in metres.
    ///   - filter: The category or kinds of locations to include (e.g. restaurants, historic buildings, or shops).
    ///   - returnLimit: The maximum number of locations to return.
    /// - Returns: An array of nearby locations matching the specified category.
    /// - Throws: An error if the request URL is invalid, the network request fails, or the response cannot be decoded.
    func fetchNearbyPointsByCategory(location: CLLocationCoordinate2D,
                                     radius: Int,
                                     filter: String,
                                     returnLimit: Int) async throws -> [OpenTripLocation]
}

/// Real implementation of ``OpenTripMapService`` in the app.
class OpenTripMapServiceImpl : OpenTripMapService {
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
    
    /// Fetches nearby locations within a specified radius, filtered by category.
    func fetchNearbyPointsByCategory(location: CLLocationCoordinate2D,
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
    }
}
