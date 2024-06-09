//
//  DatabaseManager.swift
//  fishtrack
//
//  Created by Ben Böckmann on 03.06.24.
//

import Foundation
import Supabase

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init() {}
    
    let client = SupabaseClient(supabaseURL: URL(string: "https://vvgxpnjuncthfgvpsurz.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2Z3hwbmp1bmN0aGZndnBzdXJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTcxNjkwNTYsImV4cCI6MjAzMjc0NTA1Nn0.biEGqgzoiAhnOwJzpMKkiJ-96-U-zAAnFKHm1KP7W40")
    
    func createFishItem(item: FishPayload) async throws {
        try await client.from("fish").insert(item).execute()
    }
    
    func updateFishImage(imageUrl: URL, uuid: String) async throws {
        try await client.from("fish").update(["image": imageUrl]).eq("uuid", value: uuid).execute()
    }
    
    func editFishItem(item: FishPayload) async throws {
        try await client.from("fish").update(item).eq("uuid", value: item.uuid).execute()
    }
    
    func deleteFishItem(uuid: String) async throws {
        try await client.from("fish").delete().eq("uuid", value: uuid).execute()
    }
    
    func fetchFishItems(for uid: String) async throws -> [Fish] {
        let fish: [Fish] = try await client.from("fish").select().equals("user_uid", value: uid).order("created_at", ascending: false).execute().value
        print(fish)
        return fish
    }
}
