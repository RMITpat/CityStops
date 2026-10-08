//
//  MockCoreLocationService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import MapKit

/// Mock service that does not retrieve the user's location. Used in UI test
@MainActor
final class MockCoreLocationService : CoreLocationService {
    var onLocationUpdate: ((CLLocation) -> Void)?
    
    func checkLocationAuthorization() {
        // Do nothing
    }
  
}
