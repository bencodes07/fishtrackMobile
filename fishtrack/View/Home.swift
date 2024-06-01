//
//  Home.swift
//  fishtrack
//
//  Created by Ben Böckmann on 31.05.24.
//

import SwiftUI

struct Home: View {
    @State var selectedFilter: Category = categories.first!
    var body: some View {
        
        VStack {
            HStack {
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "circle.grid.2x2")
                        .font(.title2)
                        .padding(10)
                        .background(.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                })
                
                Spacer()
                
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding(10)
                        .background(.black.opacity(0.08))
                        .foregroundColor(.pink)
                        .cornerRadius(8)
                })
            }
            .overlay(
                HStack(spacing: 4) {
                    Text("fishtrack.")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            )
            .padding()
            
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8, content: {
                            (
                                Text("Track all your ")
                                +
                                Text("Fish")
                                    .foregroundColor(.blue)
                            )
                            .font(.title)
                            .fontWeight(.bold)
                            
                            Button(action: {}, label: {
                                Text("Order Now")
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
                                        .foregroundColor(selectedFilter.id == filter.id ? .white : .black)
                                }
                                .padding(.vertical, 12)
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
