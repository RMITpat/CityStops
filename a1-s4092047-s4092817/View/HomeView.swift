//
//  HomeView.swift
//  a1-s4092047-s4092817
//
//  Created by Patrick Ly on 15/9/2026.
//

import SwiftUI

struct HomeView: View {
    @Environment(AuthViewModel.self) var auth: AuthViewModel

    var body: some View {
        @Bindable var auth = auth
        
        Text(auth.userEmail ?? "no email")
        Button("Sign Out") { auth.signOut() }

    }
}

#Preview {
    HomeView()
}
