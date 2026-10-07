//
//  OpenTripLocation.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import Foundation
import CoreLocation

/// Models the necessary location response variables from OpenTripMapAPI response
/// for conversion to ``MKMapItem``.

struct OpenTripLocation: Identifiable, Decodable {
    let lat: Double
    let lon: Double
    
    let name: String
    
    // TEMP FOR TESTING: this struct won't need to be decodable? (since it will get parsed into an MKMapItem)
    var id: String { "\(name)-\(lat)-\(lon)" }
    
    private enum CodingKeys: String, CodingKey {
        case name, point
    }

    private enum PointKeys: String, CodingKey {
        case lat, lon
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)

        let point = try container.nestedContainer(keyedBy: PointKeys.self, forKey: .point)
        lat = try point.decode(Double.self, forKey: .lat)
        lon = try point.decode(Double.self, forKey: .lon)
    }
    
    // Mock init
    init(name: String, lat: Double, lon: Double) {
        self.name = name
        self.lat = lat
        self.lon = lon
    }
}
