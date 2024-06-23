//
//  FishModel.swift
//  fishtrack
//
//  Created by Ben Böckmann on 03.06.24.
//

import Foundation

struct Fish: Decodable, Identifiable {
    let name: String
    let description: String
    
    let catch_type: String
    let catch_length: Float
    let catch_weight: Float
    let catch_date: String
    let catch_location: String
    let image: String
    let tags: [String]
    
    let user_uid: String
    let uuid: String
    let id: Int
    let created_at: String
}

struct FishPayload: Codable {
    let name: String
    let description: String
    
    let catch_type: String
    let catch_length: String
    let catch_weight: String
    let catch_date: String
    let catch_location: String
    let image: String?
    let tags: [String]
    
    let user_uid: String
    let uuid: String
}

class FishModel: ObservableObject {
    @Published var fish = [Fish]()
    
    var mockData: [Fish] = []
    
    func createItem(
        name: String,
        description: String,
        catch_type: String,
        catch_length: String,
        catch_weight: String,
        catch_date: String,
        catch_location: String,
        uid: String,
        image: Data) async throws {
            let uuid = UUID().uuidString
            do {
                try await DatabaseManager.shared.createFishItem(
                    item:
                        FishPayload(
                            name: name,
                            description: description,
                            catch_type: catch_type,
                            catch_length: catch_length,
                            catch_weight: catch_weight,
                            catch_date: catch_date,
                            catch_location: catch_location,
                            image: nil,
                            tags: [""],
                            user_uid: uid,
                            uuid: uuid
                        )
                )
                print("Fish item created in database.")
                
                let downloadURL = try await StorageManager.shared.uploadFishPhoto(for: uid, photoData: image, uuid: uuid)
                print("Image uploaded successfully. URL: \(downloadURL)")
                
                try await DatabaseManager.shared.updateFishImage(imageUrl: downloadURL, uuid: uuid)
                print("Fish item updated with image URL in database.")
            } catch {
                print("Error in createItem: \(error)")
                throw error
            }
    }
    
    func deleteItem(for uid: String, uuid: String) async throws {
        try await StorageManager.shared.deleteFishImage(for: uid, uuid: uuid)
        print("Fish Image deleted")
        try await DatabaseManager.shared.deleteFishItem(uuid: uuid)
        print("Fish Item deleted")
    }
    
    func fetchItems(userUid: String) async throws -> [Fish] {
        let fish = try await DatabaseManager.shared.fetchFishItems(for: userUid)
        return fish
    }
    
    func fetchTagsForFish(for uuid: String) async throws -> [Tag] {
        return try await DatabaseManager.shared.fetchTagsForFish(for: uuid)
    }
    
    func editItem(item: FishPayload) async throws {
        try await DatabaseManager.shared.editFishItem(item: item)
    }
    
    func addTagToFish(fishId: String, tagId: String) async throws -> [Tag] {
        return try await DatabaseManager.shared.addTagToFish(fishId: fishId, tagId: tagId)
    }
    
    func removeTagFromFish(fishId: String, tagId: String) async throws -> [Tag] {
        return try await DatabaseManager.shared.removeTagFromFish(fishId: fishId, tagId: tagId)
    }
}
