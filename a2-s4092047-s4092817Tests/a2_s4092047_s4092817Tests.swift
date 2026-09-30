//
//  a2_s4092047_s4092817Tests.swift
//  a2_s4092047-s4092817Tests
//
//  Created by Patrick Ly on 10/9/2026.
//

import XCTest
@testable import a2_s4092047_s4092817

enum TestError : Error {
    case signInFail
    case signUpFail
    case signInWithGoogleFail
}

@MainActor
final class FakeAuthService : AuthService {
    let currentUser: AppUser? = AppUser(id: "1", username: "Walter", email: "waltergod@email.com")
    
    var failSignInWithGoogle = false
    
    func signInWithGoogle() async throws -> AppUser {
        if (failSignInWithGoogle) {
            throw TestError.signInWithGoogleFail
        }
        
        return currentUser!
    }
    
    func signOut() throws {
        
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AppUser {
        if (email == "emailOfFail@email.com") {
            throw TestError.signInFail
        }
        return AppUser(id: "1", username: "WalterCool", email: email)
    }
    
    func signUpWithEmail(email: String, password: String, username: String) async throws -> AppUser {
        if (email == "emailOfFail@email.com") {
            throw TestError.signUpFail
        }
        
        
        return AppUser(id: "1", username: username, email: email)
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

    /// Input invalid credentials that should prevent the AuthService's sign up being called leaving authVM's signedInUser as null
    func testSignUpInvalid() async throws {
        authVM = AuthViewModel(service: fakeAuthService, email: "walter", password: "walterpassword", username: "walterthegod")
        await authVM.signUp()
        
        XCTAssertNil(authVM.signedInUser)
    }
    
    /// Use valid credentials that should be reflected in the authVM's signedInUser
    func testSignUpSucceeds() async throws {
        await authVM.signUp()
        
        XCTAssertNil(authVM.error)
        XCTAssertEqual(authVM.signedInUser?.username, "WalterTheBest")
        XCTAssertEqual(authVM.signedInUser?.email, "walter@email.com")
    }
    
    /// Trigger a FakeAuthService error by inputting an email we have hard coded the Fake to throw on. Assert that this error is set in authVM
    func testSignUpError() async throws {
        authVM.email = "emailOfFail@email.com"
        await authVM.signUp()
        
        XCTAssertNil(authVM.signedInUser)
        XCTAssertEqual(authVM.error, "The operation couldn’t be completed. (a2_s4092047_s4092817Tests.TestError error 1.)")

    }
    
    /// Input invalid credentials that should prevent the AuthService's sign in being called leaving authVM's signedInUser as null and error message as such
    func testSignInInvalid() async throws {
        authVM = AuthViewModel(service: fakeAuthService, email: "emailOfFail@email.com", password: "walterpassword", username: "walterthegod")
        await authVM.signIn()
        
        XCTAssertNil(authVM.signedInUser)
        XCTAssertEqual(authVM.error, "Could not find a user with these credentials")
    }
    
    /// Use valid credentials that should be reflected in the authVM's signedInUser
    func testSignInSucceeds() async throws {
        await authVM.signIn()
        
        XCTAssertNil(authVM.error)
        XCTAssertEqual(authVM.signedInUser?.username, "WalterCool")
        XCTAssertEqual(authVM.signedInUser?.email, "walter@email.com")
    }
    
    /// Trigger a FakeAuthService error by setting failSignInWithGoogle to true. Assert that this error is set in authVM
    func testSignInWithGoogleError() async throws {
        fakeAuthService.failSignInWithGoogle = true
        
        await authVM.signInWithGoogle()
        XCTAssertEqual(authVM.error, "The operation couldn’t be completed. (a2_s4092047_s4092817Tests.TestError error 2.)")
    
    }
    
    /// Assert that a successful sign in with Google results in the authVM having its signInUser set
    func testSignInWithGoogleSuccess() async throws {
        await authVM.signInWithGoogle()
        XCTAssertEqual(authVM.signedInUser?.username, "Walter")
        XCTAssertEqual(authVM.signedInUser?.email, "waltergod@email.com")
    }

   

}
