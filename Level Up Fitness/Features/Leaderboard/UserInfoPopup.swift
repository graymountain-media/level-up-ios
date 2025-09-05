//
//  UserInfoPopup.swift
//  Level Up
//
//  Created by Jake Gray on 8/31/25.
//

import SwiftUI
import FactoryKit

struct UserInfoPopup: View {
    let userId: UUID
    @Injected(\.otherUsersService) var otherUsersService
//    @Injected(\.friendsService) var friendsService
    
    @State private var userProfile: OtherUserProfile?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var viewProfile: () -> Void = {}
    var dismiss: () -> Void = {}
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation {
                        dismiss()
                    }
                }
            
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(errorMessage)
            } else if let profile = userProfile {
                profileView(profile)
            }
        }
        .task {
            await fetchUserProfile()
        }
    }
    
    // MARK: - Helper Views
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .scaleEffect(1.2)
            
            Text("Loading user info...")
                .foregroundColor(.white)
                .font(.headline)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.2, green: 0.3, blue: 0.4))
        )
        .transition(.opacity.combined(with: .scale))
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 30))
                .foregroundColor(.orange)
            
            Text("Error loading user")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Close") {
                dismiss()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.red)
            .cornerRadius(8)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.2, green: 0.3, blue: 0.4))
        )
        .frame(width: 320)
        .transition(.opacity.combined(with: .scale))
    }
    
    private func profileView(_ profile: OtherUserProfile) -> some View {
        VStack(spacing: 7) {
            Text(profile.avatarName.uppercased())
                .font(.mainFont(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.title)
            
            VStack(spacing: 2) {
                ProfilePicture(url: profile.profilePictureUrl)
                
                Text("LEVEL \(profile.currentLevel)")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            if let path = profile.heroPath {
                HStack(spacing: 6) {
                    Text(path.name)
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                    
                    Image(path.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(.orange)
                }
            }
            
            if let faction = profile.faction {
                HStack(spacing: 6) {
                    Text(faction.name)
                        .font(.system(size: 14))
                        .italic()
                        .foregroundColor(faction.baseColor)
                        .fontWeight(.medium)
                    
                    Image(faction.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(faction.baseColor)
                }
            }
            
            VStack(spacing: 10) {
                Button(action: viewProfile) {
                    Text("View Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 28)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 7)
                        .background(Color.textInput)
                        .cornerRadius(10)
                }
                
                Button(action: {}) {
                    Text("Add Friend")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 28)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 7)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                Button(action: {}) {
                    Text("Block")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(height: 28)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 7)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.textfieldBg)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.textfieldBorder, lineWidth: 1.5)
                })
        )
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - Data Fetching
    
    private func fetchUserProfile() async {
        do {
            isLoading = true
            errorMessage = nil
            
            let profile = try await otherUsersService.fetchUserProfile(userId: userId)
            
            await MainActor.run {
                self.userProfile = profile
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}


#Preview {
    let _ = Container.shared.setupMocks()
    UserInfoPopup(userId: UUID())
}
