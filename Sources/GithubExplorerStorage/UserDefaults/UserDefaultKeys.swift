//
//  UserDefaultKeys.swift
//  GitHubExplorer
//
//  Created by Malik Abdul Ghani on 19/10/25.
//

import Foundation

/// A strongly typed key used to store and retrieve values from `UserDefaults`.
public struct UserDefaultsKey<Value: Sendable>: Sendable {
    /// The string key used internally to identify the stored value in `UserDefaults`.
    let rawValue: String

    /// The default value returned when no value exists in `UserDefaults` for this key.
    let defaultValue: Value?

    /// Creates a new strongly typed key with an optional default value.
    ///
    /// - Parameters:
    ///   - rawValue: The string key used in `UserDefaults`.
    ///   - defaultValue: The default value to return if none is stored. Defaults to `nil`.
    init(_ rawValue: String, defaultValue: Value? = nil) {
        self.rawValue = rawValue
        self.defaultValue = defaultValue
    }
}

/// A collection of keys used for storing and retrieving values from `UserDefaults`.
public enum UserDefaultKeys {
    /// The key used to store the user's preferred search order setting in `UserDefaults`.
    public static let searchOrder = UserDefaultsKey<String>("search.order")
}
