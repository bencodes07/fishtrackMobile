//
//  AuthManager.swift
//  fishtrack
//
//  Created by Ben Böckmann on 01.06.24.
//

import Foundation
import Supabase

struct AppUser {
    let uid: String
    let email: String?
}

class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    let client = SupabaseClient(supabaseURL: URL(string: "https://vvgxpnjuncthfgvpsurz.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2Z3hwbmp1bmN0aGZndnBzdXJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTcxNjkwNTYsImV4cCI6MjAzMjc0NTA1Nn0.biEGqgzoiAhnOwJzpMKkiJ-96-U-zAAnFKHm1KP7W40")
    
    func getCurrentSession() async throws -> AppUser {
        let session = try await client.auth.session
        print(session)
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    func signInWithApple(idToken: String, nonce: String) async throws -> AppUser {
        let session = try await client.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: idToken, nonce: nonce))
        print("Signed In!")
        print(session)
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    func signInWithGoogle(idToken: String) async throws -> AppUser {
        let session = try await client.auth.signInWithIdToken(credentials: .init(provider: .google, idToken: idToken))
        print("Signed In!")
        print(session)
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
}
