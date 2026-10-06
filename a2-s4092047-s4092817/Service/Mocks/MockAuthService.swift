//
//  MockAuthService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 6/10/2026.
//

import Foundation

/// Mock AuthService that does not call Firebase Auth methods. Used in UI Tests
@MainActor
final class MockAuthService : AuthService {
    var currentUser: AppUser? = AppUser(id: "1", username: "Tester", email: "test@email.com")
    
    func signInWithGoogle() async throws -> AppUser {
        return AppUser(id: "1", username: "Tester", email: "test@email.com")
    }
    
    func signOut() throws {
        currentUser = nil
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AppUser {
        let user = AppUser(id: "1", username: "test", email: email)
        currentUser = user
        return user
    }
    
    func signUpWithEmail(email: String, password: String, username: String) async throws -> AppUser {
        let user = AppUser(id: "1", username: username, email: email)
        currentUser = user
        return user

    }
    
    
}
