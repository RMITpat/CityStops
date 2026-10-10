//
//  OpenTripLocation.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import Foundation
import CoreLocation

/// Models the necessary location response variables from OpenTripMapAPI response
/// for conversion to MKMapItem.
struct OpenTripLocation: Identifiable, Decodable {
    let lat: Double
    let lon: Double
    
    /// Name of location.
    let name: String
    
    /// A unique identifier derived from the location's name and coordinates.
    /// Used to identify locations in SwiftUI views and tests.
    var id: String { "\(name)-\(lat)-\(lon)" }
    
    /// Defines the API response keys used to decode the location's name and coordinates.
    private enum CodingKeys: String, CodingKey {
        case name, point
    }

    /// Defines the keys used to decode the latitude and longitude from the nested point object.
    private enum PointKeys: String, CodingKey {
        case lat, lon
    }

    /// Creates an OpenTripLocation by decoding the nested structure of an OpenTripMap API response.
    /// - Parameter decoder: The decoder providing the API response data.
    /// - Throws: A decoding error if the name, point object, latitude, or longitude is missing
    ///   or cannot be decoded.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)

        let point = try container.nestedContainer(keyedBy: PointKeys.self, forKey: .point)
        lat = try point.decode(Double.self, forKey: .lat)
        lon = try point.decode(Double.self, forKey: .lon)
    }
    
    /// Creates an OpenTripLocation directly using the supplied values, primarily for mock data and tests.
    /// - Parameters:
    ///   - name: The name of the location.
    ///   - lat: The latitude coordinate of the location.
    ///   - lon: The longitude coordinate of the location.
    init(name: String, lat: Double, lon: Double) {
        self.name = name
        self.lat = lat
        self.lon = lon
    }
}
