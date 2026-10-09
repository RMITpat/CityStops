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
    var description: String = ""
    
    
    var nameError: String?
    var descriptionError: String?
    
    // Places selected by the user to be a part of the trip
    var selectedPlaces: [MapItem] = []
    
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
    
    /// Reset name, description, currently selected places and preferences
    func clear() {
        name.removeAll()
        description.removeAll()
        selectedPlaces.removeAll()
        selectedPreferences.removeAll()
    }
    
    /// Extract name, desc and selected places from an AI Result
    func fromAIResult(result: AIResult) {
        name = result.tripName
        description = result.description
        selectedPlaces = result.selectedPlaces
    }
    
    /// Reset name and desc errors
    func clearErrors() {
        nameError = nil
        descriptionError = nil
    }
    
    /// Check trip name and desc is not empty
    func validateNameDesc() -> Bool {
        clearErrors()
        if name.isEmpty {
            nameError = "Please provide a title"
        }
        if description.isEmpty {
            descriptionError = "Please provide a description"
        }
        return nameError == nil && descriptionError == nil
    }
}
