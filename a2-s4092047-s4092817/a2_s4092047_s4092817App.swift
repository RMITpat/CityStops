//
//  a2_s4092047_s4092817App.swift
//  a2_s4092047-s4092817
//
//  Created by Patrick Ly on 10/9/2026.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import SwiftData
import FirebaseAppCheck

/// App entry point.
@main
struct a2_s4092047_s4092817App: App {
    @State private var vmFactory: ViewModelFactory
    
    @State private var authVM: AuthViewModel

    
    init() {
        let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        
        FirebaseApp.configure()
        
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration =
            GIDConfiguration(clientID: clientID)
        } else {
            print("Firebase client ID could not be found.")
        }
        
        #if DEBUG
        let testMode = ProcessInfo.processInfo.arguments.contains("-ENABLE-MOCK-DATA")
        let factory = ViewModelFactory(testMode: testMode)
        
        #else
        let factory = ViewModelFactory()
        #endif
        vmFactory = factory
        _authVM = State(
            initialValue: factory.createAuthViewModel()
        )
    }
    
    var body: some Scene {
        // MARK: Login Entry point
        WindowGroup {
            if let user = authVM.signedInUser {
                ContentView(signedInUser: user, vmFactory: vmFactory)
            } else {
                LoginView()
                    .onOpenURL { url in
                    // Handles the redirect back from Google Sign-In.
                    GIDSignIn.sharedInstance.handle(url)
                }
            }
        }
        .environment(authVM)
        .environment(vmFactory)
        .modelContainer(for: SearchTerm.self)

        
    }
}
