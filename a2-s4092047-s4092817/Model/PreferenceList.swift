//
//  PreferenceList.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 22/9/2026.
//

/// Fixed list of ``Preference``s, displayed in the creating Daytrip user flow.
/// Used in ``TripCreationViewModel``.
var preferencesList : [Preference] = [Preference(preference: "Food", preferenceSearch: "restaurants", icon: "fork.knife"),
                                      Preference(preference: "Landmarks and Sightseeing", preferenceSearch: "historic", icon: "building.columns"),
                                      Preference(preference: "Shopping", preferenceSearch: "malls", icon: "bag"),
                                      Preference(preference: "Nature", preferenceSearch: "natural", icon: "leaf"),
                                      Preference(preference: "Sports and Amusement", preferenceSearch: "sport", icon: "basketball")
                                    ]  
