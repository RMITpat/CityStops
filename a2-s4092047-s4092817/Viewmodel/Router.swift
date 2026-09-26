//
//  Router.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 26/9/2026.
//

import SwiftUI
import Observation

// MARK: - Routing Enums

/// Represents the different root tabs in the application
enum AppTab: Hashable {
    case home
    case create
    case settings
}

/// Represents the destination views within the Trip Creation navigation stack
enum TripCreationRoute: Hashable {
    case name
    case preferences
    case createTrip
    case createRoute
}

// MARK: - Router Class

/// Centralized navigation manager that controls both Tab selection and NavigationStack paths
@Observable
class Router {
    
    // MARK: Properties
    
    /// The currently selected tab in the MainTabView
    var selectedTab: AppTab = .home
    
    /// The navigation stack path for the Create Trip flow
    var tripCreationRoute = NavigationPath()
    
}
