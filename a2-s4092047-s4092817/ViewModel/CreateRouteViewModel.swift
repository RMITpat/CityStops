//
//  CreateRouteViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 1/10/2026.
//

import Foundation
import MapKit

/// Holds ``LocationSegmentViewModel`` instances in ``CreateRouteView``, so that
/// API calls only happen once regardless of Sheet view regeneration.

@MainActor
@Observable
final class CreateRouteViewModel {
    private var segments: [String: LocationSegmentViewModel] = [:]
    
    /// Returns the existing ``LocationSegmentViewModel`` for a given ``Preference``, or creates one if it doesn't exist yet.
    func segmentVM(for preference: Preference) -> LocationSegmentViewModel {
        if let existing = segments[preference.preference] { return existing }
        let vm = LocationSegmentViewModel()
        segments[preference.preference] = vm
        return vm
    }
    
    /// Loads locations for every preference.
    func preload(preferences: [Preference], near coordinate: CLLocationCoordinate2D) async {
        await withTaskGroup(of: Void.self) { group in
            for preference in preferences {
                let vm = segmentVM(for: preference)
                group.addTask { await vm.loadIfNeeded(for: preference, near: coordinate) }
            }
        }
    }
    func clear() { segments.removeAll() }
}
