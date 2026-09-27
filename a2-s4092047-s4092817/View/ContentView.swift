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
    @State private var router: Router = Router()

    // Initialise the vm's with the signedInUser's information for their internal use
    init(signedInUser: AppUser) {
        self.signedInUser = signedInUser
        locationVM = LocationViewModel(user: signedInUser)
        appVM = AppViewModel(user: signedInUser)
    }
    
    var body: some View {
        // Bottom nav. bar
        TabView(selection: $router.selectedTab) {
            // Home
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppTab.home)
            
            // Create Trip
                CreationChoiceView()
                 
            
            .tabItem {
                Label("Create Trip", systemImage: "plus")
            }
            .tag(AppTab.create)

            
            // Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(AppTab.settings)

        }
        .environment(locationVM)
        .environment(appVM)
        .environment(router)
    }
}

#Preview {
    let user = AppUser(id: "Test", email: "test@email.com")
    ContentView(signedInUser: user)
        
}
