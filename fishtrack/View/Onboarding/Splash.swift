//
//  Splash.swift
//  fishtrack
//
//  Created by Ben Böckmann on 02.06.24.
//

import SwiftUI

struct Splash: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var showSignUp = false
    @State private var showSignIn = false
    @Binding var appUser: AppUser?
    
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
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(.blue)
            )
            
            
            Spacer()
            

            Button(action: {showSignUp = true}) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.vertical)
            .fullScreenCover(isPresented: $showSignUp) {
                SignUp(appUser: $appUser, isPresented: $showSignUp)
            }

            Button(action: {showSignIn = true}, label: {
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
            }).fullScreenCover(isPresented: $showSignIn) {
                SignIn(appUser: $appUser, isPresented: $showSignIn)
            }
        }
    }
}

#Preview {
    Splash(appUser: .constant(AppUser(uid: "1234", email: nil)))
}
