//
//  ContentView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 19/9/2026.
//

import SwiftUI

// View that handles Navigation of the app.
struct ContentView: View {
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
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
        .environment(LocationViewModel())
}
