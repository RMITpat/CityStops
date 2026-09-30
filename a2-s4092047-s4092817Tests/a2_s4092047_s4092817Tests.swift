//
//  a2_s4092047_s4092817Tests.swift
//  a2_s4092047-s4092817Tests
//
//  Created by Patrick Ly on 10/9/2026.
//

import XCTest
@testable import a2_s4092047_s4092817

@MainActor
final class FakeAuthService : AuthService {
    let currentUser: AppUser? = AppUser(id: "1", username: "Walter", email: "waltergod@email.com")
    var signInWithGoogleCalled: Bool = false
    var signInWithEmailCalled: Bool = false
    var signUpWithEmailCalled: Bool = false
    var signOutCalled: Bool = false
    
    func signInWithGoogle() async throws -> AppUser {
        signInWithGoogleCalled = true
        return currentUser!
    }
    
    func signOut() throws {
        signOutCalled = true
        
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AppUser {
        signInWithEmailCalled = true
        return currentUser!
    }
    
    func signUpWithEmail(email: String, password: String, username: String) async throws -> AppUser {
        signUpWithEmailCalled = true
        return currentUser!
    }
    
    
}

@MainActor
final class a2_s4092047_s4092817Tests: XCTestCase {
    var authVM: AuthViewModel!
    var fakeAuthService: FakeAuthService!
    
    // By default initialise authVM with valid credentials. Set it manually in test to test invalid credentials
    override func setUpWithError() throws {
        let validEmail = "walter@email.com"
        let validPassword = "WalterGod67@"
        let validUsername = "WalterTheBest"
        fakeAuthService = FakeAuthService()
        authVM = AuthViewModel(service: fakeAuthService, email: validEmail, password: validPassword, username: validUsername)
    }


    func testSignUpFails() async throws {
        authVM = AuthViewModel(service: fakeAuthService, email: "walter", password: "walterpassword", username: "walterthegod")
        await authVM.signUp()
        
        XCTAssertFalse(fakeAuthService.signUpWithEmailCalled)
    }
    
    func testSignUpSucceeds() async throws {
        await authVM.signUp()
        
        XCTAssertTrue(fakeAuthService.signUpWithEmailCalled)
    }

   

}
