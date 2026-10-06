//
//  ViewModelFactory.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import MapKit

@MainActor
@Observable
final class ViewModelFactory {
    func createAppViewModel(user: AppUser) -> AppViewModel {
        return AppViewModel(user: user)
    }
    
    func createAuthViewModel() -> AuthViewModel {
        return AuthViewModel()
    }
    
    func createGeminiViewModel(region: MKCoordinateRegion) -> GeminiViewModel {
        return GeminiViewModel(region: region)
    }
    
    func createLocationViewModel(user: AppUser) -> LocationViewModel {
        return LocationViewModel(user: user)
    }
    
    func createOpenTripMapViewModel() -> OpenTripMapViewModel {
        return OpenTripMapViewModel()
    }
    
    func createSearchTermViewModel() -> SearchTermViewModel {
        return SearchTermViewModel()
    }
    
    
}
