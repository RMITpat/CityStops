//
//  AuthViewModel.swift
//  a2_s4092047-s4092817
//
//  Created by Patrick Ly on 15/9/2026.
//

import Foundation

///
/// ViewModel for signing in to the app, signing up, and keeping track of signed in user.
/// Taken from Week 8 lectorial code archive.
///
@Observable class AuthViewModel {
    var email: String = ""
    var password: String = ""
    var error: String?
    var isLoading: Bool = false
    var username: String = ""
    
    private let authService: AuthService

    var signedInUser: AppUser?

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
        
        if !validateSignUp(email: email, password: password, username: username) {
            return
        }
        Task {
            do {
                signedInUser = try await authService.signUpWithEmail(email: email, password: password, username: username)
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
    
    func validateSignUp(email: String, password: String, username: String) -> Bool {
        var errorString = ""
        if email.wholeMatch(of: /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/) == nil {
            errorString += "Email must match x@x.xx\n"
        }
        
        if username.isEmpty {
            errorString += "Username cannot be empty\n"
        }
        
        if password.wholeMatch(of:/^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$/) == nil {
            errorString += "Password must be 8 characters, have at least one uppercase letter, one digit and one special character\n"
        }
        
        if !errorString.isEmpty {
            error = errorString
            return false
        }
        error = nil

        return true
        
    }
    
    func resetError() {
        error = nil
    }
}


