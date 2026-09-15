//
//  AuthViewModel.swift
//  a2_s4092047-s4092817
//
//  Created by Patrick Ly on 15/9/2026.
//

import Foundation
import FirebaseAuth

///
/// Viewmodel for signing in, signing up and keeping track of signed in user. Taken from Week 8 lectorial code archive.
///
@Observable class AuthViewModel {
    var email: String = ""
    var password: String = ""
    var error: String?
    var isAuthenticated: Bool = Auth.auth().currentUser != nil
    
    var userId: String? { Auth.auth().currentUser?.uid }
    var userEmail: String? { Auth.auth().currentUser?.email }
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = (user != nil)
        }
    }
    
    /// Sign up with email and password
    func signUp() async {
        error = nil
        do {
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    /// Sign in with email and password
    func signIn() async {
        error = nil
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    /// Sign out of account
    func signOut() {
        do { try Auth.auth().signOut() } catch { self.error = error.localizedDescription }
    }
}


