//
//  UserDefaultsStorage.swift
//  GitHubExplorer
//
//  Created by Malik Abdul Ghani on 18/10/25.
//

import Foundation

/// Wrapper around `UserDefaults` that handles simple persistence needs.
public final class UserDefaultsStorage {
    @MainActor
    public static let shared = UserDefaultsStorage()
    
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Stores a value for the given key, removing the entry when `value` is `nil`.
    public func store<Value>(_ value: Value?, for key: UserDefaultsKey<Value>) {
        if let value {
            defaults.set(value, forKey: key.rawValue)
        } else {
            defaults.removeObject(forKey: key.rawValue)
        }
    }

    /// Fetches a value for the given key or returns the key's default value.
    public func fetch<Value>(for key: UserDefaultsKey<Value>) -> Value? {
        if let value = defaults.object(forKey: key.rawValue) as? Value {
            return value
        }

        return key.defaultValue
    }
}
