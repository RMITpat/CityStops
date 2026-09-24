//
//  HomeView.swift
//  a2_s4092047-s4092817
//
//  Created by Patrick Ly on 15/9/2026.
//

import SwiftUI
///
/// Home view for viewing trip feed.
/// Implements ``AuthViewModel`` to allow sign out (needs to be moved into settings)
// TODO: MOVE SIGN OUT TO SETTINGS PAGE
struct HomeView: View {
    @Environment(AuthViewModel.self) var auth: AuthViewModel
    
    var body: some View {
        @Bindable var auth = auth
        
        VStack {
            Text(auth.signedInUser?.email ?? "no email")
            Button("Sign Out") { auth.signOut() }
            Spacer()

        }
            .navigationTitle("Welcome!")
    }
}

#Preview {
    NavigationStack {
        HomeView().environment(AuthViewModel())
    }
}
