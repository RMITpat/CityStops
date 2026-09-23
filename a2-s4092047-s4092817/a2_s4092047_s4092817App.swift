//
//  a2_s4092047_s4092817App.swift
//  a2_s4092047-s4092817
//
//  Created by Patrick Ly on 10/9/2026.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

/// App entry point.
@main
struct a2_s4092047_s4092817App: App {
    @State private var authVM: AuthViewModel

    
    init() {
            FirebaseApp.configure()
            
            if let clientID = FirebaseApp.app()?.options.clientID {
                GIDSignIn.sharedInstance.configuration =
                GIDConfiguration(clientID: clientID)
            } else {
                print("Firebase client ID could not be found.")
            }

            _authVM = State(
                initialValue: AuthViewModel()
            )
        }
    
    var body: some Scene {
        // MARK: Login Entry point
        WindowGroup {
            if let user = authVM.signedInUser {
                ContentView(signedInUser: user)
            } else {
                LoginView()
                    .onOpenURL { url in
                    // Handles the redirect back from Google Sign-In.
                    GIDSignIn.sharedInstance.handle(url)
                }
            }
        }
        .environment(authVM)
        
    }
}
