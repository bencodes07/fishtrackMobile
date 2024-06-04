//
//  Home.swift
//  fishtrack
//
//  Created by Ben Böckmann on 31.05.24.
//

import SwiftUI

struct Home: View {
    @State var selectedFilter: Category = categories.first!
    @State private var fishItems: [Fish]?
    @Binding var appUser: AppUser?
    @StateObject var viewModel = FishModel()
    @Environment(\.colorScheme) private var colorScheme
    
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
                            
                            Button(action: {}, label: {
                                Text("Add a Catch")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.vertical,10)
                                    .padding(.horizontal)
                                    .background(.blue)
                                    .clipShape(Capsule())
                            })
                        })
                        
                        Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
                        
                        Image("delivery-man")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: getRect().width / 3)
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
