//
//  a2_s4092047_s4092817App.swift
//  a2_s4092047-s4092817
//
//  Created by Patrick Ly on 10/9/2026.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct a2_s4092047_s4092817App: App {
    @State private var authVM: AuthViewModel

    init() {
            FirebaseApp.configure()

            _authVM = State(
                initialValue: AuthViewModel()
            )
        }
    
    var body: some Scene {
        WindowGroup {
            if (authVM.isAuthenticated) {
                HomeView()
            } else {
                LoginView()
            }
        }.environment(authVM)
    }
}
