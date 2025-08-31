import Foundation
import Supabase
import Combine

enum FriendshipStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case blocked = "blocked"
}

// MARK: - Friendship Model

struct Friendship: Codable, Identifiable {
    let friendshipId: Int64
    let user1: UUID
    let user2: UUID
    let status: FriendshipStatus
    let createdAt: Date
    let isCurrentUserInitiator: Bool // true if current user is user1, false if user2
    
    // Other user's profile information (the friend/requester/blocked user)
    let otherUserId: UUID
    let otherDisplayName: String
    let otherAvatarName: String
    let otherProfilePictureUrl: String?
    let otherFaction: Faction?
    let otherHeroPath: HeroPath?
    let otherCurrentLevel: Int?
    
    var id: Int64 { friendshipId }
    
    enum CodingKeys: String, CodingKey {
        case friendshipId = "friendship_id"
        case user1 = "user_1"
        case user2 = "user_2"
        case status
        case createdAt = "created_at"
        case isCurrentUserInitiator = "is_current_user_initiator"
        case otherUserId = "other_user_id"
        case otherDisplayName = "other_display_name"
        case otherAvatarName = "other_avatar_name"
        case otherProfilePictureUrl = "other_profile_picture_url"
        case otherFaction = "other_faction"
        case otherHeroPath = "other_hero_path"
        case otherCurrentLevel = "other_current_level"
    }
    
    // Convenience computed properties for different relationship types
    var isIncoming: Bool {
        return status == .pending && !isCurrentUserInitiator
    }
    
    var isOutgoing: Bool {
        return status == .pending && isCurrentUserInitiator
    }
    
    var isAccepted: Bool {
        return status == .accepted
    }
    
    var isBlocked: Bool {
        return status == .blocked
    }
}

struct SearchableUser: Codable, Identifiable {
    let userId: UUID
    let displayName: String
    let avatarName: String
    let profilePictureUrl: String?
    let faction: Faction?
    let path: HeroPath?
    let currentLevel: Int
    
    var id: UUID { userId }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case displayName = "display_name"
        case avatarName = "avatar_name"
        case profilePictureUrl = "profile_picture_url"
        case faction
        case path
        case currentLevel = "current_level"
    }
}

struct AllFriendships: Codable {
    let friendships: [Friendship]
    
    // Computed properties to filter friendships by type
    var acceptedAndPending: [Friendship] {
        friendships.filter { $0.isAccepted || $0.isOutgoing  }
    }
    
    var incomingRequests: [Friendship] {
        friendships.filter { $0.isIncoming }
    }
    
    var blockedUsers: [Friendship] {
        friendships.filter { $0.isBlocked }
    }
}

enum FriendsError: LocalizedError {
    case notAuthenticated
    case userNotFound
    case alreadyFriends
    case friendRequestAlreadyExists
    case cannotFriendSelf
    case networkError(String)
    case databaseError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to manage friends"
        case .userNotFound:
            return "User not found"
        case .alreadyFriends:
            return "Already friends with this user"
        case .friendRequestAlreadyExists:
            return "Friend request already exists"
        case .cannotFriendSelf:
            return "Cannot send friend request to yourself"
        case .networkError(let message):
            return "Network error: \(message)"
        case .databaseError(let message):
            return "Database error: \(message)"
        case .unknownError(let message):
            return message
        }
    }
}

protocol FriendsServiceProtocol {
    func fetchAllFriendships() async -> Result<AllFriendships, FriendsError>
    func sendFriendRequest(to userId: UUID) async -> Result<Void, FriendsError>
    func acceptFriendRequest(friendshipId: Int64) async -> Result<Void, FriendsError>
    func rejectFriendRequest(friendshipId: Int64) async -> Result<Void, FriendsError>
    func blockUser(userId: UUID) async -> Result<Void, FriendsError>
    func removeFriend(userId: UUID) async -> Result<Void, FriendsError>
    func searchUsers(query: String) async -> Result<[SearchableUser], FriendsError>
}

class FriendsService: FriendsServiceProtocol {
    
    init() {}
    
