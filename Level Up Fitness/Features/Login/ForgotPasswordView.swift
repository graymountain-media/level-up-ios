//
//  ForgotPasswordView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/20/25.
//

import SwiftUI
import FactoryKit

struct ForgotPasswordView: View {
    @State var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 36) {
            FeatureHeader(title: "Password Reset")
            Spacer()
            VStack(spacing: 24) {
                Image("padlock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 78)
                VStack(spacing: 8) {
                    Text("Send Password Reset Link")
                        .font(.system(size: 17.5))
                        .foregroundStyle(.white)
                    
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: 24) {
                LUTextField(title: "Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                LUButton(title: "Send Reset Link", isLoading: viewModel.isLoading, fillSpace: false) {
                    viewModel.resetPassword()
                }
                .disabled(viewModel.email.isEmpty || viewModel.isLoading)
                Button("Back to Login") {
                    dismiss()
                }
                .foregroundStyle(.textDetail)
            }
            Spacer()
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 46)
        .background(
            Image("main_bg")
                .resizable()
                .ignoresSafeArea()
        )
        .alert("Password Reset Email Sent", isPresented: $viewModel.isShowingResetConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Check your email for a link to reset your password.")
        }
    }
}

#Preview {
    ForgotPasswordView(viewModel: LoginViewModel(isLogin: true))
}
