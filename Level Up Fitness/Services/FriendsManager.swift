//
//  FriendsManager.swift
//  Level Up Fitness
//
//  Created by Claude on 9/5/25.
//

import Foundation
import FactoryKit

// MARK: - Friend Status Types

enum FriendStatus {
    case notFriend
    case pendingIncoming     // They sent us a request
    case pendingOutgoing     // We sent them a request  
    case accepted           // We are friends
    case blocked           // We blocked them
    case blockedBy         // They blocked us (we won't know this directly from API)
    
    var displayText: String {
        switch self {
        case .notFriend:
            return "Add Friend"
        case .pendingIncoming:
            return "Accept Request"
        case .pendingOutgoing:
            return "Request Sent"
        case .accepted:
            return "Friends"
        case .blocked:
            return "Blocked"
        case .blockedBy:
            return "Unavailable"
        }
    }
    
    var isActionable: Bool {
        switch self {
        case .notFriend, .pendingIncoming:
            return true
        case .pendingOutgoing, .accepted, .blocked, .blockedBy:
            return false
        }
    }
}

// MARK: - Protocol

@MainActor
protocol FriendsManagerProtocol {
    var allFriendships: AllFriendships? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    func loadFriendships() async
    func getFriendStatus(for userId: UUID) -> FriendStatus
    func sendFriendRequest(to userId: UUID) async -> Result<Void, FriendsError>
    func acceptFriendRequest(from userId: UUID) async -> Result<Void, FriendsError>
    func rejectFriendRequest(friendshipId: Int64) async -> Result<Void, FriendsError>
    func blockUser(_ userId: UUID) async -> Result<Void, FriendsError>
    func removeFriend(_ userId: UUID) async -> Result<Void, FriendsError>
}

// MARK: - Implementation

@MainActor
@Observable
class FriendsManager: FriendsManagerProtocol {
    @ObservationIgnored @Injected(\.friendsService) var friendsService
    
    var allFriendships: AllFriendships?
    var isLoading = false
    var errorMessage: String?
    
    init() {
        Task {
            await loadFriendships()
        }
    }
    
    func loadFriendships() async {
        isLoading = true
        errorMessage = nil
        
        let result = await friendsService.fetchAllFriendships()
        
        switch result {
        case .success(let friendships):
            allFriendships = friendships
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func getFriendStatus(for userId: UUID) -> FriendStatus {
        guard let friendships = allFriendships else {
            return .notFriend
        }
        
        // Check if they sent us a request (incoming)
        if friendships.incomingRequests.contains(where: { $0.otherUserId == userId }) {
            return .pendingIncoming
        }
        
        // Check if we sent them a request (outgoing) or we're already friends
        if let friendship = friendships.acceptedAndPending.first(where: { $0.otherUserId == userId }) {
            if friendship.isOutgoing {
                return .pendingOutgoing
            } else {
                return .accepted
            }
        }
        
        // Check if we blocked them
        if friendships.blockedUsers.contains(where: { $0.otherUserId == userId }) {
            return .blocked
        }
        
        return .notFriend
    }
    
    func sendFriendRequest(to userId: UUID) async -> Result<Void, FriendsError> {
        let result = await friendsService.sendFriendRequest(to: userId)
        
        if case .success = result {
            await loadFriendships() // Refresh data
        }
        
        return result
    }
    
    func acceptFriendRequest(from userId: UUID) async -> Result<Void, FriendsError> {
        // Find the friendship ID for this user
        guard let friendship = allFriendships?.incomingRequests.first(where: { $0.otherUserId == userId }) else {
            return .failure(.unknownError("Friend request not found"))
        }
        
        let result = await friendsService.acceptFriendRequest(friendshipId: friendship.friendshipId)
        
        if case .success = result {
            await loadFriendships() // Refresh data
        }
        
        return result
    }
    
    func rejectFriendRequest(friendshipId: Int64) async -> Result<Void, FriendsError> {
        let result = await friendsService.rejectFriendRequest(friendshipId: friendshipId)
        
        if case .success = result {
            await loadFriendships() // Refresh data
        }
        
        return result
    }
    
    func blockUser(_ userId: UUID) async -> Result<Void, FriendsError> {
        let result = await friendsService.blockUser(userId: userId)
        
        if case .success = result {
            await loadFriendships() // Refresh data
        }
        
        return result
    }
    
    func removeFriend(_ userId: UUID) async -> Result<Void, FriendsError> {
        let result = await friendsService.removeFriend(userId: userId)
        
        if case .success = result {
            await loadFriendships() // Refresh data
        }
        
        return result
    }
}

// MARK: - Mock Implementation

@MainActor
@Observable
class MockFriendsManager: FriendsManagerProtocol {
    var allFriendships: AllFriendships?
    var isLoading = false
    var errorMessage: String?
    
    init() {
        // Set up some mock data
        allFriendships = AllFriendships(friendships: []
        )
    }
    
    func loadFriendships() async {
        // Mock implementation
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        isLoading = false
    }
    
    func getFriendStatus(for userId: UUID) -> FriendStatus {
        return .notFriend // Always return not friend for mock
    }
    
    func sendFriendRequest(to userId: UUID) async -> Result<Void, FriendsError> {
        return .success(())
    }
    
    func acceptFriendRequest(from userId: UUID) async -> Result<Void, FriendsError> {
        return .success(())
    }
    
    func blockUser(_ userId: UUID) async -> Result<Void, FriendsError> {
        return .success(())
    }
    
    func removeFriend(_ userId: UUID) async -> Result<Void, FriendsError> {
        return .success(())
    }
    
    func rejectFriendRequest(friendshipId: Int64) async -> Result<Void, FriendsError> {
        return .success(())
    }
}
