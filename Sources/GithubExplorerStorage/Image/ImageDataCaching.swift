//
//  ImageDataCaching.swift
//  GitHubExplorer
//
//  Created by Malik Abdul Ghani on 19/10/25.
//

import Foundation

/// A protocol that defines the requirements for caching image data in memory.
public protocol ImageDataCaching: Sendable {
    /// Retrieves cached image data for the given URL.
    ///
    /// - Parameter url: The URL associated with the cached image.
    /// - Returns: The cached image data if it exists, otherwise `nil`.
    func data(for url: URL) async -> Data?
    
    /// Stores the given image data in the cache for the specified URL.
    ///
    /// - Parameters:
    ///   - data: The image data to cache.
    ///   - url: The URL to associate with the cached image data.
    func insert(_ data: Data, for url: URL) async
}
