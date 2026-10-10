//
//  AppUser.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 23/9/2026.
//

import Foundation
import FirebaseAuth


/// Simple version of user, so that other files don't have to pull in Firebase dependencies.
struct AppUser {
    let id: String
    let username: String
    let email: String
    
    /// Converts Firebase's User into our simpler app model.
    static func fromFirebaseUser(_ user: User) -> AppUser {
        
        return AppUser(
            id: user.uid,
            username: user.displayName ?? "",
            email: user.email ?? ""
        )
    }
    
    /// Overload for when users sign up with email and password instead of with Google.
    static func fromFirebaseUser(_ user: User, username: String) -> AppUser {
        
        return AppUser(
            id: user.uid,
            username: username,
            email: user.email ?? ""
        )
    }
}
