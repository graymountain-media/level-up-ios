//
//  FriendsListView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/24/25.
//

import SwiftUI
import FactoryKit

struct FriendsListView: View {
    @Injected(\.friendsManager) var friendsManager
    @State private var showingAddFriends = false
    @State private var selectedUser: SelectedUser?
    
    struct SelectedUser: Identifiable {
        let id: UUID
    }
    
    private var isAllEmpty: Bool {
        guard let friendships = friendsManager.allFriendships else { return true }
        return friendships.friendships.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            FeatureHeader(title: "Friends", showCloseButton: true, right: {
                Button {
                    showingAddFriends = true
                } label: {
                    Text("Add Friend")
                        .foregroundStyle(.textInput)
                        .bold()
                }
            })
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 32) {
                    if isAllEmpty && !friendsManager.isLoading {
                        // Empty state
                        VStack(spacing: 24) {
                            Spacer()
                            
                            Image(systemName: "person.2")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.3))
                            
                            VStack(spacing: 8) {
                                Text("NO FRIENDS YET")
                                    .font(.mainFont(size: 20))
                                    .bold()
                                    .foregroundColor(.title)
                                
                                Text("Start building your network by adding friends to compete and train together.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.textDetail)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(2)
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 32)
                    } else if let friendships = friendsManager.allFriendships {
                            // Incoming Friend Requests Section
                            if !friendships.incomingRequests.isEmpty {
                                friendshipSection(
                                    title: "Friend Requests",
                                    items: friendships.incomingRequests,
                                    content: { request in
                                        IncomingRequestRowView(
                                            friendship: request,
                                            onAccept: {
                                                await acceptFriendRequest(request.otherUserId)
                                            },
                                            onReject: { await rejectFriendRequest(request.friendshipId)
                                            },
                                            onTap: { userId in
                                                self.selectedUser = SelectedUser(id: userId)
                                            }
                                        )
                                    }
                                )
                            }
                            
                            // Accepted Friends Section
                            if !friendships.acceptedAndPending.isEmpty {
                                friendshipSection(
                                    title: "Friends (\(friendships.acceptedAndPending.count))",
                                    items: friendships.acceptedAndPending,
                                    content: { friend in
                                        if friend.isOutgoing {
                                            OutgoingRequestRowView(friendship: friend) { userId in
                                                self.selectedUser = SelectedUser(id: userId)
                                            }
                                        } else {
                                            AcceptedFriendRowView(
                                                friendship: friend,
                                                onTap: { userId in
                                                    self.selectedUser = SelectedUser(id: userId)
                                                }
                                            )
                                        }
                                    }
                                )
                            }
                            
                            // Blocked Users Section
                            if !friendships.blockedUsers.isEmpty {
                                friendshipSection(
                                    title: "Blocked Users",
                                    items: friendships.blockedUsers,
                                    content: { blockedUser in
                                        BlockedUserRowView(
                                            friendship: blockedUser,
                                            onUnblock: { await unblockUser(blockedUser.otherUserId) }
                                        )
                                    }
                                )
                            }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
            }
            .refreshable(action: { await friendsManager.loadFriendships() })
            .scrollIndicators(.hidden)
        }
        .background(
            Color.major
                .ignoresSafeArea()
        )
        .task {
            await friendsManager.loadFriendships()
        }
        .fullScreenCover(isPresented: $showingAddFriends) {
            AddFriendsSearchView {
                showingAddFriends = false
            }
        }
        .fullScreenCover(item: $selectedUser) { user in
            OtherUserProfileView(userId: user.id) {
                selectedUser = nil
            }
        }
    }
    
    @ViewBuilder
    private func friendshipSection<T: Identifiable, Content: View>(
        title: String,
        items: [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title.uppercased())
                .font(.mainFont(size: 16))
                .bold()
                .foregroundColor(.title)
            
            LazyVStack(spacing: 16) {
                ForEach(items) { item in
                    content(item)
                }
            }
        }
    }
}

extension FriendsListView {
    private func acceptFriendRequest(_ userId: UUID) async {
        let result = await friendsManager.acceptFriendRequest(from: userId)
        
        if case .failure(let error) = result {
            // Error handling could be implemented here if needed
            print("Failed to accept friend request: \(error)")
        }
    }
    
