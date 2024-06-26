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
import MapKit
import Combine

struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct Home: View {
    @State var selectedFilter: Category = categories.first!
    @State private var fishItems: [Fish]?
    @State private var originalFishItems: [Fish]?
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
    
    @State private var showTags: Bool = false
    @State private var showTagsAdd: Bool = false
    @State private var showTagPopover: Bool = false
    @State private var tags: [Tag] = []
    @State var selection = Set<Int>()
    let items = [1, 4, 6, 8, 9]
    @State private var selectedTags: [Tag] = []
    @State private var newTagName: String = ""
    
    @State private var selectedFish: Fish?
    @State private var selectedFishTags: [Tag] = []
    @State private var isImagePresented: Bool = false
    
    @State private var showSearchbar: Bool = false
    @FocusState var searchFocused: Bool
    @State private var searchValue: String = ""
    
    @State private var name: String = ""
    @State private var type: String = ""
    @State private var length: String = ""
    @State private var weight: String = ""
    @State private var description: String = ""
    @State private var date = Date()
    @State private var location: String = ""
    
    @State private var locationCoordinates: CLLocationCoordinate2D?
    @State var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        )
        @State var markerCoordinate = IdentifiableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))

    
    @ViewBuilder
    func TagView(_ tag: String, _ color: Color, _ icon: String) -> some View {
        HStack (spacing: 10) {
            Text(tag)
                .font(.callout)
                .fontWeight(.semibold)
            
            Image(systemName: icon)
        }
        .frame(height: 35)
        .foregroundStyle(.white)
        .padding(.horizontal, 15)
        .background {
            if icon == "checkmark" {
                Capsule().fill(color.gradient)
            } else {
                Capsule().fill(color)
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack () {
                    Text("fishtrack.")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.blue)
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    Button(action: { showTags = true }, label: {
                        Image(systemName: "tag")
                            .font(.title3)
                            .padding(.trailing)
                            .foregroundColor(.blue)
                    })
                    .sheet(isPresented: $showTags, content: {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack {
                                ZStack(alignment: .topLeading) {
                                    HStack {
                                        Button(action: {
                                            showTags = false
                                        }, label: {
                                            Image(systemName: "chevron.backward")
                                                .padding()
                                                .clipShape(Circle())
                                        })
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        Button(action: {
                                            newTagName = ""
                                            showTagsAdd = true
                                        }, label: {
                                            Image(systemName: "plus.circle.fill")
                                                .padding()
                                                .font(.title2)
                                                .clipShape(Circle())
                                                .foregroundColor(.blue)
                                        })
                                        .alert("Create a new Tag", isPresented: $showTagsAdd) {
                                            TextField(text: $newTagName.max(25)) {}
                                            Button("Cancel") {
                                                showTagsAdd = false
                                            }
                                            Button("Submit") {
                                                if newTagName != "" {
                                                    Task {
                                                        if(appUser != nil ) {
                                                            do {
                                                                try await DatabaseManager.shared.createTag(item: TagPayload(text: newTagName, uid: appUser!.uid))
                                                            } catch {
                                                                print("Error creating tag: \(error)")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        } message: {
                                            Text("Enter new Tag name (Max. 25 Characters)")
                                        }
                                    }
                                    .padding(.top)
                                    .padding(.horizontal)
                                }
                                
                                ScrollView(.horizontal) {
                                    HStack (spacing: 12) {
                                        ForEach(selectedTags, id: \.self) { tag in
                                            TagView(tag.text, .blue, "checkmark")
                                                .matchedGeometryEffect(id: tag, in: animationNamespace)
                                                .onTapGesture {
                                                    let impactMed = UIImpactFeedbackGenerator(style: .soft)
                                                    impactMed.impactOccurred()
                                                    withAnimation(.snappy) {
                                                        selectedTags.removeAll(where: { $0.text == tag.text })
                                                    }
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 0)
                                    .background(colorScheme == .light ? .white : .black)
                                }
                                .scrollDisabled(true)
                                .scrollIndicators(.hidden)
                                .overlay(content: {
                                    if selectedTags.isEmpty {
                                        Text("No tags selected. Showing all catches")
                                            .font(.callout)
                                            .foregroundStyle(.gray)
                                            .padding(.bottom)
                                    }
                                })
                            }
                            .background(colorScheme == .light ? .white : .black)
                            .zIndex(1)
                            
                            ScrollView(.vertical) {
                                TagLayout(alignment: .center, spacing: 10) {
                                    ForEach(tags.filter { !selectedTags.contains($0) }, id: \.self) { tag in
                                        TagView(tag.text, .blue.opacity(0.75), "plus")
                                            .matchedGeometryEffect(id: tag, in: animationNamespace)
                                            .onTapGesture {
                                                let impactMed = UIImpactFeedbackGenerator(style: .soft)
                                                impactMed.impactOccurred()
                                                withAnimation(.snappy) {
                                                    selectedTags.insert(tag, at: 0)
                                                }
                                            }
                                            .zIndex(0)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    Task {
                                                        if(appUser != nil) {
                                                            do {
                                                                tags = try await viewModel.deleteTag(tagId: tag.id, uid: appUser!.uid)
                                                            } catch {
                                                                print("Error deleting tag: \(error)")
                                                            }
                                                        }
                                                    }
                                                } label: {
                                                    Label("Delete Tag", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                                .padding(15)
                            }
                            .scrollClipDisabled(true)
                            .scrollIndicators(.hidden)
                            .background(colorScheme == .light ? .black.opacity(0.03) : .white.opacity(0.05))
                            .zIndex(0)
                            
                            ZStack {
                                Button(action: {
                                    Task {
                                        if appUser != nil {
                                            do {
                                                if selectedTags == [] {
                                                    fishItems = originalFishItems
                                                } else {
                                                    let allFishItems = try await viewModel.fetchItems(userUid: appUser!.uid)
                                                    fishItems = filterFishItems(allFishItems, withTags: selectedTags)
                                                }
                                                showTags = false
                                            } catch {
                                                print(error)
                                            }
                                        }
                                    }
                                }, label: {
                                    VStack (spacing: 8) {
                                        Text("Filter by Tags")
                                            .fontWeight(.semibold)
                                            .padding(.vertical, 15)
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.white)
                                            .background {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.blue)
                                            }
                                        
                                        Text("A shown fish will contain at least 1 selected tag")
                                            .font(.footnote)
                                            .foregroundStyle(.gray)
                                    }
                                })
                                .padding()
                            }
                            .background(colorScheme == .light ? .white : .black)
                            .zIndex(2)
                            
                        }.background(colorScheme == .light ? .white : .black)
                    }).onAppear() {
                        Task {
                            if(appUser != nil ) {
                                do {
                                    tags = try await DatabaseManager.shared.fetchTags(for: appUser!.uid)
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    }
                    Button(action: {
                        withAnimation(.snappy) {
                            showSearchbar.toggle()
                            if showSearchbar {
                                searchFocused = true
                            } else {
                                searchValue = ""
                                searchImages(searchValue)
                            }
                        }
                    }, label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .padding(10)
                            .background(colorScheme == .dark ? .blue.opacity(0.35) : .blue.opacity(0.12))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    })
                }
                .padding()
                
                if showSearchbar {
                    TextField("Search", text: $searchValue)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10.0)
                        .padding()
                        .focused($searchFocused)
                        .onSubmit {
                            searchFocused = false
                        }
                        .onChange(of: searchValue) {
                            searchImages(searchValue)
                        }
                }
            }
            
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
                                    let impactMed = UIImpactFeedbackGenerator(style: .soft)
                                    impactMed.impactOccurred()
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
                                                let impactMed = UIImpactFeedbackGenerator(style: .soft)
                                                impactMed.impactOccurred()
                                                selectedFish = fish
                                                selectedFishTags = []
                                                Task {
                                                    if(selectedFish != nil ) {
                                                        do {
                                                            selectedFishTags = try await viewModel.fetchTagsForFish(for: selectedFish!.uuid)
                                                        } catch {
                                                            print("Error Fetching Tags: \(error)")
                                                        }
                                                    }
                                                }
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
                            selectedTags = []
                            originalFishItems = fishItems
                            applyFilter()
                        } catch {
                            print("Error fetching items: \(error)")
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
                                                                    originalFishItems = fishItems
                                                                    selectedTags = []
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
                                    .frame(maxWidth: .infinity)
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(height: getRect().height / 2.8)
                                    .onTapGesture {
                                        isImagePresented = true
                                    }
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                            @unknown default:
                                EmptyView().frame(maxWidth: .infinity)
                            }
                        }.overlay (alignment: .bottomLeading, content: {
                            Text(selectedFish!.name)
                                .font(.title)
                                .foregroundStyle(.thickMaterial)
                                .fontWeight(.bold)
                                .padding()
                        })
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack {
                                    Image(systemName: "ruler")
                                    Text("132")
                                }
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(.black.opacity(0.1))
                                .cornerRadius(10)
                                
                                Spacer()
                                
                                VStack {
                                    Image(systemName: "scalemass")
                                    Text("60")
                                }
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(.black.opacity(0.1))
                                .cornerRadius(10)
                                
                                Spacer()
                                
                                VStack {
                                    Image(systemName: "ruler")
                                    Text("60")
                                }
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(.black.opacity(0.1))
                                .cornerRadius(10)
                                
                                Spacer()
                                
                                VStack {
                                    Image(systemName: "ruler")
                                    Text("60")
                                }
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(.black.opacity(0.1))
                                .cornerRadius(10)
                            }.frame(maxWidth: .infinity, alignment: .center)
                            FishDetails(fish: selectedFish)
                            if let catchLocation = selectedFish?.catch_location, catchLocation != "0 0" {
                                LocationView(location: catchLocation, region: $region, markerCoordinate: $markerCoordinate, showLocation: $showLocation)
                            }
                            Text("**Tags**: ").frame(maxWidth: .infinity, alignment: .leading)
                            TagLayout(alignment: .leading) {
                                ForEach(selectedFishTags, id: \.self) { tag in
                                    HStack (spacing: 10) {
                                        Text(tag.text)
                                            .font(.callout)
                                            .fontWeight(.semibold)
                                        
                                        Button(action: {
                                            Task {
                                                do {
                                                    selectedFishTags = try await viewModel.removeTagFromFish(fishId: selectedFish!.uuid, tagId: tag.id)
                                                } catch {
                                                    print("Error removing tag from fish: \(error)")
                                                }
                                            }
                                        }, label: {
                                            Image(systemName: "minus.circle")
                                        })
                                    }
                                    .frame(height: 35)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 15)
                                    .background(.blue)
                                    .cornerRadius(20)
                                }
                                Button(action: { showTagPopover = true }, label: {
                                    Image(systemName: "plus")
                                        .frame(width: 35, height: 35)
                                        .foregroundStyle(.white)
                                        .background(.blue)
                                        .cornerRadius(20)
                                }).popover(isPresented: $showTagPopover, attachmentAnchor: .point(.center),
                                           arrowEdge: .top,content: {
                                    VStack(alignment: .leading) {
                                        Text("Select a Tag")
                                            .font(.title3)
                                            .padding(.horizontal)

                                        Divider()

                                        ScrollView {
                                            TagLayout() {
                                                ForEach(tags) { tag in
                                                    Button(action: {
                                                        Task {
                                                            if (selectedFish != nil) {
                                                                do {
                                                                    let response: [Tag] = try await viewModel.addTagToFish(fishId: selectedFish!.uuid, tagId: tag.id)
                                                                    selectedFishTags = response
                                                                    showTagPopover = false
                                                                } catch {
                                                                    print("Error adding tag to fish: \(error)")
                                                                }
                                                            }
                                                        }
                                                    }, label: {
                                                        TagView(tag.text, .blue, "plus")
                                                    })
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .presentationCompactAdaptation(.none)
                                })
                            }
                        }
                        .zIndex(1)
                        .sheet(isPresented: $showLocation) {
                            HStack {
                                Button(action: { showLocation = false }, label: {
                                    Image(systemName: "chevron.backward")
                                        .padding()
                                        .clipShape(Circle())
                                })
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                            }
                            .padding(.top)
                            .padding(.leading)
                            MapView(region: $region, markerCoordinate: markerCoordinate)
                        }
                        .padding()
                        .background(Color.black.opacity(0.05).edgesIgnoringSafeArea(.bottom))
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
        }.onTapGesture {
            searchFocused = false
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
    
    private func searchImages(_ value: String) {
        guard let originalFishItems = originalFishItems else { return }
        
        if !value.isEmpty {
            self.fishItems = originalFishItems.filter { $0.name.localizedCaseInsensitiveContains(value)}
        } else {
            self.fishItems = originalFishItems
        }
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
    
    private func filterFishItems(_ items: [Fish], withTags selectedTags: [Tag]) -> [Fish] {
        let selectedTagIds = selectedTags.map { $0.id }
        return items.filter { fish in
            !selectedTags.isEmpty && fish.tags.contains(where: selectedTagIds.contains)
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
            image: selectedFish.image, tags: [],
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
                    selectedTags = []
                    originalFishItems = fishItems
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

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(limit))
            }
        }
        return self
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

struct LocationView: View {
    let location: String
    @Binding var region: MKCoordinateRegion
    @Binding var markerCoordinate: IdentifiableCoordinate
    @Binding var showLocation: Bool
    
    var body: some View {
        Text("**Location**: View Location")
            .onTapGesture {
                handleLocationTap(location: location)
            }
    }
    
    private func handleLocationTap(location: String) {
        let components = location.components(separatedBy: " ")
        if components.count == 2,
           let latitude = Double(components[0].replacingOccurrences(of: ",", with: ".")),
           let longitude = Double(components[1].replacingOccurrences(of: ",", with: ".")) {
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            region.center = coordinates
            markerCoordinate = IdentifiableCoordinate(coordinate: coordinates)
            showLocation = true
        }
    }
}

struct MapView: View {
    @Binding var region: MKCoordinateRegion
    let markerCoordinate: IdentifiableCoordinate

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [markerCoordinate]) { location in
            MapMarker(coordinate: location.coordinate)
        }
    }
}

struct FishDetails: View {
    let fish: Fish?

    var body: some View {
        Group {
            Text("**Name**: \(fish?.name ?? "")")
            Text("**Description**: \(fish?.description ?? "")")
            Text("**Type**: \(fish?.catch_type ?? "")")
            Text("**Length**: \(fish?.catch_length.formatted(.number.precision(.fractionLength(1))) ?? "") cm")
            Text("**Weight**: \(fish?.catch_weight.formatted(.number.precision(.fractionLength(1))) ?? "") lb")
            if let catchDate = fish?.catch_date, catchDate != "0001-01-03T00:00:00Z" {
                Text("**Date**: \(formatDate(catchDate))")
            }
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
}
