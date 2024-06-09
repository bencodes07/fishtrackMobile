//
//  Home.swift
//  fishtrack
//
//  Created by Ben Böckmann on 31.05.24.
//

import SwiftUI
import LocationPicker
import CoreLocation
import PhotosUI
import UIKit
import Combine

struct Home: View {
    @State var selectedFilter: Category = categories.first!
    @State private var fishItems: [Fish]?
    @Binding var appUser: AppUser?
    @StateObject var viewModel = FishModel()
    @StateObject var locationManager = LocationManager()
    @State private var coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var item: PhotosPickerItem?
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showDetails: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var showLocation: Bool = false
    @State private var showLocationEdit: Bool = false
    @State private var showEdit: Bool = false
    @State private var showEditError: Bool = false
    @State private var selectedFish: Fish?
    @State private var isImagePresented: Bool = false
    
    @State private var name: String = ""
    @State private var type: String = ""
    @State private var length: String = ""
    @State private var weight: String = ""
    @State private var description: String = ""
    @State private var date = Date()
    @State private var location: String = ""
    
    @State private var locationCoordinates: CLLocationCoordinate2D?
    
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
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8, content: {
                            (
                                Text("Track all of your ")
                                +
                                Text("Fish")
                                    .foregroundColor(.blue)
                            )
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.vertical, 20)
                        })
                        
                        Spacer(minLength: 0)
                        
                        VStack {
                            Image("fish")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50)
                        }.frame(width: getRect().width / 3)
                        
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("Filter")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false, content: {
                        HStack(spacing: 15) {
                            ForEach(categories){
                                filter in
                                ZStack {
                                    HStack(spacing: 12) {
                                        Image(systemName: filter.image)
                                            .frame(width: 18, height: 18)
                                            .foregroundColor(filter.id == selectedFilter.id ? .white : .blue)
                                            .padding(2)
                                            .background(filter.id == selectedFilter.id ? Color.blue : colorScheme == .light ? Color.white : Color.black)
                                            .clipShape(Circle())
                                            .matchedGeometryEffect(id: filter.id, in: animationNamespace)
                                        
                                        Text(filter.title)
                                            .fontWeight(.bold)
                                            .font(.body)
                                            .foregroundColor(filter.id == selectedFilter.id ? .white : .blue)
                                    }
                                    .padding(8)
                                    .padding(.trailing, 10)
                                    .background(filter.id == selectedFilter.id ? Color.blue : colorScheme == .light ? Color.white : Color.black)
                                    .clipShape(Capsule())
                                    
                                    Capsule()
                                        .stroke(Color.blue, lineWidth: 2)
                                        .padding(2)
                                        .opacity(filter.id == selectedFilter.id ? 0 : 1)
                                }
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedFilter = filter
                                        applyFilter()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    })
                    
                    Spacer()
                    
                    Text("Your Fish")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("All your fish in one single place.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(minimum: 100, maximum: 250)),
                            GridItem(.flexible(minimum: 100, maximum: 250))], content: {
                                if fishItems != nil && appUser != nil {
                                    ForEach(fishItems!, id: \.image) { fish in
                                        VStack {
                                            AsyncImage(url: URL(string: fish.image)) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                        .frame(maxWidth: getRect().width / 2.2, maxHeight: getRect().width / 2.2 * 0.8)
                                                case .success(let image):
                                                    image.resizable()
                                                        .scaledToFill()
                                                        .frame(maxWidth: getRect().width / 2.2, maxHeight: getRect().width / 2.2 * 0.8)
                                                        .clipped()
                                                        .cornerRadius(20)
                                                case .failure:
                                                    Image(systemName: "photo")
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(maxWidth: getRect().width / 2.2, maxHeight: getRect().width / 2.2 * 0.8)
                                                        .clipped()
                                                        .cornerRadius(20)
                                                @unknown default:
                                                    EmptyView().frame(maxWidth: getRect().width / 2.2, maxHeight: getRect().width / 2.2 * 0.8)
                                                }
                                            }
                                            Text("\(fish.name)")
                                                .fontWeight(.semibold)
                                                .font(.system(size: 18))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(EdgeInsets(top: 2, leading: 4, bottom: 0, trailing: 0))
                                            
                                            HStack() {
                                                Text("\(fish.catch_type)").font(.caption).lineLimit(1)
                                            }
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 10)
                                            .foregroundColor(.blue)
                                            .background(.blue.opacity(0.4))
                                            .cornerRadius(20)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }.padding(.bottom, 10)
                                            .onTapGesture {
                                                selectedFish = fish
                                                showDetails = true
                                            }
                                    }
                                }
                            }).padding(.horizontal)
                    }
                }
            }).onAppear {
                Task {
                    if(appUser != nil ) {
                        do {
                            fishItems = try await viewModel.fetchItems(userUid: appUser!.uid)
                            applyFilter()
                        } catch {
                            print("Error fetching items")
                        }
                    }
                }
            }
            .sheet(isPresented: $showDetails, content: {
                if selectedFish != nil {
                    VStack(spacing: 12) {
                        ZStack(alignment: .topLeading) {
                            HStack {
                                Button(action: {
                                    showDetails = false
                                }, label: {
                                    Image(systemName: "chevron.backward")
                                        .padding()
                                        .clipShape(Circle())
                                })
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                HStack (spacing: 0) {
                                    Button(action: {
                                        setEditSheetValues()
                                        showEdit = true
                                    }, label: {
                                        Image(systemName: "pencil")
                                            .padding()
                                            .clipShape(Circle())
                                            .foregroundColor(.blue)
                                    })
                                    .padding(.vertical)
                                    
                                    Button(action: {
                                        showDeleteConfirm = true
                                    }, label: {
                                        Image(systemName: "trash")
                                            .padding()
                                            .clipShape(Circle())
                                            .foregroundColor(.red)
                                    })
                                    .actionSheet(isPresented: $showDeleteConfirm, content: {
                                        // Delete confirmation
                                        ActionSheet(title: Text("Delete image?"),
                                            message: Text("Are you sure you want to delete the current image"),
                                            buttons: [
                                                .cancel(),
                                                .destructive(
                                                    Text("**Delete image**"),
                                                    action: {
                                                        Task {
                                                            if(appUser != nil ) {
                                                                do {
                                                                    try await viewModel.deleteItem(for: appUser!.uid, uuid: selectedFish!.uuid)
                                                                    showDetails = false
                                                                    showDeleteConfirm = false
                                                                    fishItems = try await viewModel.fetchItems(userUid: appUser!.uid)
                                                                    applyFilter()
                                                                } catch {
                                                                    print("Error Deleting item")
                                                                }
                                                            }
                                                        }
                                                    }
                                                )
                                            ]
                                        )
                                    })
                                    .onDisappear() {
                                        showDeleteConfirm = false
                                    }
                                    .padding(.vertical)
                                    .padding(.trailing)
                                }
                            }
                        }
                        AsyncImage(url: URL(string: selectedFish!.image)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: getRect().width / 1.1, maxHeight: getRect().width / 1.1 * 0.8)
                                    .cornerRadius(20)
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: getRect().width / 1.1, maxHeight: getRect().width / 1.1)
                                    .clipped()
                                    .onTapGesture {
                                        isImagePresented = true
                                    }
                                    .cornerRadius(20)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: getRect().width / 1.1, maxHeight: getRect().width / 1.1)
                                    .clipped()
                                    .cornerRadius(20)
                            @unknown default:
                                EmptyView().frame(maxWidth: getRect().width / 1.2, maxHeight: getRect().width / 1.2 * 0.8)
                            }
                        }.cornerRadius(20)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("**Name**:  \(selectedFish!.name)")
                            Text("**Description**:  \(selectedFish!.description)")
                            Text("**Type**:  \(selectedFish!.catch_type)")
                            Text("**Length**:  \(selectedFish!.catch_length.formatted(.number.precision(.fractionLength(1)))) cm")
                            Text("**Weight**:  \(selectedFish!.catch_weight.formatted(.number.precision(.fractionLength(1)))) lb")
                            Text("**Date**:  \(formatDate(selectedFish!.catch_date))")
                            Text("**Location**: View Location").onTapGesture {
                                showLocation = true
                            }
                        }.sheet(isPresented: $showLocation, content: {
                            // Location Viewer
                            if let selectedFish = selectedFish {
                                let components = selectedFish.catch_location.components(separatedBy: " ")
                                if components.count == 2, let latitude = Double(components[0].replacingOccurrences(of: ",", with: ".")),
                                   let longitude = Double(components[1].replacingOccurrences(of: ",", with: ".")) {
                                    let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                    let constantBinding = Binding<CLLocationCoordinate2D>(
                                        get: { coordinates },
                                        set: { _ in }
                                    )
                                    LocationPicker(instructions: "View your catch Location", coordinates: constantBinding, dismissOnSelection: true)
                                } else {
                                    Text("Invalid location data")
                                }
                            }
                        })
                        .padding()
                        .frame(maxWidth: getRect().width / 1.1, alignment: .leading)
                        .background(.black.opacity(0.05))
                        .cornerRadius(20)
                        Spacer()
                        .fullScreenCover(isPresented: $isImagePresented) {
                            // Full screen image preview
                            if let selectedFish = selectedFish {
                                FullScreenImageView(isPresented: $isImagePresented, imageUrl: URL(string: selectedFish.image)!)
                            }
                        }
                        .sheet(isPresented: $showEdit, content: {
                            VStack(spacing: 12) {
                                ZStack(alignment: .topLeading) {
                                    HStack {
                                        Button(action: { showEdit = false }, label: {
                                            Image(systemName: "chevron.backward")
                                                .padding()
                                                .clipShape(Circle())
                                        })
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        HStack (spacing: 0) {
                                            Button(action: {
                                                saveEdits()
                                            }, label: {
                                                Text("Save")
                                                    .padding()
                                            })
                                            .padding(.vertical)
                                            .padding(.trailing)
                                        }
                                    }
                                }
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Edit Fish Details").font(.title2).fontWeight(.bold)
                                        LabeledContent {
                                            TextField("Name *", text: $name)
                                                .padding()
                                                .background(.gray.opacity(0.15))
                                                .cornerRadius(10.0)
                                        } label: {
                                            Text("Name *").frame(maxWidth: 120, alignment: .leading)
                                        }
                                        
                                        LabeledContent {
                                            TextField("Fish Type *", text: $type)
                                                .padding()
                                                .background(.gray.opacity(0.15))
                                                .cornerRadius(10.0)
                                        } label: {
                                          Text("Fish Type *").frame(maxWidth: 120, alignment: .leading)
                                        }
                                        
                                        LabeledContent {
                                            NumberInputWithSuffix(text: $length, placeholder: "Fish Length *", suffix: "cm")
                                        } label: {
                                          Text("Fish Length *").frame(maxWidth: 120, alignment: .leading)
                                        }
                                        
                                        LabeledContent {
                                            NumberInputWithSuffix(text: $weight, placeholder: "Fish Weight *", suffix: "lb")
                                        } label: {
                                          Text("Fish Weight *").frame(maxWidth: 120, alignment: .leading)
                                        }

                                        LabeledContent {
                                            TextField("Description", text: $description)
                                                .padding()
                                                .background(.gray.opacity(0.15))
                                                .cornerRadius(10.0)
                                        } label: {
                                            Text("Description").frame(maxWidth: 120, alignment: .leading)
                                        }
                                        
                                        Spacer()
                                    }
                                    .alert(isPresented: $showEditError) {
                                        Alert(title: Text("Invalid Inputs"), message: Text("Please fill out all of the required fields"), dismissButton: .default(Text("Okay")))
                                    }
                                    .padding()
                            }
                        })
                    }
                }
            })
        }
    }
    @Namespace private var animationNamespace
    
    private func applyFilter() {
        guard let fishItems = fishItems else { return }
        
        switch selectedFilter.title {
        case "All":
            self.fishItems = fishItems.sorted { $0.created_at > $1.created_at }
        case "Weight":
            self.fishItems = fishItems.sorted { $0.catch_weight > $1.catch_weight }
        case "Length":
            self.fishItems = fishItems.sorted { $0.catch_length > $1.catch_length }
        default:
            break
        }
    }
    
    private func formatDate(_ dateStr: String) -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime]
        
        guard let date = isoDateFormatter.date(from: dateStr) else {
            return "Invalid date"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy | HH:mm"
        dateFormatter.timeZone = TimeZone.current
        
        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
    
    private func setEditSheetValues() {
        if let selectedFish = selectedFish {
            name = selectedFish.name
            type = selectedFish.catch_type
            length = String(selectedFish.catch_length)
            weight = String(selectedFish.catch_weight)
            description = selectedFish.description
        }
    }
        
    private func saveEdits() {
        guard let selectedFish = selectedFish else { return }
        
        if(name.isEmpty || type.isEmpty || length.isEmpty || weight.isEmpty) {
            return showEditError = true
        }
        
        // Update the fish object with the edited values
        let updatedFish = FishPayload(
            name: name,
            description: description,
            catch_type: type,
            catch_length: length,
            catch_weight: weight,
            catch_date: selectedFish.catch_date,
            catch_location: selectedFish.catch_location,
            image: selectedFish.image,
            user_uid: selectedFish.user_uid,
            uuid: selectedFish.uuid
        )
        
        // Save the updated fish object
        Task {
            if(appUser != nil ) {
                do {
                    try await viewModel.editItem(item: updatedFish)
                    showEdit = false
                    showDetails = false
                    fishItems = try await viewModel.fetchItems(userUid: appUser!.uid)
                    applyFilter()
                } catch {
                    print("Error updating item")
                }
            }
        }
    }
}

#Preview {
    Home(appUser: .constant(AppUser(uid: "1234", email: nil)))
}

extension View {
    func getRect()->CGRect {
        return UIScreen.main.bounds
    }
}

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return dateFormatter.date(from: self)
    }
}

struct FullScreenImageView: View {
    @Binding var isPresented: Bool
    var imageUrl: URL
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .pinchToZoom()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 30, height: 30)
                            .tint(.blue)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

extension View {
    func pinchToZoom() -> some View {
        return self.modifier(PinchToZoom())
    }
}

struct PinchToZoom: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .gesture(MagnificationGesture()
                .onChanged { value in
                    let delta = value / self.lastScale
                    self.lastScale = value
                    self.scale *= delta
                }
                .onEnded { value in
                    self.lastScale = 1.0
                }
            )
    }
}
