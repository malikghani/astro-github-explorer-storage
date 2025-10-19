//
//  ImageDataCache.swift
//  GitHubExplorer
//
//  Created by Malik Abdul Ghani on 19/10/25.
//

import Foundation
import GithubExplorerUtils

/// A concrete `actor` implementation of `ImageDataCaching` that uses `NSCache` for in-memory storage.
public actor ImageDataCache: ImageDataCaching {
    /// A shared singleton instance of `ImageDataCache` for global use.
    public static let shared = ImageDataCache()
    
    private let cache: NSCache<NSURL, NSData>

    private init() {
        cache = NSCache<NSURL, NSData>()
        cache.countLimit = Constants.cacheCountLimit
        cache.totalCostLimit = Constants.cacheTotalCostLimit
    }

    /// Retrieves cached image data for the given URL.
    ///
    /// - Parameter url: The URL associated with the cached image.
    /// - Returns: The cached image data if found, otherwise `nil`.
    public func data(for url: URL) async -> Data? {
        cache.object(forKey: url as NSURL) as Data?
    }

    /// Stores the given image data in the cache for the specified URL.
    ///
    /// - Parameters:
    ///   - data: The image data to cache.
    ///   - url: The URL to associate with the cached image data.
    ///
    /// The `cost` parameter is set to the size of the data in bytes to help `NSCache`
    /// decide when to evict objects if memory limits are reached.
    public func insert(_ data: Data, for url: URL) async {
        cache.setObject(data as NSData, forKey: url as NSURL, cost: data.count)
    }
}
