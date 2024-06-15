//
//  DatabaseManager.swift
//  fishtrack
//
//  Created by Ben Böckmann on 03.06.24.
//

import Foundation
import Supabase

struct TagPayload: Codable {
    let text: String
    let uid: String
}

struct Tag: Decodable, Identifiable, Hashable {
    let text: String
    let id: String
    let uid: String
    let created_at: String
}

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
    
    
    func createTag(item: TagPayload) async throws {
        try await client.from("tags").insert(item).execute()
    }
    
    func fetchTags(for uid: String) async throws -> [Tag] {
        return try await client.from("tags").select().equals("uid", value: uid).order("created_at", ascending: false).execute().value
    }
    
    func fetchTagById(id: String) async throws -> Tag {
        return try await client.from("tags").select().equals("id", value: id).execute().value
    }
}
