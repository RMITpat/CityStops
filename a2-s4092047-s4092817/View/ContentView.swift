//
//  ContentView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 19/9/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
        
            CreateTripView()
                .tabItem {
                    Label("Create Trip", systemImage: "plus")
                }

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
