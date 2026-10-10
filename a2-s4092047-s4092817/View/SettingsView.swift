//
//  SettingsView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 19/9/2026.
//

import SwiftUI

/// View that allows user to log out of the app 
struct SettingsView: View {
    /// AuthViewModel for interacting with Firebase Auth
    @Environment(AuthViewModel.self) var auth: AuthViewModel

    var body: some View {
        VStack {
            
            // MARK: Sign out button
            Button("Sign out") {
                auth.signOut()
            }
            .modifier(ButtonFormat())
        }
    }
}

#Preview {
    SettingsView()
}
