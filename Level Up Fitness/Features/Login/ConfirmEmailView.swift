//
//  ConfirmEmailView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/12/25.
//

import SwiftUI

struct ConfirmEmailView: View {
    @Environment(\.dismiss) private var dismiss
    var email: String
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "envelope.open.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.textOrange)
                .padding(.top, 40)
            Text("Confirm Your Email")
                .font(.mainFont(size: 24).bold())
                .foregroundStyle(Color.textOrange)
            Text("We’ve sent a confirmation email to \(email). Please check your inbox and follow the link to activate your account.")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.white)
                .padding(.horizontal)
            LUButton(title: "Open Main App") {
                // Open Mail app
                if let url = URL(string: "message://") {
                    UIApplication.shared.open(url)
                } else if let url = URL(string: "mailto:") {
                    UIApplication.shared.open(url)
                }
                // Pop back to signup screen
                dismiss()
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            Color.major.frame(maxWidth: .infinity).ignoresSafeArea()
        )
    }
}

#Preview {
    ConfirmEmailView(email: "user@example.com")
}
