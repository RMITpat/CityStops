//
//  AuthViewModel.swift
//  a2_s4092047-s4092817
//
//  Created by Patrick Ly on 15/9/2026.
//

import Foundation
import FirebaseAuth

///
/// ViewModel for signing in to the app, signing up, and keeping track of signed in user.
/// Taken from Week 8 lectorial code archive.
///
@Observable class AuthViewModel {
    var email: String = ""
    var password: String = ""
    var error: String?
    var isLoading: Bool = false
    
    private let authService: AuthService

    var signedInUser: User?

    // Real init
    init() {
        let service = AuthServiceImpl()
        self.authService = service
        self.signedInUser = service.currentUser
    }
    
    // Init used by mocks
    init(service: AuthService) {
        self.authService = service
        self.signedInUser = service.currentUser
    }
    
    /// Sign up with email and password
    func signUp()  {
        error = nil
        Task {
            do {
                signedInUser = try await authService.signUpWithEmail(email: email, password: password)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    /// Sign in with email and password
    func signIn() {
        error = nil
        Task {
            do {
                signedInUser = try await authService.signInWithEmail(email: email, password: password)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    
    /// Signs the user in with Google through AuthService.
    func signInWithGoogle() {
        isLoading = true

        Task {
            do {
                signedInUser = try await authService.signInWithGoogle()
            } catch {
                self.error = error.localizedDescription
            }

            self.isLoading = false
        }
    }
    
    /// Sign out of account.
    func signOut() {
        do {
            try authService.signOut()
            signedInUser = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}


