//
//  ContentView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 19/9/2026.
//

import SwiftUI

// View that handles Navigation of the app.
struct ContentView: View {
    let signedInUser: AppUser
    @State private var locationVM: LocationViewModel
    @State private var appVM: AppViewModel
    
    // Initialise the vm's with the signedInUser's information for their internal use
    init(signedInUser: AppUser) {
        self.signedInUser = signedInUser
        locationVM = LocationViewModel(user: signedInUser)
        appVM = AppViewModel(user: signedInUser)
    }
    
    var body: some View {
        // Bottom nav. bar
        TabView {
            // Home
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            // Create Trip
            NavigationStack {
                CreationChoiceView()
            }
            .tabItem {
                Label("Create Trip", systemImage: "plus")
            }
            
            // Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environment(locationVM)
        .environment(appVM)
    }
}

#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")
    ContentView(signedInUser: user)
        
}
