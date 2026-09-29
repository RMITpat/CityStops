//
//  PreferenceViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 23/9/2026.
//

import Foundation
import Observation
import MapKit


/// Handles selected preferences in ``TripPreferenceView``.
@Observable
final class TripCreationViewModel {
    private(set) var preferences: [Preference] = preferencesList
    var selectedPreferences: [Preference] = []

    var name: String = ""

    // Places selected by the user to be a part of the trip
    var selectedPlaces: [MKMapItem] = []
    
    /// toggles selected state of ``Preference`` list item.
    func toggle(_ preference: Preference) {
        if isSelected(preference) {
            selectedPreferences.removeAll {$0.preference == preference.preference}
        } else {
            selectedPreferences.append(preference)
        }
    }
    
    /// determine if a given ``Preference`` is selected by the user.
    func isSelected(_ preference: Preference) -> Bool {
        selectedPreferences.contains(where: {$0.preference == preference.preference})
    }
    
    func clear() {
        name.removeAll()
        selectedPlaces.removeAll()
        selectedPreferences.removeAll()
    }
}
