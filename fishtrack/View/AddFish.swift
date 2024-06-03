//
//  AddFish.swift
//  fishtrack
//
//  Created by Ben Böckmann on 01.06.24.
//

import SwiftUI
import PhotosUI
import UIKit

struct AddFish: View {
    @State private var image: Image?
    @State private var item: PhotosPickerItem?
    @State private var fishItems: [Fish]?
    @Binding var appUser: AppUser?
    @StateObject var viewModel = FishModel()
    
    var body: some View {
        VStack {
            Text("Add a new fish")
            
            PhotosPicker("select image", selection: $item, matching: .images)
            
            Button(action: {
                Task {
                    if let item = item {
                        do {
                            let photoData = try await item.loadTransferable(type: Data.self)
                            if let photoData = photoData {
                                print("Photo data loaded successfully.")
                                try await FishModel().createItem(name: "Test Name", description: "Description", catch_type: "Type", catch_length: 123, catch_weight: 123, catch_date: "XX.XX.XXXX", catch_location: "Location", uid: appUser!.uid, image: photoData)
                            } else {
                                print("Failed to load photo data.")
                            }
                        } catch {
                            print("Error loading photo data: \(error)")
                        }
                    }
                }
            }, label: {Text("Upload")})
            ScrollView {
                LazyVStack {
                    if fishItems != nil {
                        ForEach(fishItems!, id: \.image) { fishItem in
                            AsyncImage(url: URL(string: fishItem.image)) { phase in
                                switch phase {
                                case .empty:
                                    Text("Empty Image")
                                case .success(let image):
                                    image.resizable()
                                         .aspectRatio(contentMode: .fit)
                                case .failure:
                                    Image(systemName: "photo").onAppear() {
                                        print(fishItem.image)
                                    }
                                @unknown default:
                                    Text("Empty View")
                                }
                            }
                            .frame(height: 200)
                            .cornerRadius(8)
                            .padding()
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        fishItems = try await viewModel.fetchItems(userUid: appUser!.uid)
                    } catch {
                        print("Error fetching items")
                    }
                }
            }
        }
    }
}

#Preview {
    AddFish(appUser: .constant(AppUser(uid: "1234", email: "boeckmannben@gmail.com")))
}

extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}
