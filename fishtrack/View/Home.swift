//
//  Home.swift
//  fishtrack
//
//  Created by Ben Böckmann on 31.05.24.
//

import SwiftUI

struct Home: View {
    @State var selectedFilter: Category = categories.first!
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
                                HStack(spacing: 12) {
                                    Image(systemName: filter.image)
                                        .frame(width: 18, height: 18)
                                        .padding(6)
                                        .foregroundColor(.blue)
                                        .background(.white)
                                        .clipShape(Circle())
                                    
                                    Text(filter.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(selectedFilter.id == filter.id ? .white : colorScheme == .dark ? Color(red: 0.85, green: 0.85, blue: 0.85) : .black)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .background(selectedFilter.id == filter.id ? .blue : .gray.opacity(0.3))
                                .clipShape(Capsule())
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedFilter = filter
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
                                ForEach(0..<10) { data in
                                    VStack {
                                        Image("")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipped()
                                            .background(.gray)
                                            .cornerRadius(20)
                                            .padding(1)
                                        Text("Mein Barsch")
                                            .fontWeight(.semibold)
                                            .font(.system(size: 18))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(EdgeInsets(top: 2, leading: 4, bottom: 0, trailing: 0))
                                        
                                        HStack() {
                                                Text("Hello").font(.caption).lineLimit(1)
                                        }
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 10)
                                        .foregroundColor(.blue)
                                        .background(.blue.opacity(0.4))
                                        .cornerRadius(20)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }.padding(.bottom, 10)
                                }
                            }).padding(.horizontal)
                    }
                }
            })
        }
    }
}

#Preview {
    Home()
}

extension View {
    func getRect()->CGRect {
        return UIScreen.main.bounds
    }
}
