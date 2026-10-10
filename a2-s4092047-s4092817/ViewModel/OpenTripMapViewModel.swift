//
//  OpenTripMapViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import MapKit

enum SegmentStatus {
    case success([MapItem])
    case error(Error)
}
@MainActor
@Observable
final class OpenTripMapViewModel {
    private let service: OpenTripMapService
    private let mapKitService: MapKitService
    // MARK: - Preset REST API query values
    private let radius = 5000
    private let limit = 15
    private let maxResults = 3
    
    // MARK: - The MapItems for each of the preference segments
    var segmentLocations: [String : SegmentStatus] = [:]
    
    // Mock init
    init (service: OpenTripMapService, mkService: MapKitService) {
        self.service = service
        self.mapKitService = mkService
    }
    
    // Real init
    init() {
        self.service = OpenTripMapServiceImpl()
        self.mapKitService = MapKitServiceImpl()
    }
    
    /// Populates segmentLocations with the converted opentripmap locations
    func generateSegments(preferences: [Preference], coordinate: CLLocationCoordinate2D) async {
        for preference in preferences {
            Task {
                await loadLocations(for: preference, near: coordinate)
            }
        }
        
    }
    
    /// Loads the locations and converts them into MapItem for a preference
    func loadLocations(for preference: Preference,
                       near coordinate: CLLocationCoordinate2D) async {
        do {
            let results = try await service.fetchNearbyPointsByCategory(
                location: coordinate,
                radius: radius,
                filter: preference.preferenceSearch,
                returnLimit: limit
            )
            var mapItems: [MapItem] = []
            for place in results where !place.name.isEmpty {
                if mapItems.count >= maxResults { break }

                if let item = try? await convertResponseToMapItem(response: place)
//                   !mapItems.contains(where: { $0.identifier == item.identifier })
                {
                    mapItems.append(item)
                }
            }
            
            segmentLocations[preference.preference] =  .success(mapItems)
        } catch {
            segmentLocations[preference.preference] = .error(error)
        }
    
    }
    
    
    /// Convert from ``OpenTripLocation`` to MapItem
    func convertResponseToMapItem(
        response: OpenTripLocation,
        searchRadius: CLLocationDistance = 500
    ) async throws -> MapItem? {
        let target = CLLocation(latitude: response.lat, longitude: response.lon)
       
        let region = MKCoordinateRegion(
            center: target.coordinate,
            latitudinalMeters: searchRadius * 2,
            longitudinalMeters: searchRadius * 2
        )

        let result = try await mapKitService.searchPlaces(searchRequest: response.name, currentRegion: region)
      
        
        let candidates = result.filter {
            $0.mkMapItem.location.distance(from: target) <= searchRadius
            
        }
        
        
        // Prefer a result whose name matches, ignoring punctuation and spaces
        let wanted = response.name
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }

        let match = candidates.first {
            guard let name = $0.mkMapItem.name?.lowercased()
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
