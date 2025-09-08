//
//  MessageBoardService.swift
//  Level Up Fitness
//
//  Created by Claude on 1/6/25.
//

import Foundation
import FactoryKit
import Supabase

// MARK: - Enums

enum MessageFilter: CaseIterable {
    case allPosts
    case hot
    case new
    
    var title: String {
        switch self {
        case .allPosts: return "All Posts"
        case .hot: return "Hot"
        case .new: return "New"
        }
    }
}

// MARK: - Models

struct PostWithUserResponse: Codable {
    let id: UUID
    let userId: UUID
    let content: String
    let imageUrl: String?
    let createdAt: Date
    let updatedAt: Date
    let isEdited: Bool
    let likeCount: Int
    let commentCount: Int
    let userHasLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, content
        case userId = "user_id"
        case imageUrl = "image_url"  
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isEdited = "is_edited"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case userHasLiked = "user_has_liked"
    }
}

struct PostsWithUsersResponse: Codable {
    let posts: [PostWithUserResponse]
    let users: [UserProfile]
}

struct CommentWithUserResponse: Codable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let isEdited: Bool
    let likeCount: Int
    let userHasLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, content
        case postId = "post_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isEdited = "is_edited"
        case likeCount = "like_count"
        case userHasLiked = "user_has_liked"
    }
}

struct CommentUserProfile: Codable {
    let id: UUID
    let avatarName: String?
    let profilePictureUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case avatarName = "avatar_name"
        case profilePictureUrl = "profile_picture_url"
    }
}

struct CommentsWithUsersResponse: Codable {
    let comments: [CommentWithUserResponse]
    let users: [CommentUserProfile]
}

struct UserProfile: Codable {
    let id: UUID
    let avatarName: String?
    let profilePictureUrl: String?
    let faction: String?
    let heroPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case avatarName = "avatar_name"
        case profilePictureUrl = "profile_picture_url"
        case faction = "faction"
        case heroPath = "hero_path"
    }
}

struct PostResponse: Codable {
    let id: UUID
    let userId: UUID
    let content: String
    let imageUrl: String?
    let createdAt: Date
    let updatedAt: Date
    let isEdited: Bool
    let likeCount: Int
    let commentCount: Int
    let profiles: ProfileInfo
    
    enum CodingKeys: String, CodingKey {
        case id, content, isEdited, likeCount, commentCount, profiles
        case userId = "user_id"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ProfileInfo: Codable {
    let avatarName: String?
    let avatarImageUrl: String?
    let faction: String?
    let heroPath: String?
    
    enum CodingKeys: String, CodingKey {
        case avatarName = "avatar_name"
        case avatarImageUrl = "avatar_image_url"
        case faction = "faction"
        case heroPath = "hero_path"
    }
}

struct Post: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let content: String
    let imageUrl: String?
    let createdAt: Date
    let updatedAt: Date
    let isEdited: Bool
    let likeCount: Int
    let commentCount: Int
    
    // User info (from join)
    let userAvatarName: String
    let userProfilePicture: String?
    let userFaction: String?
    let userHeroPath: String?
    
    // Current user context
    let userHasLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, content, createdAt, updatedAt, isEdited, likeCount, commentCount
        case userId = "user_id"
        case imageUrl = "image_url"
        case userAvatarName = "avatar_name"
        case userProfilePicture = "profile_picture_url"
        case userFaction = "faction"
        case userHeroPath = "hero_path"
        case userHasLiked = "user_has_liked"
    }
}

struct Comment: Codable, Identifiable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let isEdited: Bool
    let likeCount: Int
    
    // User info (from join)
    let userAvatarName: String
    let userAvatarImageUrl: String?
    
    // Current user context
    let userHasLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, content, createdAt, updatedAt, isEdited, likeCount
        case postId = "post_id"
        case userId = "user_id"
        case userAvatarName = "avatar_name"
        case userAvatarImageUrl = "avatar_image_url"
        case userHasLiked = "user_has_liked"
    }
}

// MARK: - Errors

enum MessageBoardError: LocalizedError {
    case networkError(String)
    case decodingError(String)
    case unauthorizedError
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Data error: \(message)"
        case .unauthorizedError:
            return "You must be logged in to perform this action"
        case .unknownError(let message):
            return "An error occurred: \(message)"
        }
    }
}

// MARK: - Protocol