    func fetchAllFriendships() async -> Result<AllFriendships, FriendsError> {
        do {
            let userId = try await client.auth.session.user.id
            
            let friendships: [Friendship] = try await client
                .rpc("get_user_friendships", params: ["user_id_param": userId])
                .execute()
                .value
            
            let allFriendships = AllFriendships(friendships: friendships)
            return .success(allFriendships)
            
        } catch {
            if error.localizedDescription.contains("Invalid JWT") || error.localizedDescription.contains("expired") {
                return .failure(.notAuthenticated)
            }
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func sendFriendRequest(to userId: UUID) async -> Result<Void, FriendsError> {
        do {
            let currentUserId = try await client.auth.session.user.id
            
            // Check if trying to friend self
            guard currentUserId != userId else {
                return .failure(.cannotFriendSelf)
            }
            
            // Create new friend request directly - let database constraints handle duplicates
            let newFriendship = [
                "user_1": currentUserId.uuidString,
                "user_2": userId.uuidString,
                "status": FriendshipStatus.pending.rawValue
            ]
            
            try await client
                .from("friendships")
                .insert(newFriendship)
                .execute()
            
            return .success(())
            
        } catch {
            if error.localizedDescription.contains("Invalid JWT") || error.localizedDescription.contains("expired") {
                return .failure(.notAuthenticated)
            }
            // Handle specific database constraint errors
            if error.localizedDescription.contains("duplicate") || error.localizedDescription.contains("already exists") {
                return .failure(.friendRequestAlreadyExists)
            }
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func acceptFriendRequest(friendshipId: Int64) async -> Result<Void, FriendsError> {
        do {
            try await client
                .from("friendships")
                .update(["status": FriendshipStatus.accepted.rawValue])
                .eq("id", value: Int(friendshipId))
                .execute()
            
            return .success(())
            
        } catch {
            if error.localizedDescription.contains("Invalid JWT") || error.localizedDescription.contains("expired") {
                return .failure(.notAuthenticated)
            }
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func rejectFriendRequest(friendshipId: Int64) async -> Result<Void, FriendsError> {
        do {
            // Delete the friendship instead of setting to rejected
            try await client
                .from("friendships")
                .delete()
                .eq("id", value: Int(friendshipId))
                .execute()
            
            return .success(())
            
        } catch {
            if error.localizedDescription.contains("Invalid JWT") || error.localizedDescription.contains("expired") {
                return .failure(.notAuthenticated)
            }
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func blockUser(userId: UUID) async -> Result<Void, FriendsError> {
        do {
            let currentUserId = try await client.auth.session.user.id
            
            // First, try to update existing friendship to blocked
            try await client
                .from("friendships")
                .update(["status": FriendshipStatus.blocked.rawValue])
                .or("and(user_1.eq.\(currentUserId),user_2.eq.\(userId)),and(user_1.eq.\(userId),user_2.eq.\(currentUserId))")
                .execute()
            
            // If no existing friendship was found, create new blocked relationship
            // We can use upsert with a conflict resolution or just insert and handle the error
            let newFriendship = [
                "user_1": currentUserId.uuidString,
                "user_2": userId.uuidString,
                "status": FriendshipStatus.blocked.rawValue
            ]
            
            try await client
                .from("friendships")
                .insert(newFriendship)
                .execute()
            
            return .success(())
            
        } catch {
            if error.localizedDescription.contains("Invalid JWT") || error.localizedDescription.contains("expired") {
                return .failure(.notAuthenticated)
            }
            // If duplicate error, it means we successfully updated the existing record
            if error.localizedDescription.contains("duplicate") || error.localizedDescription.contains("already exists") {
                return .success(())
            }
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func removeFriend(userId: UUID) async -> Result<Void, FriendsError> {
        do {
            let currentUserId = try await client.auth.session.user.id
            
            // Find and delete the friendship
            try await client
                .from("friendships")
                .delete()
                .or("and(user_1.eq.\(currentUserId),user_2.eq.\(userId)),and(user_1.eq.\(userId),user_2.eq.\(currentUserId))")
                .execute()
            
            return .success(())
            
        } catch {
            if error.localizedDescription.contains("Invalid JWT") || error.localizedDescription.contains("expired") {
                return .failure(.notAuthenticated)
            }
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func searchUsers(query: String) async -> Result<[SearchableUser], FriendsError> {
        do {
            let users: [SearchableUser] = try await client
                .rpc("search_users_for_friends", params: ["search_query": query])
                .execute()
                .value
            
            return .success(users)
            
        } catch {
            if error.localizedDescription.contains("Invalid JWT") || error.localizedDescription.contains("expired") {
                return .failure(.notAuthenticated)
            }
            return .failure(.databaseError(error.localizedDescription))
        }
    }
}
