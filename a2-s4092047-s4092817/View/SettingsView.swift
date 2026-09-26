//
//  SettingsView.swift
//  a2-s4092047-s4092817
//
//  Created by Riley Tran on 19/9/2026.
//

import SwiftUI

/// View that allows user to log out of the app (and other settings stuff)
struct SettingsView: View {
    @Environment(AuthViewModel.self) var auth: AuthViewModel

    var body: some View {
        VStack {
            Button("Sign out") {
                auth.signOut()
            }
        }
    }
}

#Preview {
    SettingsView()
}
