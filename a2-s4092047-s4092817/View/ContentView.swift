//
//  ContentView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 19/9/2026.
//

import SwiftUI
import SwiftData

// View that handles Navigation of the app.
struct ContentView: View {
    let signedInUser: AppUser
    @Environment(\.modelContext) private var modelContext

    
    @State private var locationVM: LocationViewModel
    @State private var appVM: AppViewModel
    @State private var router: Router = Router()
    @State private var searchTermVM: SearchTermViewModel = SearchTermViewModel()

    // Initialise the vm's with the signedInUser's information for their internal use
    init(signedInUser: AppUser, vmFactory: ViewModelFactory) {
        self.signedInUser = signedInUser
        
        _locationVM = State(initialValue: vmFactory.createLocationViewModel(user: signedInUser))
        _appVM = State(initialValue: vmFactory.createAppViewModel(user: signedInUser))
        _searchTermVM = State(initialValue: vmFactory.createSearchTermViewModel())
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
            
            // Profile
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(AppTab.profile)

        }
        .environment(locationVM)
        .environment(appVM)
        .environment(router)
        .environment(searchTermVM)
        .task {
            searchTermVM.attach(modelContext: modelContext)
        }
     
    }
}

#Preview {
    let user = AppUser(id: "Test", username: "test", email: "test@email.com")
    ContentView(signedInUser: user, vmFactory: ViewModelFactory())
        
}
