//
//  PasswordResetView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/30/25.
//

import SwiftUI

struct PasswordResetView: View {
    @State var password: String = ""
    @State var passwordConfirmation: String = ""
    
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
                    Text("Change Your Password")
                        .font(.system(size: 17.5))
                        .foregroundStyle(.white)
                    
                    Text("Enter a new password below to change your password.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: 24) {
                LUTextField(title: "New password*", text: $password, isSecure: true)
                LUTextField(title: "Re-enter password*", text: $passwordConfirmation, isSecure: true)
                
                LUButton(title: "Continue", isLoading: false, fillSpace: false) {
//                    viewModel.resetPassword()
                }
//                .disabled(viewModel.email.isEmpty || viewModel.isLoading)
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
    }
}

#Preview {
    PasswordResetView()
}
