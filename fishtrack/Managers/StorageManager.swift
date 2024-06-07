//
//  StorageManager.swift
//  fishtrack
//
//  Created by Ben Böckmann on 03.06.24.
//

import Foundation
import Supabase

class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    let client = SupabaseClient(supabaseURL: URL(string: "https://vvgxpnjuncthfgvpsurz.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2Z3hwbmp1bmN0aGZndnBzdXJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTcxNjkwNTYsImV4cCI6MjAzMjc0NTA1Nn0.biEGqgzoiAhnOwJzpMKkiJ-96-U-zAAnFKHm1KP7W40")
    
    func uploadFishPhoto(for uid: String, photoData: Data, uuid: String) async throws -> URL {
        let result = try await client.storage.from("images").upload(path: "\(uid)/\(uuid).jpg", file: photoData, options: FileOptions(cacheControl: "3600", contentType: "image/jpg"))
        print(result)
        return try await client.storage.from("images").createSignedURL(path: "\(uid)/\(uuid).jpg", expiresIn: 999999999999999999)
    }
    
    func deleteFishImage(for uid: String, uuid: String) async throws {
        try await client.storage.from("images").remove(paths: ["\(uid)/\(uuid).jpg"])
    }
}
