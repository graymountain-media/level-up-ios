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
