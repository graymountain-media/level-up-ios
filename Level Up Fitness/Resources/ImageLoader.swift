//
//  ImageLoader.swift
//  Level Up
//
//  Created by Jake Gray on 8/24/25.
//


import Foundation
import Combine
import class UIKit.UIImage

final class ImageLoader: ObservableObject {
    @Published var image: UIImage
    private var subscriptions = Set<AnyCancellable>()

    init(url: URL?, placeholder: UIImage = #imageLiteral(resourceName: "placeholder")) {
        image = placeholder
        guard let url = url else {
            return
        }

        ImageURLStorage.shared
            .cachedImage(with: url)
            .map { image = $0 }

        ImageURLStorage.shared
            .getImage(for: url)
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    self?.image = $0
                })
            .store(in: &subscriptions)
    }
}

final class OptionalImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var subscriptions = Set<AnyCancellable>()

    init(url: URL?, placeholder: UIImage? = nil) {
        image = placeholder
        guard let url = url else {
            return
        }

        ImageURLStorage.shared
            .cachedImage(with: url)
            .map { image = $0 }

        ImageURLStorage.shared
            .getImage(for: url)
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    self?.image = $0
                })
            .store(in: &subscriptions)
    }
}

final class DynamicImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    private var subscriptions = Set<AnyCancellable>()
    private var currentURL: URL?

    func loadImage(from url: URL?) {
        // Don't reload if it's the same URL and we already have an image
        if currentURL == url && image != nil {
            return
        }
        
        currentURL = url
        subscriptions.removeAll()
        
        guard let url = url else {
            image = nil
            isLoading = false
            return
        }

        // Check cache first
        if let cachedImage = ImageURLStorage.shared.cachedImage(with: url) {
            image = cachedImage
            isLoading = false
            return
        }

        // Load from network
        isLoading = true
        ImageURLStorage.shared
            .getImage(for: url)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] loadedImage in
                    // Only update if this is still the current URL
                    guard self?.currentURL == url else { return }
                    self?.image = loadedImage
                    self?.isLoading = false
                })
            .store(in: &subscriptions)
    }
    
    func preloadImages(urls: [URL]) {
        for url in urls {
            // Check if already cached
            if ImageURLStorage.shared.cachedImage(with: url) != nil {
                continue
            }
            
            // Preload in background
            ImageURLStorage.shared
                .getImage(for: url)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { _ in })
                .store(in: &subscriptions)
        }
    }
}
