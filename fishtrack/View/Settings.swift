//
//  Settings.swift
//  fishtrack
//
//  Created by Ben Böckmann on 01.06.24.
//

import SwiftUI

struct Settings: View {
    @Binding var appUser: AppUser?
    
    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading) {
                Text("Welcome back,")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.8))
                Text(appUser?.email ?? "")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: getRect().width, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .padding(.top, 24)
            
            ScrollView(.vertical, showsIndicators: false, content: {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {}, label: {
                    Label(title: {
                        Text("Send Feedback")
                    }, icon: {
                        Image(systemName: "star")
                            .padding(.horizontal)
                            .padding(.trailing, -10)
                            .fontWeight(.semibold)
                    })
                    .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                    .font(.headline)
                    .padding()
                    .background(.black.opacity(0.05))
                    .cornerRadius(10.0)
                })
                
                Button(role: .destructive, action: {
                    Task {
                        do {
                            try await AuthManager.shared.signOut()
                            appUser = nil
                        } catch {
                            print("Unable to Sign Out")
                        }
                    }
                }, label: {
                    Label(title: {
                        Text("Sign Out")
                    }, icon: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .padding(.horizontal)
                            .padding(.trailing, -10)
                            .fontWeight(.semibold)
                    })
                    .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                    .font(.headline)
                    .padding()
                    .background(.black.opacity(0.05))
                    .cornerRadius(10.0)
                })
            })
            .padding()
        }
    }
}

#Preview {
    Settings(appUser: .constant(AppUser(uid: "1234", email: "boeckmannben@gmail.com")))
}
