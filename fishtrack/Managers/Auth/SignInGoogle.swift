//
//  SignInGoogle.swift
//  fishtrack
//
//  Created by Ben Böckmann on 01.06.24.
//

import CryptoKit
import UIKit
import GoogleSignIn

struct SignInGoogleResult {
    let idToken: String
    let nonce: String
}

class SignInGoogle {
    private var currentNonce: String?
    private var completionHandler: ((Result<SignInGoogleResult, Error>) -> Void)?
    
    func startSignInWithGoogleFlow() async throws -> SignInGoogleResult {
        try await withCheckedThrowingContinuation({ [weak self] continuation in
            self?.signInWithGoogleFlow { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func signInWithGoogleFlow(completion: @escaping (Result<SignInGoogleResult, Error>) -> Void) {
        guard let topVC = UIApplication.getTopViewController() else {
            completion(.failure(NSError()))
            return
        }
        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        GIDSignIn.sharedInstance.signIn(
            withPresenting: topVC) { signInResult, error in
                guard let user = signInResult?.user, let idToken = user.idToken else {
                    return
                }
                completion(.success(.init(idToken: idToken.tokenString, nonce: self.sha256(nonce))))
            }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}
