//
//  SignInViewModel.swift
//  fishtrack
//
//  Created by Ben Böckmann on 01.06.24.
//

import Foundation
import GoogleSignIn

class SignInViewModel: ObservableObject {
    let signInApple = SignInApple()
    
    func createNewUserWithEmail(email: String, password: String) async throws -> AppUser {
        return try await AuthManager.shared.createNewUserWithEmail(email: email, password: password)
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AppUser? {
        return try await AuthManager.shared.signInWithEmail(email: email, password: password)
    }
    
    func signInWithApple() async throws -> AppUser {
        let appleResult = try await signInApple.startSignInWithAppleFlow()
        return try await AuthManager.shared.signInWithApple(idToken: appleResult.idToken, nonce: appleResult.nonce)
    }
    
    func signInWithGoogle() async throws -> AppUser {
        let signInGoogle = SignInGoogle()
        let googleResult = try await signInGoogle.startSignInWithGoogleFlow()
        return try await AuthManager.shared.signInWithGoogle(idToken: googleResult.idToken, nonce: googleResult.nonce)
    }
}
