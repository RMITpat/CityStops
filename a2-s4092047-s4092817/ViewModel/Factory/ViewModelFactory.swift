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
    let arguments: [String]
    
    init(arguments: [String] = []) {
        self.arguments = arguments
    }
    
    func createAppViewModel(user: AppUser) -> AppViewModel {
        if arguments.isEmpty {
            return AppViewModel(user: user)
        }
        
        return AppViewModel(
            service: MockTripService(),
            user: user,
            mkservice: MockMapKitService()
        )
    }
    
    func createAuthViewModel() -> AuthViewModel {
        if arguments.isEmpty {
            return AuthViewModel()
        }
        
        return AuthViewModel(service: MockAuthService())
    }
    
    func createGeminiViewModel(region: MKCoordinateRegion) -> GeminiViewModel {
        if arguments.isEmpty {
            return GeminiViewModel(region: region)
        }
        return GeminiViewModel(region: region, geminiService: MockGeminiService())
    }
    
    func createLocationViewModel(user: AppUser) -> LocationViewModel {
        if arguments.isEmpty {
            return LocationViewModel(user: user)
        }
        return LocationViewModel(user: user, coreLocationService: MockCoreLocationService(), mapKitService: MockMapKitService())
    }
    
    func createOpenTripMapViewModel() -> OpenTripMapViewModel {
        if arguments.isEmpty {
            return OpenTripMapViewModel()
        }
        return OpenTripMapViewModel(service: MockOpenTripMapService(), mkService: MockMapKitService())
    }
    
    func createSearchTermViewModel() -> SearchTermViewModel {
        if arguments.isEmpty {
            return SearchTermViewModel()
        }
        return SearchTermViewModel(searchTermService: MockSearchTermService())
    }
    
    
}
