//
//  Settings.swift
//  fishtrack
//
//  Created by Ben Böckmann on 01.06.24.
//

import SwiftUI

struct Settings: View {
    @StateObject var viewModel = SignInViewModel()
    @Binding var appUser: AppUser?
    
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistrationPresented = false
    
    var body: some View {
        VStack {
            VStack {
                Button(action: {
                    Task {
                        do {
                            let user = try await viewModel.signInWithApple()
                            self.appUser = AppUser(uid: user.uid, email: user.email)
                        } catch {
                            print("Error signing in with apple")
                        }
                    }
                }, label: {
                    Text("Sign In With Apple")
                })
                Button(action: {
                    Task {
                        do {
                            let appUser = try await viewModel.signInWithGoogle()
                            self.appUser = appUser
                        } catch {
                            print("Error signing in with google")
                        }
                    }
                }, label: {Text("Sign In With Google")})
            }
            
            Spacer()
            
            VStack {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.top, 20)
                
                Divider()
                
                SecureField(
                    "Password", text: $password)
                .padding(.top, 20)
                
                Divider()
            }
            
            Button(action: { 
                Task {
                    do {
                        let user = try await viewModel.createNewUserWithEmail(email: email, password: password)
                        self.appUser = AppUser(uid: user.uid, email: user.email)
                    } catch {
                        print("issue with sign up")
                    }
                }
            }, label: {
                Text("New User? Signup Here")
            })
            
//            .sheet(isPresented: $isRegistrationPresented, content: {
//                SignUp()
//            })
            
            Spacer()
            if(appUser != nil) {
                Button(action: {
                    Task {
                        do {
                            try await AuthManager.shared.signOut()
                            self.appUser = nil
                        } catch {
                            print("unable to sign out")
                        }
                    }
                }, label: {
                    Text("Sign Out").foregroundColor(.red)
                })
            }
            
            Button(
                action: {
                    Task {
                        do {
                            let user = try await viewModel.signInWithEmail(email: email, password: password)
                            self.appUser = AppUser(uid: user!.uid, email: user!.email)
                        } catch {
                            print("issue with sign in")
                        }
                    }
                },
                label: {
                    Text("Sign In")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            )
        }.padding(30)
    }
}

#Preview {
    Settings(appUser: .constant(AppUser(uid: "1234", email: nil)))
}
