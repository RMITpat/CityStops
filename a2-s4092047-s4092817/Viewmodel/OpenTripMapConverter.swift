//
//  OpenTripMapConverter.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 29/9/2026.
//

import Foundation
import MapKit

///
/// Class used for converting OpenTripMap API location responses into
/// Swift ``MKMapItem``, so that the corresponding identifier can be stored
/// consistently with regular locations.
///
@Observable
class OpenTripMapConverter {
    
    func convertResponseToMapItem(
        response: OpenTripLocation,
        searchRadius: CLLocationDistance = 300
    ) async throws -> MKMapItem? {
        let target = CLLocation(latitude: response.lat, longitude: response.lon)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = response.name
        request.region = MKCoordinateRegion(
            center: target.coordinate,
            latitudinalMeters: searchRadius * 2,
            longitudinalMeters: searchRadius * 2
        )
        
        let result = try await MKLocalSearch(request: request).start()
        
        let candidates = result.mapItems.filter {
            $0.identifier != nil &&
            $0.location.distance(from: target) <= searchRadius
        }
        
        // Prefer a result whose name matches (or contains / is contained by) the wanted name
        let wanted = response.name.lowercased()
        let match = candidates.first {
            guard let name = $0.name?.lowercased() else { return false }
            return name.contains(wanted) || wanted.contains(name)
        }
        
        // Otherwise fall back to the closest result
        return match ?? candidates.min {
            $0.location.distance(from: target) < $1.location.distance(from: target)
        }
    }
}

