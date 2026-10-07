//
//  ViewModelFactory.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation
import MapKit

/// ViewModelFactory that allows us to have control over the services used by a viewmodel. Inject mocks if we are in testmode and running UI tests, otherwise provide a normal
/// instance
@MainActor
@Observable
final class ViewModelFactory {
    let testMode: Bool
    
    init(testMode: Bool = false) {
        self.testMode = testMode
    }
    
    func createAppViewModel(user: AppUser) -> AppViewModel {
        return testMode ? AppViewModel(service: MockTripService(), user: user) : AppViewModel(user: user)
    }
    
    func createAuthViewModel() -> AuthViewModel {
        return testMode ? AuthViewModel(service: MockAuthService()) : AuthViewModel()
    }
    
    func createGeminiViewModel(region: MKCoordinateRegion) -> GeminiViewModel {
        return testMode ? GeminiViewModel(region: region, geminiService: MockGeminiService()) : GeminiViewModel(region: region)
    }
    
    func createLocationViewModel(user: AppUser) -> LocationViewModel {
        return testMode ? LocationViewModel(user: user, coreLocationService: MockCoreLocationService(), mapKitService: MockMapKitService()) : LocationViewModel(user: user)
    }
    
    func createOpenTripMapViewModel() -> OpenTripMapViewModel {
        return testMode ? OpenTripMapViewModel(service: MockOpenTripMapService(), mkService: MockMapKitService()) : OpenTripMapViewModel()
    }
    
    func createSearchTermViewModel() -> SearchTermViewModel {
        return testMode ? SearchTermViewModel(searchTermService: MockSearchTermService()) : SearchTermViewModel()
    }
    
    
}
