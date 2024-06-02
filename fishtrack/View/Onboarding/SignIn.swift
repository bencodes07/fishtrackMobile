//
//  SignIn.swift
//  fishtrack
//
//  Created by Ben Böckmann on 02.06.24.
//

import SwiftUI

struct SignIn: View {
    @StateObject var viewModel = SignInViewModel()
    @Binding var appUser: AppUser?
    @Binding var isPresented: Bool
    private let validator = FormValidator()
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var showError: Bool = false
    
    @State private var isEmailValid = false
    @State private var isPasswordValid = false
    
    var isFormValid: Bool {
        isEmailValid && isPasswordValid
    }
    
    var body: some View {
        VStack{
            Spacer()
            Spacer()
            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Email", text: $email)
                .padding()
                .background(.gray.opacity(0.15))
                .cornerRadius(10.0)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.bottom, 20)
                .onChange(of: email) {
                    isEmailValid = validator.validateEmail(email)
                }
            SecureField("Password", text: $password)
                .padding()
                .background(.gray.opacity(0.15))
                .cornerRadius(10.0)
                .padding(.bottom, 20)
                .onChange(of: password) {
                    isPasswordValid = validator.validatePassword(password)
                }
            
            Button(action: {
                Task {
                    do {
                        let user = try await viewModel.signInWithEmail(email: email, password: password)
                        appUser = AppUser(uid: user!.uid, email: user!.email)
                    } catch {
                        showError = true
                        print("issue with sign up")
                    }
                }
            }){
                Text("Sign In")
                 .font(.headline)
                 .padding()
                 .foregroundColor(.white)
                 .frame(maxWidth: .infinity, minHeight: 60)
                 .background(.blue)
                 .disabled(!isFormValid)
                 .cornerRadius(10.0)
            }.alert("Please ensure the inputs are correctly formatted", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            }
            
            
            Button(action: {}, label: {
                Text("I forgot my password.")
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.8))
                    .padding()
            })
            
            Spacer()
            
            VStack {
                Text("Don't have an account yet?")
                    .padding(.top)
                    .foregroundColor(.black.opacity(0.8))
                
                Button(action: { isPresented = false }, label: {
                    Text("Create Account")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 250, minHeight: 30)
                        .background(.secondary)
                        .cornerRadius(10)
                        .padding()
                })
            }
            .frame(maxWidth: .infinity)
            .background(.black.opacity(0.05))
            .cornerRadius(10)
            .padding()
            
        }.padding()
            .overlay(alignment: .topLeading, content: {
                HStack {
                    Button(action: { isPresented = false }, label: {
                        Image(systemName: "chevron.backward")
                    }).padding(.leading, 30)
                    
                    Spacer()
                    
                    HStack {
                        Text("fishtrack.")
                            .padding(.vertical)
                            .fontWeight(.black)
                            .foregroundColor(.blue)
                            .font(.title3)
                        Image("fish")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(.vertical)
                    }
                }
                .frame(maxWidth: getRect().width / 1.5)
            })
    }
}

#Preview {
    SignIn(appUser: .constant(AppUser(uid: "1234", email: nil)), isPresented: .constant(true))
}
