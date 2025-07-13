//
//  LoginView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI
import Combine

struct LoginView: View {
    @State private var showConfirmEmailView: Bool = false
    @Environment(AppState.self) var appState
    @State private var isLogin: Bool = true
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var avatarName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingResetPassword = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @State private var emailToConfirm: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.major
                    .ignoresSafeArea()
                    .frame(maxHeight: .infinity)
                VStack(spacing: 32) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    if !isLogin {
                        LUTextField("Avatar Name", text: $avatarName)
                            .autocapitalization(.words)

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
                        .textContentType(isLogin ? .password : .newPassword)

                    if !isLogin {
                        LUTextField("Confirm Password", text: $confirmPassword, isSecure: true)
                            .textContentType(.newPassword)
                            .autocapitalization(.none)
                    }
                    
                    // Sign Up Button
                    VStack {
                        LUButton(title: isLogin ? "Login" : "Sign Up") {
                            handleAuthentication()
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 24) {
                            Button(isLogin ? "SIGN UP" : "LOG IN") {
                                isLogin.toggle()
                            }
                            
                            if isLogin {
                                Button("FORGOT PASSWORD") {
                                    showingResetPassword = true
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.minor)
                    }
                    .padding(.top, 16)
                }
                .navigationDestination(isPresented: $showConfirmEmailView, destination: {
                    ConfirmEmailView(email: emailToConfirm)
                })
                .padding(30)
                .containerBorder()
                .padding()
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Authentication Error"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .sheet(isPresented: $showingResetPassword) {
                    ResetPasswordView(email: $email)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        
//        .onReceive(appState.supabaseService.$errorMessage) { errorMessage in
//            if let message = errorMessage, !message.isEmpty {
//                alertMessage = message
//                showingAlert = true
//            }
//        }
    }
    
    private func handleAuthentication() {
        func resetFields() {
            emailToConfirm = email
            email = ""
            password = ""
            confirmPassword = ""
            firstName = ""
            lastName = ""
            avatarName = ""
            isLogin = true
        }
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all required fields"
            showingAlert = true
            return
        }
        
        if isLogin {
            // Handle login
            Task {
                let result = await appState.supabaseService.signIn(email: email, password: password)
                switch result {
                case .success(let success):
                    return
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        } else {
            // Handle signup
            guard !avatarName.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
                alertMessage = "Please fill in all required fields"
                showingAlert = true
                return
            }

            guard password == confirmPassword else {
                alertMessage = "Passwords must match"
                showingAlert = true
                return
            }
            
            Task {
                let result = await appState.supabaseService.signUp(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    avatarName: avatarName
                )
                switch result {
                case .success:
                    showConfirmEmailView = true
                    resetFields()
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}

// Reset Password View
struct ResetPasswordView: View {
    @Environment(AppState.self) var appState
    @Binding var email: String
    @State private var showingConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.major
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Reset Password")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 32)
                    
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    LUTextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                    
                    Button(action: {
                        resetPassword()
                    }) {
                        Text("Send Reset Link")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(email.isEmpty)
                    
//                    if appState.supabaseService.isLoading {
//                        ProgressView()
//                            .tint(.white)
//                    }
                    
                    Spacer()
                }
                .padding()
                .overlay {
                    CustomBorderShape(cornerWidth: 15)
                        .stroke(Color.border, lineWidth: 3)
                    CustomBorderShape()
                        .stroke(Color.border, lineWidth: 3)
                        .padding(8)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert("Password Reset Email Sent", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Check your email for a link to reset your password.")
            }
        }
    }
    
    private func resetPassword() {
//        Task {
//            do {
//                try await appState.supabaseService.resetPassword(email: email)
//                showingConfirmation = true
//            } catch {
//                // Error is handled in SupabaseService
//                print("Reset password error: \(error.localizedDescription)")
//            }
//        }
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
