//
//  LoginView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI
import Combine
import FactoryKit

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @InjectedObservable(\.appState) var appState
    @State var viewModel: LoginViewModel
    
    init(isLogin: Bool = false) {
        self._viewModel = State(initialValue: LoginViewModel(isLogin: isLogin))
    }
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: 36) {
                LoginHeader()
                .frame(width: proxy.size.width * 0.7)
                LUDivider()
                VStack(spacing: 8) {
                    Text(viewModel.isLogin ? "Log In Now" : "Sign Up")
                        .font(.system(size: 32))
                        .foregroundStyle(.title)
                    Text("Sign in to continue using our app")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
                VStack(spacing: 8) {
                    fields
                    buttons
                }
                Spacer()
            }
            
        }
        .padding(.horizontal, 40)
        .mainBackground()
        .navigationDestination(isPresented: $viewModel.showConfirmEmailView, destination: {
            ConfirmEmailView(email: viewModel.emailToConfirm)
        })
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(
                title: Text("Authentication Error"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $viewModel.showingResetPassword) {
            ForgotPasswordView(viewModel: viewModel)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.textfieldBorder)
                }

            }
        }
    }
    
    var fields: some View {
        VStack {
            LUTextField(title: "Email", text: $viewModel.email, placeholder: "you@email.com")
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
            
            LUTextField(title: "Password", text: $viewModel.password, placeholder: "Create a password", isSecure: true)
                .textContentType(viewModel.isLogin ? .password : .newPassword)
            
            if !viewModel.isLogin {
                LUTextField(title: "Confirm Password", text: $viewModel.confirmPassword,placeholder: "Re-enter your password", isSecure: true)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
            }
        }
    }
    
    var buttons: some View {
        VStack {
            LUButton(
                title: viewModel.isLogin ? "Log In" : "Sign Up",
                isLoading: viewModel.isLoading,
                fillSpace: true
            ) {
                viewModel.handleAuthentication()
            }
            .disabled(viewModel.isLoading)
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 32) {
                Button {
                    viewModel.isLogin.toggle()
                } label: {
                    Text(viewModel.isLogin ? "Sign Up" : " Have an account? Log In")
                        
                }
                
                if viewModel.isLogin {
                    Button {
                        viewModel.showingResetPassword = true
                    } label: {
                        Text("Forgot Password")
                    }
                }
            }
            .font(.system(size: 18))
            .foregroundStyle(.textDetail)
            .frame(height: 46)
        }
    }
}

#Preview {
    let _ = Container.shared.setupMocks()
    LoginView(isLogin: true)
}