    private func rejectFriendRequest(_ friendshipId: Int64) async {
        let result = await friendsManager.rejectFriendRequest(friendshipId: friendshipId)
        
        if case .failure(let error) = result {
            print("Failed to reject friend request: \(error)")
        }
    }
    
    private func blockFriend(_ userId: UUID) async {
        let result = await friendsManager.blockUser(userId)
        
        if case .failure(let error) = result {
            print("Failed to block user: \(error)")
        }
    }
    
    private func unblockUser(_ userId: UUID) async {
        let result = await friendsManager.removeFriend(userId)
        
        if case .failure(let error) = result {
            print("Failed to unblock user: \(error)")
        }
    }
}

// MARK: - Row Views

struct AcceptedFriendRowView: View {
    let friendship: Friendship
    let onTap: (_ userId: UUID) -> Void
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack(alignment: .bottom) {
                ProfilePicture(url: friendship.otherProfilePictureUrl)
                if let level = friendship.otherCurrentLevel {
                    Text("\(level)")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .bold()
                        .offset(y: 7)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Username
                Text(friendship.otherAvatarName.uppercased())
                    .font(.mainFont(size: 15))
                    .bold()
                    .foregroundColor(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            Spacer(minLength: 0)
            
            VStack(alignment: .trailing, spacing: 4) {
                // Faction
                if let faction = friendship.otherFaction {
                    HStack(spacing: 4) {
                        Text(faction.name)
                            .font(.system(size: 12))
                            .foregroundColor(faction.baseColor)
                            .italic()
                        Image(faction.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                    }
                }
                
                // Path
                if let path = friendship.otherHeroPath {
                    HStack(spacing: 4) {
                        Text(path.name)
                            .font(.system(size: 12))
                            .foregroundColor(.textOrange)
                            .italic()
                        // Path icon (if available)
                        Image(path.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(friendship.otherUserId)
        }
    }
}

struct IncomingRequestRowView: View {
    let friendship: Friendship
    let onAccept: () async -> Void
    let onReject: () async -> Void
    let onTap: (_ userId: UUID) -> Void
    
    @State private var isAccepting = false
    @State private var isRejecting = false
    @State private var showRejectAlert = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ProfilePicture(url: friendship.otherProfilePictureUrl)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friendship.otherAvatarName.uppercased())
                    .font(.mainFont(size: 15))
                    .bold()
                    .foregroundColor(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                HStack(spacing: 4) {
                    if let faction = friendship.otherFaction {
                        HStack(spacing: 4) {
                            Text(faction.name)
                                .font(.system(size: 12))
                                .foregroundColor(faction.baseColor)
                                .italic()
                            Image(faction.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        }
                    }
                    if let path = friendship.otherHeroPath {
                        HStack(spacing: 4) {
                            Text(path.name)
                                .font(.system(size: 12))
                                .foregroundColor(.textOrange)
                                .italic()
                            // Path icon (if available)
                            Image(path.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap(friendship.otherUserId)
            }
            
            Spacer(minLength: 0)
            
            VStack(alignment: .trailing, spacing: 8) {
                
                
                Button {
                    Task {
                        isAccepting = true
                        await onAccept()
                        isAccepting = false
                    }
                } label: {
                    if isAccepting {
                        ProgressView()
                            .scaleEffect(0.6)
                            .frame(height: 24)
                            .frame(width: 60)
                            .tint(.white)
                    } else {
                        Text("Accept")
                            .font(.system(size: 14))
                            .bold()
                            .foregroundStyle(.black)
                            .frame(height: 36)
                            .padding(.horizontal, 12)
                            .background {
                                Capsule()
                                    .fill(.textOrange)
                            }
                    }
                }
                .disabled(isAccepting || isRejecting)
                
                
                Button {
                    showRejectAlert = true
                } label: {
                    if isRejecting {
                        ProgressView()
                            .scaleEffect(0.6)
                            .frame(height: 24)
                            .frame(width: 60)
                            .tint(.white)
                    } else {
                        Text("Reject")
                            .font(.system(size: 14))
                            .bold()
                            .foregroundStyle(.white)
                            .frame(height: 32)
                            .padding(.horizontal, 12)
                            .background {
                                Capsule()
                                    .fill(.red.opacity(0.6))
                            }
                    }
                }
                .disabled(isRejecting || isAccepting)
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, -8)
        )
        .alert("Reject Friend Request", isPresented: $showRejectAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reject", role: .destructive) {
                Task {
                    isRejecting = true
                    await onReject()
                    isRejecting = false
                }
            }
        } message: {
            Text("Are you sure you want to reject the friend request from \(friendship.otherAvatarName)? This action cannot be undone.")
        }
    }
}

struct OutgoingRequestRowView: View {
    let friendship: Friendship
    let onTap: (_ userId: UUID) -> Void
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ProfilePicture(url: friendship.otherProfilePictureUrl)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friendship.otherAvatarName.uppercased())
                    .font(.mainFont(size: 15))
                    .bold()
                    .foregroundColor(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                HStack(spacing: 4) {
                    if let faction = friendship.otherFaction {
                        HStack(spacing: 4) {
                            Text(faction.name)
                                .font(.system(size: 12))
                                .foregroundColor(faction.baseColor)
                                .italic()
                            Image(faction.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        }
                    }
                    if let path = friendship.otherHeroPath {
                        HStack(spacing: 4) {
                            Text(path.name)
                                .font(.system(size: 12))
                                .foregroundColor(.textOrange)
                                .italic()
                            // Path icon (if available)
                            Image(path.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Pending")
                    .font(.system(size: 10))
                    .bold()
                    .foregroundStyle(.white)
                    .frame(height: 24)
                    .padding(.horizontal, 12)
                    .background {
                        Capsule()
                            .fill(.orange.opacity(0.3))
                            .overlay(
                                Capsule()
                                    .stroke(.orange, lineWidth: 1)
                            )
                    }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(friendship.otherUserId)
        }
    }
}

struct BlockedUserRowView: View {
    let friendship: Friendship
    let onUnblock: () async -> Void
    
    @State private var isUnblocking = false
    @State private var showUnblockAlert = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar (grayed out)
            ProfilePicture(url: friendship.otherProfilePictureUrl)
                .opacity(0.5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friendship.otherAvatarName.uppercased())
                    .font(.mainFont(size: 15))
                    .bold()
                    .foregroundColor(.title.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text("@\(friendship.otherAvatarName)")
                    .font(.system(size: 12))
                    .foregroundColor(.textDetail.opacity(0.7))
            }
            
            Spacer(minLength: 0)
            
            Button {
                showUnblockAlert = true
            } label: {
                if isUnblocking {
                    ProgressView()
                        .frame(height: 24)
                        .tint(.white)
                } else {
                    Text("Unblock")
                        .font(.system(size: 12))
                        .bold()
                        .foregroundStyle(.black)
                        .frame(height: 24)
                        .padding(.horizontal, 12)
                        .background {
                            Capsule()
                                .fill(.gray.opacity(0.3))
                        }
                }
            }
            .disabled(isUnblocking)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, -8)
        )
        .alert("Unblock User", isPresented: $showUnblockAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Unblock") {
                Task {
                    isUnblocking = true
                    await onUnblock()
                    isUnblocking = false
                }
            }
        } message: {
            Text("Are you sure you want to unblock \(friendship.otherAvatarName)? They will be able to send you friend requests again.")
        }
    }
}

// MARK: - Models

struct Friend: Identifiable, Codable {
    let id = UUID()
    let username: String
    let level: Int
    let faction: Faction?
    let path: HeroPath?
    let avatarURL: String?
    
    static let mockData: [Friend] = [
        Friend(
            username: "AVARII",
            level: 9,
            faction: .pulseforge,
            path: .ranger,
            avatarURL: "https://via.placeholder.com/60"
        ),
        Friend(
            username: "MEGATRON",
            level: 9,
            faction: .voidkind,
            path: .brute,
            avatarURL: "https://via.placeholder.com/60"
        ),
        Friend(
            username: "WILLIAMVANGENCE",
            level: 5,
            faction: .neurospire,
            path: .juggernaut,
            avatarURL: "https://via.placeholder.com/60"
        )
    ]
}

// MARK: - Extensions

#Preview {
    let _ = Container.shared.setupMocks()
    FriendsListView()
}
