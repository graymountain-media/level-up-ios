import Foundation

class MockFriendsService: FriendsServiceProtocol {
    
    // Mock data storage
    private var mockFriendships: [Friendship] = []
    private var mockSearchableUsers: [SearchableUser] = []
    private var sentRequestIds: Set<UUID> = []
    private let currentUserId = UUID() // Mock current user ID
    
    init() {
        setupMockData()
    }
    
    private func setupMockData() {
        let currentDate = Date()
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: currentDate) ?? currentDate
        
        // Create mock friendships with unified model
        mockFriendships = [
            // Accepted friends
            Friendship(
                friendshipId: Int64.random(in: 1...1000000),
                user1: currentUserId,
                user2: UUID(),
                status: .accepted,
                createdAt: pastDate,
                isCurrentUserInitiator: true,
                otherUserId: UUID(),
                otherDisplayName: "Alex Johnson",
                otherAvatarName: "SHADOWBLADE",
                otherProfilePictureUrl: "https://via.placeholder.com/60",
                otherFaction: .pulseforge,
                otherHeroPath: .ranger,
                otherCurrentLevel: 12
            ),
            Friendship(
                friendshipId: Int64.random(in: 1...1000000),
                user1: UUID(),
                user2: currentUserId,
                status: .accepted,
                createdAt: pastDate,
                isCurrentUserInitiator: false,
                otherUserId: UUID(),
                otherDisplayName: "Sarah Chen",
                otherAvatarName: "STARFIRE",
                otherProfilePictureUrl: "https://via.placeholder.com/60",
                otherFaction: .neurospire,
                otherHeroPath: .brute,
                otherCurrentLevel: 8
            ),
            Friendship(
                friendshipId: Int64.random(in: 1...1000000),
                user1: currentUserId,
                user2: UUID(),
                status: .accepted,
                createdAt: pastDate,
                isCurrentUserInitiator: true,
                otherUserId: UUID(),
                otherDisplayName: "Mike Rodriguez",
                otherAvatarName: "IRONWILL",
                otherProfilePictureUrl: "https://via.placeholder.com/60",
                otherFaction: .voidkind,
                otherHeroPath: .champion,
                otherCurrentLevel: 15
            ),
            
            // Incoming friend requests (user is user2, others are user1)
            Friendship(
                friendshipId: Int64.random(in: 1...1000000),
                user1: UUID(),
                user2: currentUserId,
                status: .pending,
                createdAt: currentDate,
                isCurrentUserInitiator: false,
                otherUserId: UUID(),
                otherDisplayName: "Emma Wilson",
                otherAvatarName: "MOONLIGHT",
                otherProfilePictureUrl: "https://via.placeholder.com/60",
                otherFaction: .echoreach,
                otherHeroPath: nil,
                otherCurrentLevel: 6
            ),
            Friendship(
                friendshipId: Int64.random(in: 1...1000000),
                user1: UUID(),
                user2: currentUserId,
                status: .pending,
                createdAt: Calendar.current.date(byAdding: .hour, value: -2, to: currentDate) ?? currentDate,
                isCurrentUserInitiator: false,
                otherUserId: UUID(),
                otherDisplayName: "David Kim",
                otherAvatarName: "THUNDERSTRIKE",
                otherProfilePictureUrl: "https://via.placeholder.com/60",
                otherFaction: .pulseforge,
                otherHeroPath: .brute,
                otherCurrentLevel: 4
            ),
            
            // Outgoing friend requests (user is user1, others are user2)
            Friendship(
                friendshipId: Int64.random(in: 1...1000000),
                user1: currentUserId,
                user2: UUID(),
                status: .pending,
                createdAt: Calendar.current.date(byAdding: .hour, value: -1, to: currentDate) ?? currentDate,
                isCurrentUserInitiator: true,
                otherUserId: UUID(),
                otherDisplayName: "Lisa Park",
                otherAvatarName: "CRIMSONROSE",
                otherProfilePictureUrl: "https://via.placeholder.com/60",
                otherFaction: .neurospire,
                otherHeroPath: nil,
                otherCurrentLevel: 7
            ),
            
            // Blocked users
            Friendship(
                friendshipId: Int64.random(in: 1...1000000),
                user1: currentUserId,
                user2: UUID(),
                status: .blocked,
                createdAt: Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate,
                isCurrentUserInitiator: true,
                otherUserId: UUID(),
                otherDisplayName: "John Spam",
                otherAvatarName: "SPAMMER123",
                otherProfilePictureUrl: "https://via.placeholder.com/60",
                otherFaction: nil,
                otherHeroPath: nil,
                otherCurrentLevel: 1
            )
        ]
        
