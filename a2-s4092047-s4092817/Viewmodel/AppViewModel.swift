//
//  AppViewModel.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 17/9/2026.
//

import Foundation

enum Route {
    case createTrip
    case createRoute
}

@Observable class AppViewModel {
    
    var path: [Route] = [Route]()
    
    private let tripService: TripService

    // Real init
    init() {
        let service = TripServiceImpl()
        self.tripService = service
    }
    
    // Init used by mock
    init(service: TripService) {
        self.tripService = service
    }
    
    
    
    
    
}
