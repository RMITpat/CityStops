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

struct OpenTripLocation: Decodable {
    let latitude: Double
    let longitude: Double
    
    let name: String
}