        // Mock searchable users
        mockSearchableUsers = [
            SearchableUser(
                userId: UUID(),
                displayName: "Phoenix Wright",
                avatarName: "PHOENIX",
                profilePictureUrl: "https://via.placeholder.com/60",
                faction: .pulseforge,
                path: nil,
                currentLevel: 7
            ),
            SearchableUser(
                userId: UUID(),
                displayName: "Maya Fey",
                avatarName: "MYSTIC",
                profilePictureUrl: "https://via.placeholder.com/60",
                faction: .neurospire,
                path: .hunter,
                currentLevel: 5
            ),
            SearchableUser(
                userId: UUID(),
                displayName: "Miles Edgeworth",
                avatarName: "PROSECUTOR",
                profilePictureUrl: "https://via.placeholder.com/60",
                faction: .voidkind,
                path: .juggernaut,
                currentLevel: 11
            ),
            SearchableUser(
                userId: UUID(),
                displayName: "Pearl Fey",
                avatarName: "PEARL",
                profilePictureUrl: "https://via.placeholder.com/60",
                faction: .echoreach,
                path: .brute,
                currentLevel: 3
            ),
            SearchableUser(
                userId: UUID(),
                displayName: "Franziska von Karma",
                avatarName: "WHIPLASH",
                profilePictureUrl: "https://via.placeholder.com/60",
                faction: .voidkind,
                path: .sentinel,
                currentLevel: 9
            )
        ]
    }
    
    // MARK: - Protocol Implementation
    
    func fetchAllFriendships() async -> Result<AllFriendships, FriendsError> {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let allFriendships = AllFriendships(friendships: mockFriendships)
        return .success(allFriendships)
    }
    
    func sendFriendRequest(to userId: UUID) async -> Result<Void, FriendsError> {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Check if trying to friend self
        guard currentUserId != userId else {
            return .failure(.cannotFriendSelf)
        }
        
        // Check if friendship already exists
        if mockFriendships.contains(where: { $0.otherUserId == userId }) {
            let existingFriendship = mockFriendships.first { $0.otherUserId == userId }!
            if existingFriendship.status == .accepted {
                return .failure(.alreadyFriends)
            } else if existingFriendship.status == .pending {
                return .failure(.friendRequestAlreadyExists)
            }
        }
        
        // Find user in searchable users to get their info
        guard let targetUser = mockSearchableUsers.first(where: { $0.userId == userId }) else {
            return .failure(.userNotFound)
        }
        
        // Create new outgoing friend request
        let newFriendship = Friendship(
            friendshipId: Int64.random(in: 1000001...2000000),
            user1: currentUserId,
            user2: userId,
            status: .pending,
            createdAt: Date(),
            isCurrentUserInitiator: true,
            otherUserId: userId,
            otherDisplayName: targetUser.displayName,
            otherAvatarName: targetUser.avatarName,
            otherProfilePictureUrl: targetUser.profilePictureUrl,
            otherFaction: targetUser.faction,
            otherHeroPath: nil,
            otherCurrentLevel: targetUser.currentLevel
        )
        
        mockFriendships.append(newFriendship)
        sentRequestIds.insert(userId)
        
        return .success(())
    }
    
    func acceptFriendRequest(friendshipId: Int64) async -> Result<Void, FriendsError> {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Find the friendship and update its status
        if let friendshipIndex = mockFriendships.firstIndex(where: { $0.friendshipId == friendshipId }) {
            var friendship = mockFriendships[friendshipIndex]
            
            // Create updated friendship with accepted status
            let updatedFriendship = Friendship(
                friendshipId: friendship.friendshipId,
                user1: friendship.user1,
                user2: friendship.user2,
                status: .accepted,
                createdAt: friendship.createdAt,
                isCurrentUserInitiator: friendship.isCurrentUserInitiator,
                otherUserId: friendship.otherUserId,
                otherDisplayName: friendship.otherDisplayName,
                otherAvatarName: friendship.otherAvatarName,
                otherProfilePictureUrl: friendship.otherProfilePictureUrl,
                otherFaction: friendship.otherFaction,
                otherHeroPath: friendship.otherHeroPath,
                otherCurrentLevel: friendship.otherCurrentLevel
            )
            
            mockFriendships[friendshipIndex] = updatedFriendship
            return .success(())
        }
        
        return .failure(.userNotFound)
    }
    
    func rejectFriendRequest(friendshipId: Int64) async -> Result<Void, FriendsError> {
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Remove the friendship entirely (since rejection deletes the record)
        if let friendshipIndex = mockFriendships.firstIndex(where: { $0.friendshipId == friendshipId }) {
            mockFriendships.remove(at: friendshipIndex)
            return .success(())
        }
        
        return .failure(.userNotFound)
    }
    
    func blockUser(userId: UUID) async -> Result<Void, FriendsError> {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Find existing friendship if any and update to blocked, or create new blocked friendship
        if let existingIndex = mockFriendships.firstIndex(where: { $0.otherUserId == userId }) {
            // Update existing friendship to blocked
            let existingFriendship = mockFriendships[existingIndex]
            let blockedFriendship = Friendship(
                friendshipId: existingFriendship.friendshipId,
                user1: existingFriendship.user1,
                user2: existingFriendship.user2,
                status: .blocked,
                createdAt: existingFriendship.createdAt,
                isCurrentUserInitiator: existingFriendship.isCurrentUserInitiator,
                otherUserId: existingFriendship.otherUserId,
                otherDisplayName: existingFriendship.otherDisplayName,
                otherAvatarName: existingFriendship.otherAvatarName,
                otherProfilePictureUrl: existingFriendship.otherProfilePictureUrl,
                otherFaction: existingFriendship.otherFaction,
                otherHeroPath: existingFriendship.otherHeroPath,
                otherCurrentLevel: existingFriendship.otherCurrentLevel
            )
            mockFriendships[existingIndex] = blockedFriendship
        } else {
            // Create new blocked relationship
            let userData = mockSearchableUsers.first(where: { $0.userId == userId })
            let newBlockedFriendship = Friendship(
                friendshipId: Int64.random(in: 2000001...3000000),
                user1: currentUserId,
                user2: userId,
                status: .blocked,
                createdAt: Date(),
                isCurrentUserInitiator: true,
                otherUserId: userId,
                otherDisplayName: userData?.displayName ?? "Unknown User",
                otherAvatarName: userData?.avatarName ?? "UNKNOWN",
                otherProfilePictureUrl: userData?.profilePictureUrl ?? "https://via.placeholder.com/60",
                otherFaction: userData?.faction,
                otherHeroPath: nil,
                otherCurrentLevel: userData?.currentLevel ?? 1
            )
            mockFriendships.append(newBlockedFriendship)
        }
        
        return .success(())
    }
    
    func removeFriend(userId: UUID) async -> Result<Void, FriendsError> {
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Remove the accepted friendship
        if let friendshipIndex = mockFriendships.firstIndex(where: { $0.otherUserId == userId && $0.status == .accepted }) {
            mockFriendships.remove(at: friendshipIndex)
            return .success(())
        }
        
        return .failure(.userNotFound)
    }
    
    func searchUsers(query: String) async -> Result<[SearchableUser], FriendsError> {
        try? await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .success([])
        }
        
        // Filter users by avatar name (case insensitive)
        let filteredUsers = mockSearchableUsers.filter { user in
            user.avatarName.lowercased().contains(query.lowercased())
        }
        
        // Exclude users with existing relationships (accepted friends, pending requests, blocked users)
        let existingRelationshipIds = Set(mockFriendships.map { $0.otherUserId })
        
        let availableUsers = filteredUsers.filter { user in
            !existingRelationshipIds.contains(user.userId)
        }
        
        return .success(availableUsers)
    }
}
