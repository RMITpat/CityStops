//
//  AuthService.swift
//  a2-s4092047-s4092817
//
//  Created by Patrick Ly on 21/9/2026.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

// Protocol for AuthService
@MainActor
protocol AuthService {
    var currentUser: AppUser? { get }
    func signInWithGoogle() async throws -> AppUser
    func signOut() throws
    func signInWithEmail(email: String, password: String) async throws -> AppUser
    func signUpWithEmail(email: String, password: String, username: String) async throws -> AppUser

}

// Real implementation of AuthService which handles google sign in, sign in and up with email and sign out
@MainActor
final class AuthServiceImpl: AuthService {

    var currentUser: AppUser? {
        guard let user = Auth.auth().currentUser else { return nil }
        return AppUser.fromFirebaseUser(user)
    }
    
    // Starts Google Sign-In, then exchanges the Google token for a Firebase credential.
    func signInWithGoogle() async throws -> AppUser {
        guard FirebaseApp.app() != nil else {
            throw AuthError.misconfigured("Firebase is not configured. Add GoogleService-Info.plist first.")
        }

        guard let viewController = Self.presentingViewController else {
            throw AuthError.misconfigured("Could not find a view controller for Google Sign-In.")
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        let googleUser = result.user

        guard let idToken = googleUser.idToken?.tokenString else {
            throw AuthError.misconfigured("Google did not return an ID token.")
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: googleUser.accessToken.tokenString
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        print(authResult.user.email)
        print(authResult.user.displayName)
        return AppUser.fromFirebaseUser(authResult.user)
    }

    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }
    
    // Starts a sign up with email
    func signUpWithEmail(email: String, password: String, username: String) async throws -> AppUser {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeReq = authResult.user.createProfileChangeRequest()
        changeReq.displayName = username
        
        try await changeReq.commitChanges()
        
        return AppUser.fromFirebaseUser(authResult.user, username: username)
    }
    
    // Starts a sign in with email
    func signInWithEmail(email: String, password: String) async throws -> AppUser {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AppUser.fromFirebaseUser(authResult.user)
    }

    private static var presentingViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    }

    enum AuthError: LocalizedError {
        case misconfigured(String)

        var errorDescription: String? {
            switch self {
            case .misconfigured(let message):
                return message
            }
        }
    }
}
