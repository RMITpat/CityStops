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
        searchRadius: CLLocationDistance = 500
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
        
        // Prefer a result whose name matches, ignoring punctuation and spaces
        let wanted = response.name
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }

        let match = candidates.first {
            guard let name = $0.name?.lowercased()
                .filter({ $0.isLetter || $0.isNumber })
            else {
                return false
            }

            return name == wanted
        }
        
        // Otherwise don't return anything
        return match ?? nil
    }
}

