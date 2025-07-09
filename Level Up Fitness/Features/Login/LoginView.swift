//
//  LoginView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) var appState
    @State private var isLogin: Bool = true
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    
    var body: some View {
        ZStack {
            Color.major
                .ignoresSafeArea()
                .frame(maxHeight: .infinity)
            VStack(spacing: 32) {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if !isLogin {
                    LUTextField("First Name", text: $firstName)
                        .textContentType(.givenName)
                        .autocapitalization(.words)
                    
                    LUTextField("Last Name", text: $lastName)
                        .textContentType(.familyName)
                        .autocapitalization(.words)
                }
                LUTextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                LUTextField("Password", text: $password, isSecure: true)
                    .textContentType(.newPassword)
                
                // Sign Up Button
                VStack {
                    Button(action: {
                        appState.isSignedIn = true
                    }) {
                        Image(isLogin ? "login_button" : "signUp_button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 60)
                    }
                    HStack(spacing: 24) {
                        Button(isLogin ? "SIGN UP" : "LOG IN") {
                            isLogin.toggle()
                        }
                        if isLogin {
                            Button("FORGOT PASSWORD") {
                                
                            }
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.minor)
                }
                .padding(.top, 16)
            }
            .padding(30)
            .overlay {
                CustomBorderShape(cornerWidth: 15)
                    .stroke(Color.border, lineWidth: 3)
                CustomBorderShape()
                    .stroke(Color.border, lineWidth: 3)
                    .padding(8)
            }
            .padding()
        }
    }

}

#Preview {
    LoginView()
        .environment(AppState())
}
