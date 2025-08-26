//
//  FriendsListView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/24/25.
//

import SwiftUI

struct FriendsListView: View {
    @State private var friends: [Friend] = Friend.mockData
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                FeatureHeader(title: "Friends", showCloseButton: true)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 25) {
                        ForEach(friends) { friend in
                            FriendRowView(friend: friend)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(
            Color.major
                .ignoresSafeArea()
        )
        .task {
            await loadFriends()
        }
    }
    
    private func loadFriends() async {
        isLoading = true
        // TODO: Load friends from service
        isLoading = false
    }
}

struct FriendRowView: View {
    let friend: Friend
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack(alignment: .bottom) {
                ProfilePicture(url: friend.avatarURL)
                Text("\(friend.level)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .bold()
                    .offset(y: 7)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Username
                Text(friend.username.uppercased())
                    .font(.mainFont(size: 15))
                    .bold()
                    .foregroundColor(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Button {
                    
                } label: {
                    Text("Block")
                        .font(.system(size: 8))
                        .bold()
                        .foregroundStyle(.black)
                        .frame(height: 18)
                        .padding(.horizontal, 8)
                        .background {
                            Capsule()
                                .fill(.red)
                        }
                }
            }
            
            Spacer(minLength: 0)
            
            VStack(alignment: .trailing, spacing: 4) {
                // Faction
                if let faction = friend.faction {
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
                if let path = friend.path {
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
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.black.opacity(0.3))
//        )
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
    FriendsListView()
}
