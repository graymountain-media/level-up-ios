//
//  OtherUserProfileView.swift
//  Level Up Fitness
//
//  Created by Claude on 9/5/25.
//

import SwiftUI
import FactoryKit

struct OtherUserProfileView: View {
    let userId: UUID
    @Injected(\.otherUsersService) var otherUsersService
    @Injected(\.friendsManager) var friendsManager
    
    @State private var userProfile: OtherUserProfile?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isPerformingFriendAction = false
    
    var dismiss: () -> Void = {}
    
    init(userId: UUID, userProfile: OtherUserProfile? = nil, dismiss: @escaping () -> Void) {
        self.userId = userId
        self._userProfile = .init(initialValue: userProfile)
        self.dismiss = dismiss
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(errorMessage)
            } else if let profile = userProfile {
                profileContentView(profile)
            }
        }
        .mainBackground()
        .task {
            if userProfile == nil {
                await fetchUserProfile()
            } else {
                isLoading = false
            }
        }
    }
    
    // MARK: - Loading & Error Views
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .scaleEffect(1.5)
            
            Text("Loading profile...")
                .foregroundColor(.white)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .mainBackground()
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Failed to load profile")
                .font(.title2)
                .foregroundColor(.white)
                .bold()
            
            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Try Again") {
                Task { await fetchUserProfile() }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .mainBackground()
    }
    
    // MARK: - Main Profile View
    
    private func profileContentView(_ profile: OtherUserProfile) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with character portrait and friend actions
                headerSection(profile)
                
                // User info card
//                userInfoCard(profile)
                
                // Stats section
                statsSection(profile)
                
                // Equipment section
