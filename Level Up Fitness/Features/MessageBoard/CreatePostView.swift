//
//  CreatePostView.swift
//  Level Up Fitness
//
//  Created by Claude on 1/6/25.
//

import SwiftUI
import FactoryKit

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @Injected(\.messageBoardService) var messageBoardService
    
    @State private var postContent: String
    @State private var isPosting = false
    @State private var errorMessage: String?
    
    private let maxCharacters = 280
    private let editingPost: Post?
    let onPostCreated: () -> Void
    
    init(editingPost: Post? = nil, onPostCreated: @escaping () -> Void) {
        self.editingPost = editingPost
        self.onPostCreated = onPostCreated
        self._postContent = State(initialValue: editingPost?.content ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.majorDark.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Content input
                    VStack(alignment: .leading, spacing: 8) {
                        
                        TextEditor(text: $postContent)
                            .font(.system(size: 14))
                            .foregroundColor(.textInput)
                            .scrollContentBackground(.hidden)
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.textfieldBg)
                                    .stroke(.textfieldBorder, lineWidth: 1)
                            )
                            .frame(minHeight: 120)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    
                    // Character count
                    HStack {
                        Spacer()
                        Text("\(postContent.count)/\(maxCharacters)")
                            .font(.system(size: 12))
                            .foregroundColor(postContent.count > maxCharacters ? .red : .gray)
                    }
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(isEditMode ? "Edit Post" : "Create Post")
                        .font(.mainFont(size: 17))
                        .bold()
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Save" : "Post") {
                        if isEditMode {
                            editPost()
                        } else {
                            createPost()
                        }
                    }
                    .foregroundColor(canPost ? .textBlue : .gray)
                    .disabled(!canPost || isPosting)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                            .opacity(isPosting ? 1 : 0)
                    )
                }
            }
        }
        .presentationDetents([.medium, .large])
        .tint(.white)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    private var canPost: Bool {
        !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        postContent.count <= maxCharacters
    }
    
    private var isEditMode: Bool {
        editingPost != nil
    }
    
    private func createPost() {
        guard canPost else { return }
        
        isPosting = true
        errorMessage = nil
        
        Task {
            let result = await messageBoardService.createPost(content: postContent, imageUrl: nil)
            
            await MainActor.run {
                isPosting = false
                
                switch result {
                case .success:
                    onPostCreated()
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func editPost() {
        guard canPost, let post = editingPost else { return }
        
        isPosting = true
        errorMessage = nil
        
        Task {
            let result = await messageBoardService.editPost(postId: post.id, content: postContent, imageUrl: post.imageUrl)
            
            await MainActor.run {
                isPosting = false
                
                switch result {
                case .success:
                    onPostCreated() // This will trigger a refresh
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    CreatePostView(onPostCreated: {})
}
