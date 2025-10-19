//
//  RemoteImageLoader.swift
//  GitHubExplorer
//
//  Created by Malik Abdul Ghani on 19/10/25.
//

import SwiftUI
import UIKit
import GithubExplorerUtils

@MainActor
public final class RemoteImageLoader: ObservableObject {
    /// Represents the current loading state of a remote image.
    public enum Phase: Equatable {
        /// Indicates that the image is currently being loaded.
        case loading

        /// Indicates that the image was successfully loaded.
        case success(Image)

        /// Indicates that the image failed to load.
        case failure
    }

    @Published public private(set) var phase: Phase = .loading

    private var url: URL?
    private let cache: any ImageDataCaching
    private var task: Task<Void, Never>?
    private let transitionAnimation = Animation.easeInOut(duration: Constants.avatarFadeDuration)

    public init(url: URL?, cache: any ImageDataCaching = ImageDataCache.shared) {
        self.url = url
        self.cache = cache
    }
}

// MARK: - Public Functionality
public extension RemoteImageLoader {
    /// Starts loading the image from the current URL.
    func load() {
        guard task == nil else {
            return
        }

        guard let currentURL = url else {
            setPhase(.failure, animated: true)
            return
        }

        task = Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            
            defer {
                self.task = nil
            }

            if Task.isCancelled {
                return
            }

            if let data = await cache.data(for: currentURL), let image = makeImage(from: data) {
                if Task.isCancelled {
                    return
                }

                setPhase(.success(image), animated: false)
                return
            }

            if Task.isCancelled {
                return
            }

            setPhase(.loading, animated: phase != .loading)
            await fetchImage(from: currentURL)
        }
    }

    /// Updates the image loader with a new URL and triggers a reload if needed.
    ///
    /// - Parameter newURL: The new image URL to load.
    func updateURL(_ newURL: URL?) {
        guard newURL != url else {
            return
        }
        
        cancel()
        url = newURL
        load()
    }

    /// Cancels any ongoing image loading task and clears its reference.
    func cancel() {
        task?.cancel()
        task = nil
    }
}

// MARK: - Private Functionality
private extension RemoteImageLoader {
    /// Fetches image data from the given URL asynchronously and updates the loading state.
    ///
    /// - Parameter url: The URL of the image to fetch.
    func fetchImage(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if Task.isCancelled {
                return
            }

            if let image = makeImage(from: data) {
                await cache.insert(data, for: url)
                setPhase(.success(image), animated: true)
            } else {
                setPhase(.failure, animated: true)
            }
        } catch {
            if Task.isCancelled {
                return
            }
            
            setPhase(.failure, animated: true)
        }
    }

    /// Converts raw image data into a SwiftUI `Image` object
    ///
    /// - Parameter data: The raw image data to convert.
    /// - Returns: A SwiftUI `Image` if the data can be decoded, otherwise `nil`.
    func makeImage(from data: Data) -> Image? {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
    
    /// Updates the current image loading phase, with optional animation.
    ///
    /// - Parameters:
    ///   - newPhase: The new image loading state to apply.
    ///   - animated: A Boolean value indicating whether the state change should be animated.
    func setPhase(_ newPhase: Phase, animated: Bool) {
        guard phase != newPhase else {
            return
        }

        if animated {
            withAnimation(transitionAnimation) {
                phase = newPhase
            }
        } else {
            phase = newPhase
        }
    }
}
