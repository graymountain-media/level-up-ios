//
//  MessageBoardView.swift
//  Level Up Fitness
//
//  Created by Claude on 1/6/25.
//

import SwiftUI
import FactoryKit
import Supabase

struct MessageBoardView: View {
    @Environment(\.dismiss) var dismiss
    @Injected(\.messageBoardService) var messageBoardService
    
    @State private var selectedFilter: MessageFilter = .allPosts
    @State private var showingCreatePost = false
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedPost: Post?
    @State private var editingPost: Post?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Filter buttons
                filterSection
                
                // Create post button
                createPostSection
                
                // Posts list
                postsSection
            }
            .padding(.horizontal, 24)
            .mainBackground()
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView(onPostCreated: {
                Task {
                    await refreshPosts()
                }
            })
        }
        .task {
            await loadPosts()
        }
        .fullScreenCover(item: $selectedPost) { post in
            PostDetailView(post: post) { postNeedsRefresh in
                if postNeedsRefresh {
                    Task {
                        await loadPosts(silentRefresh: true)
                    }
                }
                selectedPost = nil
            }
        }
        .sheet(item: $editingPost) { post in
            CreatePostView(editingPost: post) {
                Task {
                    await refreshPosts()
                }
                editingPost = nil
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            FeatureHeader(title: "The Nexus", showCloseButton: true) {
                dismiss()
            }
            
            Text("WHERE FACTIONS CONVERGE")
                .font(.system(size: 12))
                .foregroundColor(.textBlue)
        }
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        HStack(spacing: 12) {
            ForEach(MessageFilter.allCases, id: \.self) { filter in
                if filter == .new {
                    Spacer()
                }
                filterButton(for: filter)
            }
        }
    }
    
    private func filterButton(for filter: MessageFilter) -> some View {
        Button(action: {
            selectedFilter = filter
            Task {
                await loadPosts()
            }
        }) {
            Text(filter.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(height: 36)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(selectedFilter == filter ? Color.textInput : Color.textfieldBorder)
                )
        }
    }
    
    // MARK: - Create Post Section
    
    private var createPostSection: some View {
        Button(action: {
            showingCreatePost = true
        }) {
            HStack(spacing: 8) {
                Text("Create a Post")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.textLight)
                Spacer()
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.majorDark)
                    .stroke(Color.textfieldBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Posts Section
    
    private var postsSection: some View {
        ScrollView {
            if isLoading && posts.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading posts...")
                        .foregroundColor(.textLight)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else if let errorMessage = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Failed to load posts")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button("Try Again") {
                        Task {
                            await loadPosts()
                        }
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else if posts.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Image(systemName: "message")
                        .font(.system(size: 50))
                        .foregroundColor(.textInput)
                    
                    VStack(spacing: 8) {
                        Text("No Posts Yet")
                            .font(.mainFont(size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(.title)
                        
                        Text("Be the first to share something with your faction!")
                            .font(.system(size: 14))
                            .foregroundColor(.textLight)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        showingCreatePost = true
                    }) {
                        Text("Create First Post")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.textOrange)
                            )
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                .padding(.horizontal, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(posts) { post in
                        PostCard(
                            post: post,
                            onLikeToggle: { post in
                                Task {
                                    await togglePostLike(post)
                                }
                            },
                            onEdit: { post in
                                editingPost = post
                            },
                            onDelete: { post in
                                Task {
                                    await deletePost(post)
                                }
                            },
                            onTap: { post in
                                selectedPost = post
                            }
                        )
                    }
                    
                    if isLoading {
                        ProgressView()
                            .padding()
                    }
                }
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func loadPosts(silentRefresh: Bool = false) async {
        print("📱 MessageBoardView: Starting to load posts...")
        if !silentRefresh {
            isLoading = true
        }
        errorMessage = nil
        
        let result = await messageBoardService.fetchPosts(filter: selectedFilter)
        
        await MainActor.run {
            isLoading = false
            
            switch result {
            case .success(let fetchedPosts):
                print("📱 MessageBoardView: Successfully loaded \(fetchedPosts.count) posts")
                self.posts = fetchedPosts
            case .failure(let error):
                print("📱 MessageBoardView: Failed to load posts - \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func refreshPosts() async {
        await loadPosts()
    }
    
    private func togglePostLike(_ post: Post) async {
        if post.userHasLiked {
            await messageBoardService.unlikePost(postId: post.id)
        } else {
            await messageBoardService.likePost(postId: post.id)
        }
        // Refresh posts to get updated counts
        await loadPosts()
    }
    
    private func deletePost(_ post: Post) async {
        let result = await messageBoardService.deletePost(postId: post.id)
        
        switch result {
        case .success:
            print("✅ MessageBoardView: Post deleted successfully")
            await loadPosts() // Refresh after deletion
        case .failure(let error):
            print("❌ MessageBoardView: Failed to delete post - \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Supporting Types

// MARK: - Post Card Component

struct PostCard: View {
    let post: Post
    let onLikeToggle: (Post) -> Void
    let onEdit: (Post) -> Void
    let onDelete: (Post) -> Void
    let onTap: (Post) -> Void
    
    @State private var showDeleteAlert = false
    
    private var isOwnPost: Bool {
        guard let currentUserId = client.auth.currentUser?.id else { return false }
        return currentUserId == post.userId
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            ProfilePicture(url: post.userProfilePicture, hasBorder: true)
                .onTapGesture {
                    onTap(post)
                }
            
            VStack(alignment: .leading, spacing: 10) {
                // Username and time
                HStack {
                    Text(post.userAvatarName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textLight)
                    
                    Text(timeAgoString(from: post.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(.textLight)
                    
                    Spacer()
                    
                    // Edit menu for own posts
                    if isOwnPost {
                        Menu {
                            Button("Edit") {
                                onEdit(post)
                            }
                            Button("Delete", role: .destructive) {
                                showDeleteAlert = true
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16))
                                .foregroundColor(.textLight)
                                .frame(width: 45, height: 30, alignment: .trailing)
                        }
                    }
                }
                .foregroundStyle(.textLight)
                
                // Content
                Text(post.content)
                    .font(.system(size: 14))
                    .foregroundColor(.title)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .onTapGesture {
                        onTap(post)
                    }
                // Action buttons
                HStack(spacing: 20) {
                    // Like button
                    Button(action: {
                        onLikeToggle(post)
                    }) {
                        HStack(spacing: 6) {
                            Image("like_arrow")
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                                .foregroundColor(post.userHasLiked ? .textOrange : .textInput)
                            
                            Text("\(post.likeCount)")
                                .font(.system(size: 12))
                                .foregroundColor(.textLight)
                        }
                    }
                    
                    // Comment button
                    Button(action: {
                        // Show comments action
                    }) {
                        HStack(spacing: 6) {
                            Image("comment_bubble")
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                                .foregroundColor(.textInput)
                            
                            Text("\(post.commentCount)")
                                .font(.system(size: 12))
                                .foregroundColor(.textLight)
                        }
                    }
                    
                    // Comment text (non-interactive)
                    HStack(spacing: 6) {
                        Image("comment_bubble")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                            .foregroundColor(.textInput)
                        Text("Comment")
                            .font(.system(size: 12))
                            .foregroundColor(.textLight)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.majorDark)
                .strokeBorder(Color.textfieldBorder)
                .onTapGesture {
                    onTap(post)
                }
                
        )
        .alert("Delete Post", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete(post)
            }
        } message: {
            Text("Are you sure you want to delete this post? This action cannot be undone.")
        }
    }
    
    // MARK: - Helper Methods
    
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        let minute: TimeInterval = 60
        let hour: TimeInterval = 60 * minute
        let day: TimeInterval = 24 * hour
        
        if timeInterval < minute {
            return "Just now"
        } else if timeInterval < hour {
            let minutes = Int(timeInterval / minute)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if timeInterval < day {
            let hours = Int(timeInterval / hour)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(timeInterval / day)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}

// MARK: - Preview

#Preview {
    let _ = Container.shared.setupMocks()
    MessageBoardView()
}