//                equipmentSection(profile)
                
                Spacer(minLength: 0)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Header Section
    
    private func headerSection(_ profile: OtherUserProfile) -> some View {
        ZStack(alignment: .top) {
            CachedAsyncImage(url: URL(string: profile.avatarImageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(4/5, contentMode: .fit)
            } placeholder: {
                Image("avatar_placeholder")
                    .resizable()
                    .aspectRatio(4/5, contentMode: .fit)
                    .opacity(0.5)
            }
            
            
            // Friend action buttons
            HStack(alignment: .top) {
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(spacing: 12) {
                    friendActionButton(for: friendsManager.getFriendStatus(for: userId))
                    blockButton()
                }
            }
            .padding(.horizontal, 20)
            
            // Member since info
            VStack(spacing: 4) {
                Spacer()
                HStack {
                    Spacer()
                    Text("Member since \(formatMemberSince(profile.createdAt))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                    Spacer()
                }
                userInfoCard(profile)
            }
        }
        .padding(.top,24)
        .background(
            Image("avatar_bg")
                .resizable()
                .ignoresSafeArea()
        )
    }
    
    // MARK: - User Info Card
    
    private func userInfoCard(_ profile: OtherUserProfile) -> some View {
        HStack(spacing: 0) {
            Spacer()
            if let faction = profile.faction {
                HStack(spacing: 6) {
                    Image(faction.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 72, height: 72)
                }
            }
            VStack(spacing: 10) {
                Text(profile.avatarName.uppercased())
                    .font(.mainFont(size: 42))
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textPath)
                
                if let path = profile.heroPath {
                    LUDivider()
                    HStack(spacing: 6) {
                        Image(path.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .foregroundColor(.textPath)
                        
                        Text(path.name.uppercased())
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.textPath)
                    }
                    .padding(.top, 4)
                }
            }
            if profile.faction != nil {
                Color.clear
                    .frame(width: 72, height: 72)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(.textfieldBg.opacity(0.6))
                .stroke(.textfieldBorder, lineWidth: 2)
        )
        .padding(.horizontal, 18)
    }
    
    // MARK: - Stats Section
    
    private func statsSection(_ profile: OtherUserProfile) -> some View {
        HStack(spacing: 19) {
            // Level info
            VStack {
                progressBar(profile)
                streakCard(
                    title: "CURRENT STREAK",
                    value: "\(profile.currentStreak)",
                    isLongest: false
                )
            }
            VStack {
                
                // XP icons (placeholder)
                Image("badges")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                    .padding(.horizontal, 4)
                streakCard(
                    title: "LONGEST STREAK",
                    value: "\(profile.longestStreak)",
                    isLongest: true
                )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
    }
    
    private func progressBar(_ profile: OtherUserProfile) -> some View {
        VStack(alignment: .leading, spacing: 4) {
                Text("Level \(profile.currentLevel)")
                    .font(.mainFont(size: 25))
                    .bold()
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .foregroundColor(Color.textfieldBg)
                    
                    // Progress fill with gradient
                    Capsule()
                        .frame(width: geometry.size.width * profile.progressToNextLevel)
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 0.3, green: 0.8, blue: 0.3), Color.green],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                }
            }
            .frame(height: 12)
            Text("\(profile.xpToNextLevel) XP to next level")
                .font(.system(size: 14))
                .padding(.top, 4)
        }
        .foregroundStyle(.white)
    }
    
    private func streakCard(title: String, value: String, isLongest: Bool) -> some View {
        VStack(spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 12))
                .fontWeight(.medium)
                .foregroundColor(isLongest ? .textOrange : .white)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.system(size: 36))
                .fontWeight(.bold)
                .foregroundColor(isLongest ? .textOrange : .white)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.textfieldBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isLongest ? .textOrange : .textfieldBorder, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Equipment Section
    
    private func equipmentSection(_ profile: OtherUserProfile) -> some View {
        VStack(spacing: 12) {
            if !profile.equippedItems.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(profile.equippedItems, id: \.id) { equippedItem in
                        equipmentSlot(equippedItem)
                    }
                }
                .padding(.horizontal, 20)
            } else {
                Text("No equipment equipped")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.vertical, 40)
            }
        }
    }
    
    private func equipmentSlot(_ equippedItem: OtherUserEquippedItem) -> some View {
        VStack(spacing: 8) {
            // Equipment icon placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.2, green: 0.15, blue: 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.6), lineWidth: 2)
                )
                .overlay(
                    // Placeholder icon - you can replace with actual item images
                    Image(systemName: iconForItemSlot(equippedItem.itemSlot))
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                )
                .frame(width: 70, height: 70)
            
            if let item = equippedItem.item {
                Text(item.formattedXPBonus)
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
        }
    }
    
    // MARK: - Friend Action Buttons
    
    @ViewBuilder
    private func friendActionButton(for status: FriendStatus) -> some View {
        Button(action: { 
            Task {
                await handleFriendAction(status)
            }
        }) {
            if isPerformingFriendAction {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.white)
                    .frame(width: 120, height: 40)
                    .background(Color.gray)
                    .cornerRadius(5)
            } else {
                Text(status.displayText)
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 40)
                    .background(backgroundColorForStatus(status))
                    .cornerRadius(5)
            }
        }
        .disabled(isPerformingFriendAction || !status.isActionable)
    }
    
    private func blockButton() -> some View {
        Button(action: { 
            Task {
                await blockUser()
            }
        }) {
            if isPerformingFriendAction {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.white)
                    .frame(width: 120, height: 40)
                    .background(Color.gray)
                    .cornerRadius(5)
            } else {
                Text("Block")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 40)
                    .background(Color.red)
                    .cornerRadius(5)
            }
        }
        .disabled(isPerformingFriendAction)
    }
    
    // MARK: - Helper Methods
    
    private func backgroundColorForStatus(_ status: FriendStatus) -> Color {
        switch status {
        case .notFriend:
            return .green
        case .pendingIncoming:
            return .blue
        case .pendingOutgoing, .accepted:
            return .gray
        case .blocked, .blockedBy:
            return .red
        }
    }
    
    private func iconForItemSlot(_ slot: String) -> String {
        switch slot.lowercased() {
        case "weapon":
            return "sword.fill"
        case "armor":
            return "shield.fill"
        case "helmet":
            return "crown.fill"
        case "gloves":
            return "hand.raised.fill"
        case "boots":
            return "shoe.2.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    private func formatMemberSince(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M-dd-yy"
        return formatter.string(from: date)
    }
    
    // MARK: - Data & Actions
    
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
    
    private func handleFriendAction(_ status: FriendStatus) async {
        isPerformingFriendAction = true
        
        let result: Result<Void, FriendsError>
        
        switch status {
        case .notFriend:
            result = await friendsManager.sendFriendRequest(to: userId)
        case .pendingIncoming:
            result = await friendsManager.acceptFriendRequest(from: userId)
        default:
            isPerformingFriendAction = false
            return
        }
        
        await MainActor.run {
            switch result {
            case .success:
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
            isPerformingFriendAction = false
        }
    }
    
    private func blockUser() async {
        isPerformingFriendAction = true
        
        let result = await friendsManager.blockUser(userId)
        
        await MainActor.run {
            switch result {
            case .success:
                break
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
            isPerformingFriendAction = false
        }
    }
}

// MARK: - Preview

#Preview {
    let _ = Container.shared.setupMocks()
    OtherUserProfileView(userId: UUID()) {}
}
