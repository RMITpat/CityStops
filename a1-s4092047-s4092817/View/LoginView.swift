//
//  LoginView.swift
//  a1-s4092047-s4092817
//
//  Created by Patrick Ly on 10/9/2026.
//

import SwiftUI

struct LoginView: View {
    @State private var isSigningUp = false

    @Environment(AuthViewModel.self) var auth: AuthViewModel

    var body: some View {
        @Bindable var auth = auth
        
        VStack(spacing: 24) {
            Text(isSigningUp ? "Create Account" : "Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("Email", text: $auth.email)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                SecureField("Password", text: $auth.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

            
            }
            
            if let error = auth.error {
                Text(error).foregroundColor(.red).font(.footnote)
            }

            Button(action: {
                if isSigningUp {
                    Task { await auth.signUp() }
                } else {
                    Task { await auth.signIn() }
                }
            }) {
                Text(isSigningUp ? "Sign Up" : "Log In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            Button(action: {
                isSigningUp.toggle()
            }) {
                Text(
                    isSigningUp
                    ? "Already have an account? Log In"
                    : "Don't have an account? Sign Up"
                )
                .font(.footnote)
            }
        }
        .padding(24)
    }
}

#Preview {
    LoginView()
}