@MainActor
protocol MessageBoardServiceProtocol {
    func fetchPosts(filter: MessageFilter) async -> Result<[Post], MessageBoardError>
    func createPost(content: String, imageUrl: String?) async -> Result<Post, MessageBoardError>
    func likePost(postId: UUID) async -> Result<Void, MessageBoardError>
    func unlikePost(postId: UUID) async -> Result<Void, MessageBoardError>
    
    func fetchComments(postId: UUID) async -> Result<[Comment], MessageBoardError>
    func createComment(postId: UUID, content: String) async -> Result<Comment, MessageBoardError>
    func likeComment(commentId: UUID) async -> Result<Void, MessageBoardError>
    func unlikeComment(commentId: UUID) async -> Result<Void, MessageBoardError>
    
    func fetchPostLikers(postId: UUID) async -> Result<[String], MessageBoardError>
}

// MARK: - Implementation

@MainActor
class MessageBoardService: MessageBoardServiceProtocol {
    
    func fetchPosts(filter: MessageFilter) async -> Result<[Post], MessageBoardError> {
        do {
            guard let currentUserId = client.auth.currentUser?.id else {
                return .failure(.unauthorizedError)
            }
            
            print("🔍 MessageBoardService: Fetching posts for user \(currentUserId)")
            
            // Call the database function to get posts and users in one call
            let response: PostsWithUsersResponse = try await client
                .rpc("get_posts_with_users", params: [
                    "current_user_id": currentUserId.uuidString
                ])
                .execute()
                .value
            
            print("📦 MessageBoardService: Retrieved \(response.posts.count) posts and \(response.users.count) user profiles")
            
            // Create a lookup dictionary for users
            var userProfiles: [UUID: UserProfile] = [:]
            for user in response.users {
                userProfiles[user.id] = user
            }
            
            // Convert to Post models with user info
            let allPosts = response.posts.map { postData in
                let userProfile = userProfiles[postData.userId]
                return Post(
                    id: postData.id,
                    userId: postData.userId,
                    content: postData.content,
                    imageUrl: postData.imageUrl,
                    createdAt: postData.createdAt,
                    updatedAt: postData.updatedAt,
                    isEdited: postData.isEdited,
                    likeCount: postData.likeCount,
                    commentCount: postData.commentCount,
                    userAvatarName: userProfile?.avatarName ?? "Unknown User",
                    userProfilePicture: userProfile?.profilePictureUrl,
                    userFaction: userProfile?.faction,
                    userHeroPath: userProfile?.heroPath,
                    userHasLiked: postData.userHasLiked
                )
            }
            
            // Apply local filtering
            let filteredPosts = applyFilter(posts: allPosts, filter: filter)
            
            print("✅ MessageBoardService: Returning \(filteredPosts.count) filtered posts (filter: \(filter))")
            return .success(filteredPosts)
        } catch {
            print("❌ MessageBoardService: Error fetching posts - \(error.localizedDescription)")
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    private func applyFilter(posts: [Post], filter: MessageFilter) -> [Post] {
        switch filter {
        case .allPosts:
            return posts.sorted { $0.createdAt > $1.createdAt }
        case .hot:
            return posts.sorted { 
                let score1 = $0.likeCount + $0.commentCount
                let score2 = $1.likeCount + $1.commentCount
                if score1 != score2 {
                    return score1 > score2
                }
                return $0.createdAt > $1.createdAt
            }
        case .new:
            return posts.sorted { $0.createdAt > $1.createdAt }
        }
    }
    
    func createPost(content: String, imageUrl: String?) async -> Result<Post, MessageBoardError> {
        do {
            guard let currentUserId = client.auth.currentUser?.id else {
                return .failure(.unauthorizedError)
            }
            
            let newPost = [
                "user_id": currentUserId.uuidString,
                "content": content,
                "image_url": imageUrl
            ]
            
            // Create the post in the database
            try await client
                .from("posts")
                .insert(newPost)
                .execute()
            
            // Create a temporary post object - in real implementation, 
            // you'd refetch the post with user info
            let tempPost = Post(
                id: UUID(),
                userId: currentUserId,
                content: content,
                imageUrl: imageUrl,
                createdAt: Date(),
                updatedAt: Date(),
                isEdited: false,
                likeCount: 0,
                commentCount: 0,
                userAvatarName: "You",
                userProfilePicture: nil,
                userFaction: nil,
                userHeroPath: nil,
                userHasLiked: false
            )
            
            return .success(tempPost)
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    func likePost(postId: UUID) async -> Result<Void, MessageBoardError> {
        do {
            guard let currentUserId = client.auth.currentUser?.id else {
                return .failure(.unauthorizedError)
            }
            
            let like = [
                "post_id": postId.uuidString,
                "user_id": currentUserId.uuidString
            ]
            
            try await client
                .from("post_likes")
                .insert(like)
                .execute()
            
            return .success(())
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    func unlikePost(postId: UUID) async -> Result<Void, MessageBoardError> {
        do {
            guard let currentUserId = client.auth.currentUser?.id else {
                return .failure(.unauthorizedError)
            }
            
            try await client
                .from("post_likes")
                .delete()
                .eq("post_id", value: postId.uuidString)
                .eq("user_id", value: currentUserId.uuidString)
                .execute()
            
            return .success(())
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    func fetchPostLikers(postId: UUID) async -> Result<[String], MessageBoardError> {
        do {
            // Use database function to bypass RLS and get liker profile pictures
            let response: [[String: AnyJSON]] = try await client
                .rpc("get_post_liker_avatars", params: [
                    "post_id_param": postId.uuidString
                ])
                .execute()
                .value
            
            let profileUrls = response.compactMap { row in
                row["profile_picture_url"]?.stringValue
            }
            
            return .success(profileUrls)
        } catch {
            print("Failed to get images for post likers: \(error)")
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    func fetchComments(postId: UUID) async -> Result<[Comment], MessageBoardError> {
        do {
            guard let currentUserId = client.auth.currentUser?.id else {
                return .failure(.unauthorizedError)
            }
            
            print("🔍 MessageBoardService: Fetching comments for post \(postId)")
            
            // Call the database function to get comments and users in one call
            let response: CommentsWithUsersResponse = try await client
                .rpc("get_comments_with_users", params: [
                    "post_id_param": postId.uuidString,
                    "current_user_id": currentUserId.uuidString
                ])
                .execute()
                .value
            
            print("💬 MessageBoardService: Retrieved \(response.comments.count) comments and \(response.users.count) user profiles")
            
            // Create a lookup dictionary for users
            var userProfiles: [UUID: CommentUserProfile] = [:]
            for user in response.users {
                userProfiles[user.id] = user
            }
            
            // Convert to Comment models with user info
            let comments = response.comments.map { commentData in
                let userProfile = userProfiles[commentData.userId]
                return Comment(
                    id: commentData.id,
                    postId: commentData.postId,
                    userId: commentData.userId,
                    content: commentData.content,
                    createdAt: commentData.createdAt,
                    updatedAt: commentData.updatedAt,
                    isEdited: commentData.isEdited,
                    likeCount: commentData.likeCount,
                    userAvatarName: userProfile?.avatarName ?? "Unknown User",
                    userAvatarImageUrl: userProfile?.profilePictureUrl,
                    userHasLiked: commentData.userHasLiked
                )
            }
            
            print("✅ MessageBoardService: Returning \(comments.count) processed comments")
            return .success(comments)
        } catch {
            print("❌ MessageBoardService: Error fetching comments - \(error.localizedDescription)")
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    func createComment(postId: UUID, content: String) async -> Result<Comment, MessageBoardError> {
        do {
            guard let currentUserId = client.auth.currentUser?.id else {
                return .failure(.unauthorizedError)
            }
            
            print("💬 MessageBoardService: Creating comment on post \(postId)")
            
            let newCommentData = [
                "post_id": postId.uuidString,
                "user_id": currentUserId.uuidString,
                "content": content
            ]
            
            // Create the comment in the database
            try await client
                .from("comments")
                .insert(newCommentData)
                .execute()
            
            // Get current user's profile info for the response
            let userProfile: CommentUserProfile? = try? await client
                .from("profiles")
                .select("id, avatar_name, profile_picture_url")
                .eq("id", value: currentUserId.uuidString)
                .single()
                .execute()
                .value
            
            // Return the new comment with user info
            let newComment = Comment(
                id: UUID(), // We don't get the actual ID back, but it's not critical for the UI
                postId: postId,
                userId: currentUserId,
                content: content,
                createdAt: Date(),
                updatedAt: Date(),
                isEdited: false,
                likeCount: 0,
                userAvatarName: userProfile?.avatarName ?? "You",
                userAvatarImageUrl: userProfile?.profilePictureUrl,
                userHasLiked: false
            )
            
            print("✅ MessageBoardService: Comment created successfully")
            return .success(newComment)
        } catch {
            print("❌ MessageBoardService: Error creating comment - \(error.localizedDescription)")
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    func likeComment(commentId: UUID) async -> Result<Void, MessageBoardError> {
        do {
            guard let currentUserId = client.auth.currentUser?.id else {
                return .failure(.unauthorizedError)
            }
            
            let like = [
                "comment_id": commentId.uuidString,
                "user_id": currentUserId.uuidString
            ]
            
            try await client
                .from("comment_likes")
                .insert(like)
                .execute()
            
            return .success(())
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    func unlikeComment(commentId: UUID) async -> Result<Void, MessageBoardError> {
        do {
            guard let currentUserId = client.auth.currentUser?.id else {
                return .failure(.unauthorizedError)
            }
            
            try await client
                .from("comment_likes")
                .delete()
                .eq("comment_id", value: commentId.uuidString)
                .eq("user_id", value: currentUserId.uuidString)
                .execute()
            
            return .success(())
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
}

// MARK: - Mock Implementation

@MainActor
class MockMessageBoardService: MessageBoardServiceProtocol {
    func fetchPosts(filter: MessageFilter) async -> Result<[Post], MessageBoardError> {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let mockPosts: [Post] = [
            Post(
                id: UUID(),
                userId: UUID(),
                content: "We need to organize a Mind Lab defense party",
                imageUrl: nil,
                createdAt: Date().addingTimeInterval(-3*3600),
                updatedAt: Date().addingTimeInterval(-3*3600),
                isEdited: false,
                likeCount: 12,
                commentCount: 3,
                userAvatarName: "WallyO",
                userProfilePicture: nil,
                userFaction: "echoreach",
                userHeroPath: "ranger",
                userHasLiked: false
            ),
            Post(
                id: UUID(),
                userId: UUID(),
                content: "We need to organize a Mind Lab defense party",
                imageUrl: nil,
                createdAt: Date().addingTimeInterval(-3*3600),
                updatedAt: Date().addingTimeInterval(-3*3600),
                isEdited: false,
                likeCount: 12,
                commentCount: 3,
                userAvatarName: "WallyO",
                userProfilePicture: nil,
                userFaction: "echoreach",
                userHeroPath: "ranger",
                userHasLiked: false
            )
        ]
        
        return .success(mockPosts)
    }
    
    func createPost(content: String, imageUrl: String?) async -> Result<Post, MessageBoardError> {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let newPost = Post(
            id: UUID(),
            userId: UUID(),
            content: content,
            imageUrl: imageUrl,
            createdAt: Date(),
            updatedAt: Date(),
            isEdited: false,
            likeCount: 0,
            commentCount: 0,
            userAvatarName: "You",
            userProfilePicture: nil,
            userFaction: nil,
            userHeroPath: nil,
            userHasLiked: false
        )
        
        return .success(newPost)
    }
    
    func likePost(postId: UUID) async -> Result<Void, MessageBoardError> {
        return .success(())
    }
    
    func unlikePost(postId: UUID) async -> Result<Void, MessageBoardError> {
        return .success(())
    }
    
    func fetchComments(postId: UUID) async -> Result<[Comment], MessageBoardError> {
        return .success([
            Comment(id: UUID(), postId: UUID(), userId: UUID(), content: "This is a good idea!", createdAt: Date(), updatedAt: Date(), isEdited: false, likeCount: 2, userAvatarName: "Johnny Rocket", userAvatarImageUrl: nil, userHasLiked: false)
        ])
    }
    
    func createComment(postId: UUID, content: String) async -> Result<Comment, MessageBoardError> {
        let newComment = Comment(
            id: UUID(),
            postId: postId,
            userId: UUID(),
            content: content,
            createdAt: Date(),
            updatedAt: Date(),
            isEdited: false,
            likeCount: 0,
            userAvatarName: "You",
            userAvatarImageUrl: nil,
            userHasLiked: false
        )
        
        return .success(newComment)
    }
    
    func likeComment(commentId: UUID) async -> Result<Void, MessageBoardError> {
        return .success(())
    }
    
    func unlikeComment(commentId: UUID) async -> Result<Void, MessageBoardError> {
        return .success(())
    }
    
    func fetchPostLikers(postId: UUID) async -> Result<[String], MessageBoardError> {
        // Return mock profile picture URLs
        let mockProfileUrls = [
            "https://example.com/avatar1.jpg",
            "https://example.com/avatar2.jpg",
            "https://example.com/avatar3.jpg"
        ]
        return .success(mockProfileUrls)
    }
}
