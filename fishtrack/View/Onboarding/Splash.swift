//
//  Splash.swift
//  fishtrack
//
//  Created by Ben Böckmann on 02.06.24.
//

import SwiftUI

struct Splash: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack {
            Spacer()
            
            Image("fish")
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 170)
                .padding(.vertical)
            (
                Text("fish")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .light ? .black : .white)
                +
                Text("track.")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontWeight(.black)
                    .foregroundColor(.blue)
            )
            
            
            Spacer()
            
            Button(action: {
                // Action for the button
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }.padding(.vertical)
            
            Button(action: {
                
            }, label: {
                (
                    Text("Already a member? ")
                        .font(.footnote)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .fontWeight(.medium)
                    +
                    Text("Sign In")
                        .font(.system(size: 16))
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .fontWeight(.medium)
                        .underline()
                )
               
            })
        }
    }
}

#Preview {
    Splash()
}
