//
//  ImageURLStorage.swift
//  Level Up
//
//  Created by Jake Gray on 8/24/25.
//


import Foundation
import Combine
import class UIKit.UIImage

public protocol ImageStorage: AnyObject {
    func getImage(for url: URL) -> AnyPublisher<UIImage?, Error>
    func cachedImage(with url: URL) -> UIImage?
    func clearStorage()
}

/// Simple and lightweight image caching without any 3rd party dependencies.
public final class ImageURLStorage: ImageStorage {
    public static let shared: ImageStorage = ImageURLStorage()

    private let cache: URLCache
    private let session: URLSession
    private let cacheSize: Int = .megaBytes(150)

    private init() {
        let config = URLSessionConfiguration.default
        cache = URLCache(memoryCapacity: cacheSize, diskCapacity: cacheSize)
        config.urlCache = cache
        config.requestCachePolicy = .reloadRevalidatingCacheData
        config.httpMaximumConnectionsPerHost = 5

        session = URLSession(configuration: config)
    }

    public func getImage(for url: URL) -> AnyPublisher<UIImage?, Error> {
        latestData(with: url)
            .map(UIImage.init)
            .eraseToAnyPublisher()
    }

    public func cachedImage(with url: URL) -> UIImage? {
        let request = URLRequest(url: url)
        let data = cache.cachedResponse(for: request)?.data
        return data.flatMap(UIImage.init)
    }

    public func clearStorage() {
        cache.removeAllCachedResponses()
    }
}

extension ImageURLStorage {
    private func latestData(with url: URL)  -> AnyPublisher<Data, Error> {
        let request = URLRequest(url: url)

        return session
            .dataTaskPublisher(for: request)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

private extension Int {
    static func megaBytes(_ number: Int) -> Int {
        number * 1024 * 1024
    }
}
