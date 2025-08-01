//
//  ProfileSettings.swift
//  Level Up
//
//  Created by Jake Gray on 7/31/25.
//

import SwiftUI
import FactoryKit

struct ProfileSettings: View {
    @InjectedObservable(\.appState) var appState
    @Environment(\.dismiss) var dismiss
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var avatarName: String = ""
    @State private var avatarImage: String = ""
    
    var firstNameText: String {
        return appState.userAccountData?.profile.firstName ?? ""
    }
    
    var lastNameText: String {
        return appState.userAccountData?.profile.lastName ?? ""
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                FeatureHeader(title: "Account Details")
                HStack(alignment: .center, spacing: 16) {
                    Image("profile_placeholder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(firstNameText) \(lastNameText)")
                            .font(.system(size: 17))
                            .foregroundColor(.textDetail)
                        HStack(alignment: .bottom) {
                            Text("Member")
                                .font(.system(size: 14))
                                .italic()
                                .foregroundColor(.textOrange)
                            Spacer()
                            Button(action: {
                                // Reset password action
                            }) {
                                Text("Reset Password")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textDetail)
                            }
                        }
                    }
                    Spacer(minLength: 4)
                }
                VStack(alignment: .leading, spacing: 18) {
                    LUTextField(title: "First Name", text: $firstName, rightIconName: "pencil")
                    LUTextField(title: "Last Name", text: $lastName, rightIconName: "pencil")
                    LUTextField(title: "Email Address", text: $email, rightIconName: "pencil")
                        .keyboardType(.emailAddress)
                    LUTextField(title: "Avatar Name", text: $avatarName, rightIconName: "pencil")
                }
                Spacer()
                LUButton(title: "Continue") {
                    dismiss()
                }
            }
            .padding(.horizontal, 24)
        }
        .task {
            firstName = appState.userAccountData?.profile.firstName ?? ""
            lastName = appState.userAccountData?.profile.lastName ?? ""
            email = appState.supabaseClient.auth.currentUser?.email ?? ""
            avatarName = appState.userAccountData?.profile.avatarName ?? ""
        }
        
        .mainBackground()
    }
}


#Preview {
    let _ = Container.shared.setupMocks()
    ProfileSettings()
}
