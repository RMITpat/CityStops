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


    func testSignUpInvalid() async throws {
        authVM = AuthViewModel(service: fakeAuthService, email: "walter", password: "walterpassword", username: "walterthegod")
        await authVM.signUp()
        
        XCTAssertNil(authVM.signedInUser)
    }
    
    func testSignUpSucceeds() async throws {
        await authVM.signUp()
        
        XCTAssertNil(authVM.error)
        XCTAssertEqual(authVM.signedInUser?.username, "WalterTheBest")
        XCTAssertEqual(authVM.signedInUser?.email, "walter@email.com")
    }
    
    func testSignUpError() async throws {
        authVM.email = "emailOfFail@email.com"
        await authVM.signUp()
        
        XCTAssertNil(authVM.signedInUser)
        XCTAssertEqual(authVM.error, "The operation couldn’t be completed. (a2_s4092047_s4092817Tests.TestError error 1.)")

    }
    
    
    func testSignInInvalid() async throws {
        authVM = AuthViewModel(service: fakeAuthService, email: "emailOfFail@email.com", password: "walterpassword", username: "walterthegod")
        await authVM.signIn()
        
        XCTAssertNil(authVM.signedInUser)
        XCTAssertEqual(authVM.error, "Could not find a user with these credentials")
    }
    
    func testSignInSucceeds() async throws {
        await authVM.signIn()
        
        XCTAssertNil(authVM.error)
        XCTAssertEqual(authVM.signedInUser?.username, "WalterCool")
        XCTAssertEqual(authVM.signedInUser?.email, "walter@email.com")
    }
    
    func testSignInWithGoogleError() async throws {
        fakeAuthService.failSignInWithGoogle = true
        
        await authVM.signInWithGoogle()
        XCTAssertEqual(authVM.error, "The operation couldn’t be completed. (a2_s4092047_s4092817Tests.TestError error 2.)")
    
    }
    
    func testSignInWithGoogleSuccess() async throws {
        await authVM.signInWithGoogle()
        XCTAssertEqual(authVM.signedInUser?.username, "Walter")
        XCTAssertEqual(authVM.signedInUser?.email, "waltergod@email.com")
    }

   

}
