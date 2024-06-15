//
//  AddFish.swift
//  fishtrack
//
//  Created by Ben Böckmann on 01.06.24.
//

import SwiftUI
import PhotosUI
import UIKit
import Combine
import LocationPicker

struct AddFish: View {
    @State private var image: Image?
    @State private var item: PhotosPickerItem?
    @State private var fishItems: [Fish]?
    @Binding var appUser: AppUser?
    @StateObject var viewModel = FishModel()
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var name: String = ""
    @State private var type: String = ""
    @State private var length: String = ""
    @State private var weight: String = ""
    @State private var description: String = ""
    @State private var date = Date()
    @State private var location: String = ""
    
    @StateObject var locationManager = LocationManager()
    
    @State private var coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var showSheet = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            HStack () {
                Text("fishtrack.")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.blue)
                    .padding(.leading, 4)
                Spacer()
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Name *", text: $name)
                        .padding()
                        .background(.gray.opacity(0.15))
                        .cornerRadius(10.0)
                    TextField("Fish Type *", text: $type)
                        .padding()
                        .background(.gray.opacity(0.15))
                        .cornerRadius(10.0)
                    
                    NumberInputWithSuffix(text: $length, placeholder: "Fish Length *", suffix: "cm")
                    
                    NumberInputWithSuffix(text: $weight, placeholder: "Fish Weight *", suffix: "lb")
                    
                    DatePicker("Select Catch Date", selection: $date, displayedComponents: [.date])
                        .padding()
                        .padding(.vertical, -5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.gray.opacity(0.6))
                        .background(.gray.opacity(0.15))
                        .cornerRadius(10.0)
                        .datePickerStyle(.compact)
                    
                    Button("Select location") {
                        coordinates.latitude = locationManager.latitude
                        coordinates.longitude = locationManager.longitude
                        self.showSheet.toggle()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.gray.opacity(0.15))
                    .foregroundColor(.gray.opacity(0.6))
                    .cornerRadius(10)

                    TextField("Description", text: $description)
                        .padding()
                        .background(.gray.opacity(0.15))
                        .cornerRadius(10.0)
                    
                    PhotosPicker("Select an Image *", selection: $item, matching: .images)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.gray.opacity(0.15))
                        .cornerRadius(10)
                }.padding()
            })
            Button(action: {
                if validateFields() {
                    Task {
                        if let item = item {
                            do {
                                let photoData = try await item.loadTransferable(type: Data.self)
                                if let photoData = photoData {
                                    print("Photo data loaded successfully.")
                                    try await FishModel().createItem(name: name, description: description, catch_type: type, catch_length: length, catch_weight: weight, catch_date: date.ISO8601Format(), catch_location: coordinates.latitude.formatted() + " " + coordinates.longitude.formatted(), uid: appUser!.uid, image: photoData)
                                } else {
                                    print("Failed to load photo data.")
                                }
                            } catch {
                                print("Error loading photo data: \(error)")
                            }
                        }
                    }
                } else {
                    showAlert = true
                }
            }, label: {
                Text("Upload")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                    .padding(.horizontal, 15)
                    .padding(.bottom, 35)
            }).alert(isPresented: $showAlert) {
                Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }.sheet(isPresented: $showSheet) {
            LocationPicker(instructions: "Tap to select coordinates", coordinates: $coordinates, dismissOnSelection: false)
        }
    }
    private func validateFields() -> Bool {
        if name.isEmpty {
            alertMessage = "Please enter the name of the fish."
            return false
        }
        if type.isEmpty {
            alertMessage = "Please enter the type of the fish."
            return false
        }
        if length.isEmpty {
            alertMessage = "Please enter the length of the fish."
            return false
        }
        if weight.isEmpty {
            alertMessage = "Please enter the weight of the fish."
            return false
        }
        if item == nil {
            alertMessage = "Please select an image."
            return false
        }
        return true
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

struct NumberInputWithSuffix: View {
    @Binding var text: String
    let placeholder: String
    let suffix: String
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .onReceive(Just(text)) { newValue in
                    let filtered = newValue.filter { "0123456789,.".contains($0) }
                    if filtered != newValue {
                        self.text = filtered
                    }
                }
                .padding()
            
            Text(suffix)
                .foregroundColor(.gray)
                .padding(.leading, -35)
        }
        .background(Color.gray.opacity(0.15))
        .cornerRadius(10.0)
    }
}
