//
//  CachedAsyncImage.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/24/25.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader = DynamicImageLoader()
    
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let uiImage = loader.image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .onAppear {
            loader.loadImage(from: url)
        }
        .onChange(of: url) { _, newURL in
            loader.loadImage(from: newURL)
        }
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    /// Simple initializer with default progress view placeholder
    init(url: URL?) {
        self.init(url: url) { image in
            image
        } placeholder: {
            ProgressView()
        }
    }
}

extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    /// Initializer with custom content but default placeholder
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(url: url, content: content) {
            ProgressView()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // Simple usage (like AsyncImage)
        CachedAsyncImage(url: URL(string: "https://via.placeholder.com/300"))
        
        // Custom content formatting
        CachedAsyncImage(url: URL(string: "https://via.placeholder.com/300")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        
        // Custom placeholder
        CachedAsyncImage(url: URL(string: "https://via.placeholder.com/300")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Text("Loading...")
                        .foregroundColor(.gray)
                )
        }
        
        // Profile picture example
        CachedAsyncImage(url: URL(string: "https://via.placeholder.com/100")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
        } placeholder: {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                )
        }
        
        Spacer()
    }
    .padding()
    .mainBackground()
}