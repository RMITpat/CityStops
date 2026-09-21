//
//  HomeView.swift
//  a2_s4092047-s4092817
//
//  Created by Patrick Ly on 15/9/2026.
//

import SwiftUI

///
/// Home view for viewing trip feed?
struct HomeView: View {
    @Environment(AuthViewModel.self) var auth: AuthViewModel

    var body: some View {
        @Bindable var auth = auth
        
        VStack {
            Text(auth.userEmail ?? "no email")
            Button("Sign Out") { auth.signOut() }
            Spacer()
            
        //            NavigationLink(destination: CreateTripView()) {
        //
        //                Image(systemName: "plus.capsule.fill").font(.largeTitle)
        //            }
        }
            .navigationTitle("Welcome!")
    }
}

#Preview {
    NavigationStack {
        HomeView().environment(AuthViewModel())
    }
}
