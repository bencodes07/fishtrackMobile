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
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var name: String = ""
    @State private var type: String = ""
    
    var body: some View {
        VStack {
            HStack () {
                Text("fishtrack.")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.blue)
                    .padding(.leading, 4)
                
                Spacer()
                
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "circle.grid.2x2")
                        .font(.title2)
                        .padding(10)
                        .background(colorScheme == .dark ? .blue.opacity(0.35) : .blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                })
            }
            .padding()
            
            ScrollView(.vertical, showsIndicators: false, content: {
                Text("Add a fish")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Have a new catch? Add it here!")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Name", text: $name)
                        .padding()
                        .background(.gray.opacity(0.15))
                        .cornerRadius(10.0)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    TextField("Fish Type", text: $type)
                        .padding()
                        .background(.gray.opacity(0.15))
                        .cornerRadius(10.0)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    
                    PhotosPicker("Select an Image", selection: $item, matching: .images)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.gray.opacity(0.15))
                        .cornerRadius(10)
                    
                    Button(action: {}, label: {
                        Text("Upload")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 20)
                    })
                }.padding()
            })
        }
//        VStack {
//            Text("Add a new fish")
//            
//            PhotosPicker("select image", selection: $item, matching: .images)
//            
//            Button(action: {
//                Task {
//                    if let item = item {
//                        do {
//                            let photoData = try await item.loadTransferable(type: Data.self)
//                            if let photoData = photoData {
//                                print("Photo data loaded successfully.")
//                                try await FishModel().createItem(name: "Test Name", description: "Description", catch_type: "Type", catch_length: 123, catch_weight: 123, catch_date: "XX.XX.XXXX", catch_location: "Location", uid: appUser!.uid, image: photoData)
//                            } else {
//                                print("Failed to load photo data.")
//                            }
//                        } catch {
//                            print("Error loading photo data: \(error)")
//                        }
//                    }
//                }
//            }, label: {Text("Upload")})
//            ScrollView {
//                LazyVStack {
//                    if fishItems != nil {
//                        ForEach(fishItems!, id: \.image) { fishItem in
//                            AsyncImage(url: URL(string: fishItem.image)) { phase in
//                                switch phase {
//                                case .empty:
//                                    Text("Empty Image")
//                                case .success(let image):
//                                    image.resizable()
//                                         .aspectRatio(contentMode: .fit)
//                                case .failure:
//                                    Image(systemName: "photo").onAppear() {
//                                        print(fishItem.image)
//                                    }
//                                @unknown default:
//                                    Text("Empty View")
//                                }
//                            }
//                            .frame(height: 200)
//                            .cornerRadius(8)
//                            .padding()
//                        }
//                    }
//                }
//            }
//            .onAppear {
//                Task {
//                    if(appUser != nil ) {
//                        do {
//                            fishItems = try await viewModel.fetchItems(userUid: appUser!.uid)
//                        } catch {
//                            print("Error fetching items")
//                        }
//                    }
//                }
//            }
//        }
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
