//
//  PasswordResetView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/30/25.
//

import SwiftUI
import FactoryKit

struct PasswordResetView: View {
    @State private var viewModel = PasswordResetViewModel()
    let onDismiss: (_ didReset: Bool) -> Void
    
    var body: some View {
        VStack(spacing: 36) {
            FeatureHeader(title: "Password Reset", showCloseButton: true)
            Spacer()
            if viewModel.passwordResetSuccess {
                successMessage
            } else {
                passwordEntry
            }
            
            Spacer()
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
        .mainBackground()
        .alert("Error", isPresented: $viewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    var successMessage: some View {
        VStack(spacing: 20) {
            Image("checkmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            VStack(spacing: 8) {
                Text("Password Changed!")
                    .font(.system(size: 17.5))
                    .foregroundStyle(.white)
                Text("Your password has been successfully reset.")
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
            }
            LUButton(title: "Continue") {
                onDismiss(true)
            }
        }
    }
    
    var passwordEntry: some View {
        VStack(spacing: 36) {
            VStack(spacing: 24) {
                Image("padlock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 78, height: 78)
                VStack(spacing: 8) {
                    Text("Change Your Password")
                        .font(.system(size: 17.5))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Enter a new password below to change your password.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 30)
                }
            }
            
            VStack(spacing: 24) {
                LUTextField(title: "New password*", text: $viewModel.newPassword, isSecure: true)
                    .textContentType(.newPassword)
                VStack {
                    LUTextField(title: "Re-enter password*", text: $viewModel.confirmPassword, isSecure: true)
                        .textContentType(.newPassword)
                    if viewModel.newPassword != viewModel.confirmPassword {
                        Text("Passwords do not match.")
                            .font(.system(size: 12))
                            .foregroundStyle(.red)
                    }
                }
                
                LUButton(title: "Continue", isLoading: viewModel.isLoading, fillSpace: false) {
                    viewModel.updatePassword()
                }
                .disabled(viewModel.isContinueDisabled)
            }
            .padding(.horizontal, 22)
        }
    }
}

#Preview {
    PasswordResetView() { _ in
        
    }
}
