//
//  SignUp.swift
//  fishtrack
//
//  Created by Ben Böckmann on 01.06.24.
//

import SwiftUI

struct SignUp: View {
    @StateObject var viewModel = SignInViewModel()
    @Binding var appUser: AppUser?
    @Binding var isPresented: Bool
    private let validator = FormValidator()
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showError: Bool = false
    
    @State private var isEmailValid = false
    @State private var isPasswordValid = false
    @State private var isConfirmPasswordValid = false
    
    var isFormValid: Bool {
        isEmailValid && isPasswordValid && isConfirmPasswordValid
    }
    
    var body: some View {
        VStack{
            Spacer()
            Spacer()
            Text("Create an account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Email", text: $email)
                .padding()
                .background(.gray.opacity(0.15))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .cornerRadius(10.0)
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
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(.gray.opacity(0.15))
                .cornerRadius(10.0)
                .padding(.bottom, 20)
                .onChange(of: confirmPassword) {
                    isConfirmPasswordValid = password == confirmPassword
                }
            
            
            Button(action: {
                Task {
                    do {
                        let user = try await viewModel.createNewUserWithEmail(email: email, password: password)
                        self.appUser = AppUser(uid: user.uid, email: user.email)
                    } catch {
                        showError = true
                        print("issue with sign up")
                    }
                }
            }){
                Text("Create Account")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(.blue)
                    .cornerRadius(10.0)
                    .disabled(!isFormValid)
            }.alert("Please ensure the inputs are correctly formatted", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            }
            
            Text("By clicking \"Create Account\", you agree to fishtrack's Terms of Use")
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            Spacer()
            
        }.padding()
            .overlay(alignment: .topLeading, content: {
                HStack {
                    Button(action: {isPresented = false}, label: {
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
    SignUp(appUser: .constant(AppUser(uid: "1234", email: nil)), isPresented: .constant(true))
}
