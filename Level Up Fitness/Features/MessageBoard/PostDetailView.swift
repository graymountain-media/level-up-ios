//
//  PostDetailView.swift
//  Level Up Fitness
//
//  Created by Claude on 1/6/25.
//

import SwiftUI
import FactoryKit
import Supabase

struct PostDetailView: View {
    let post: Post
    @Injected(\.messageBoardService) var messageBoardService
    
    @State private var currentPost: Post
    @State private var comments: [Comment] = []
    @State private var newCommentText = ""
    @State private var isLoading = false
    @State private var isPostingComment = false
    @State private var errorMessage: String?
    @State private var showingEditMenu = false
    @State private var postNeedsRefresh: Bool = false
    @State private var likerProfileUrls: [String] = []
    
    let dismiss: (_ postNeedsRefresh: Bool) -> Void
    
    init(post: Post, dismiss: @escaping (_ postNeedsRefresh: Bool) -> Void) {
        self.post = post
        self._currentPost = State(initialValue: post)
        self.dismiss = dismiss
    }
    
    var userProfileImages: [URL] {
        return Array(likerProfileUrls.compactMap { URL(string: $0) }.prefix(10))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 0) {
                        mainPostSection
                        commentsSection
                    }
                    .scrollIndicators(.hidden)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { dismiss(postNeedsRefresh) }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18))
                                    .foregroundColor(.textfieldBorder)
                            }
                        }
                    }
                    .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.majorDark)
                            .strokeBorder(Color.textfieldBorder)
                    )
                    .padding(.horizontal, 24)
                    .padding(.top)
                }
                addCommentSection
            }
            .mainBackground()
        }
        .task {
            await loadComments()
            await loadPostLikers()
        }
    }
    
    // MARK: - Main Post Section
    
    private var mainPostSection: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top, spacing: 12) {
                // User avatar
                ProfilePicture(url: currentPost.userProfilePicture, hasBorder: true)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Username and time
                    HStack {
                        Text(currentPost.userAvatarName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textLight)
                        
                        Text(timeAgoString(from: currentPost.createdAt))
                            .font(.system(size: 14))
                            .foregroundColor(.textLight)
                        
                        Spacer()
                        
                        // Edit menu for own posts
                        if currentPost.userId == getCurrentUserId() {
                            Menu {
                                Button("Edit", action: { /* TODO: Edit post */ })
                                Button("Delete", role: .destructive, action: { /* TODO: Delete post */ })
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 16))
                                    .foregroundColor(.textLight)
                            }
                        }
                    }
                    
                    // Post content
                    Text(currentPost.content)
                        .font(.system(size: 16))
                        .foregroundColor(.title)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Like/comment actions
            HStack(spacing: 20) {
                // Like button
                Button(action: { toggleLike() }) {
                    HStack(spacing: 6) {
                        Image("like_arrow")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(currentPost.userHasLiked ? .textOrange : .textInput)
                        
                        Text("\(currentPost.likeCount)")
                            .font(.system(size: 14))
                            .foregroundColor(.textLight)
                    }
                }
                
                // Comments count (non-interactive)
                HStack(spacing: 0) {
                    ForEach(userProfileImages, id: \.self) { url in
                        CachedAsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                                .overlay {
                                    Circle()
                                        .strokeBorder(Color.textPath)
                                }
                                .padding(.leading, -6)
                        } placeholder: {
                            Image(systemName: "person")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(4)
                                .frame(width: 25, height: 25)
                                .foregroundStyle(Color.textLight)
                                .background {
                                    Color.majorDark
                                }
                                .clipShape(Circle())
                                .overlay {
                                    Circle()
                                        .strokeBorder(Color.textPath)
                                }
                                .padding(.leading, -6)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Comments Section
    
    private var commentsSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                } else if comments.isEmpty {
                    Text("No comments yet")
                        .foregroundColor(.textLight)
                        .padding(.vertical, 40)
                } else {
                    ForEach(comments) { comment in
                        CommentCard(comment: comment) { comment in
                            Task {
                                await toggleCommentLike(comment)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Add Comment Section
    
    private var addCommentSection: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.textfieldBorder)
            
            HStack(spacing: 12) {
                TextField("Add a Comment", text: $newCommentText)
                    .font(.system(size: 14))
                    .foregroundColor(.textInput)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.textfieldBg)
                            .stroke(Color.textfieldBorder, lineWidth: 1)
                    )
                
                Button("Send") {
                    Task {
                        await postComment()
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textBlue)
                .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPostingComment)
                .opacity(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.majorDark)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentUserId() -> UUID? {
        return client.auth.currentUser?.id
    }
    
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
            return "\(minutes) hour\(minutes == 1 ? "" : "s") ago"
        } else if timeInterval < day {
            let hours = Int(timeInterval / hour)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(timeInterval / day)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
    
    private func loadComments() async {
        isLoading = true
        let result = await messageBoardService.fetchComments(postId: currentPost.id)
        
        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let fetchedComments):
                self.comments = fetchedComments
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func postComment() async {
        let commentText = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !commentText.isEmpty else { return }
        
        isPostingComment = true
        let result = await messageBoardService.createComment(postId: currentPost.id, content: commentText)
        
        await MainActor.run {
            postNeedsRefresh = true
            isPostingComment = false
            switch result {
            case .success(let newComment):
                self.comments.append(newComment)
                self.newCommentText = ""
                // Update comment count
                self.currentPost = Post(
                    id: self.currentPost.id,
                    userId: self.currentPost.userId,
                    content: self.currentPost.content,
                    imageUrl: self.currentPost.imageUrl,
                    createdAt: self.currentPost.createdAt,
                    updatedAt: self.currentPost.updatedAt,
                    isEdited: self.currentPost.isEdited,
                    likeCount: self.currentPost.likeCount,
                    commentCount: self.currentPost.commentCount + 1,
                    userAvatarName: self.currentPost.userAvatarName,
                    userProfilePicture: self.currentPost.userProfilePicture,
                    userFaction: self.currentPost.userFaction,
                    userHeroPath: self.currentPost.userHeroPath,
                    userHasLiked: self.currentPost.userHasLiked
                )
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func toggleLike() {
        Task {
            let wasLiked = currentPost.userHasLiked
            let currentLikeCount = currentPost.likeCount
            
            if wasLiked {
                await messageBoardService.unlikePost(postId: currentPost.id)
            } else {
                await messageBoardService.likePost(postId: currentPost.id)
            }
            
            // Update local state immediately for responsive UI
            await MainActor.run {
                postNeedsRefresh = true
                self.currentPost = Post(
                    id: self.currentPost.id,
                    userId: self.currentPost.userId,
                    content: self.currentPost.content,
                    imageUrl: self.currentPost.imageUrl,
                    createdAt: self.currentPost.createdAt,
                    updatedAt: self.currentPost.updatedAt,
                    isEdited: self.currentPost.isEdited,
                    likeCount: wasLiked ? currentLikeCount - 1 : currentLikeCount + 1,
                    commentCount: self.currentPost.commentCount,
                    userAvatarName: self.currentPost.userAvatarName,
                    userProfilePicture: self.currentPost.userProfilePicture,
                    userFaction: self.currentPost.userFaction,
                    userHeroPath: self.currentPost.userHeroPath,
                    userHasLiked: !wasLiked
                )
            }
            
            // Refresh the liker profiles
            await loadPostLikers()
        }
    }
    
    private func toggleCommentLike(_ comment: Comment) async {
        if comment.userHasLiked {
            await messageBoardService.unlikeComment(commentId: comment.id)
        } else {
            await messageBoardService.likeComment(commentId: comment.id)
        }
        postNeedsRefresh = true
        // TODO: Update local comment state or refresh comments
        await loadComments() // For now, refresh all comments
    }
    
    private func loadPostLikers() async {
        let result = await messageBoardService.fetchPostLikers(postId: currentPost.id)
        
        await MainActor.run {
            switch result {
            case .success(let profileUrls):
                self.likerProfileUrls = profileUrls
            case .failure(let error):
                print("Failed to load post likers: \(error.localizedDescription)")
                self.likerProfileUrls = []
            }
        }
    }
}

// MARK: - Comment Card Component

struct CommentCard: View {
    let comment: Comment
    let toggleCommentLike: (_ comment: Comment) -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            ProfilePicture(url: comment.userAvatarImageUrl, hasBorder: true)
            
            VStack(alignment: .leading, spacing: 6) {
                // Username and time
                HStack {
                    Text(comment.userAvatarName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textLight)
                    
                    Text(timeAgoString(from: comment.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(.textLight)
                    
                    Spacer()
                }
                
                // Comment content
                Text(comment.content)
                    .font(.system(size: 14))
                    .foregroundColor(.title)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Like button
                Button(action: { 
                    toggleCommentLike(comment)
                }) {
                    HStack(spacing: 4) {
                        Image("like_arrow")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                            .foregroundColor(comment.userHasLiked ? .textOrange : .textInput)
                        
                        Text("\(comment.likeCount)")
                            .font(.system(size: 12))
                            .foregroundColor(.textLight)
                    }
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        let minute: TimeInterval = 60
        let hour: TimeInterval = 60 * minute
        
        if timeInterval < minute {
            return "Just now"
        } else if timeInterval < hour {
            let minutes = Int(timeInterval / minute)
            return "\(minutes) hour\(minutes == 1 ? "" : "s") ago"
        } else {
            let hours = Int(timeInterval / hour)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        }
    }
}

#Preview {
    
    let _ = Container.shared.setupMocks()
    let samplePost = Post(
        id: UUID(),
        userId: UUID(),
        content: "We need to organize a Mind Lab defense party",
        imageUrl: nil,
        createdAt: Date().addingTimeInterval(-3*3600),
        updatedAt: Date().addingTimeInterval(-3*3600),
        isEdited: false,
        likeCount: 1,
        commentCount: 3,
        userAvatarName: "WallyO",
        userProfilePicture: nil,
        userFaction: "echoreach",
        userHeroPath: "ranger",
        userHasLiked: false
    )
    
    PostDetailView(post: samplePost) { _ in }
}
