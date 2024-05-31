//
//  Home.swift
//  fishtrack
//
//  Created by Ben Böckmann on 31.05.24.
//

import SwiftUI

struct Home: View {
    var body: some View {
        
        VStack {
            HStack {
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "circle.grid.2x2")
                        .font(.title2)
                        .padding(10)
                        .background(.pink.opacity(0.12))
                        .foregroundColor(.pink)
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
                                Text("The Fastest in Delivery ")
                                +
                                Text("Food")
                                    .foregroundColor(.pink)
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
                                    .background(.pink)
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
                    .background(.yellow.opacity(0.2))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Text("Categories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false, content: {
                        HStack(spacing: 15) {
                            ForEach(categories){
                                category in
                                HStack(spacing: 12) {
                                    Image(category.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 18, height: 18)
                                        .padding(6)
                                        .background(.white)
                                        .clipShape(Circle())
                                    
                                    Text(category.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(.pink)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    })
                }
                .padding(.vertical)
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
