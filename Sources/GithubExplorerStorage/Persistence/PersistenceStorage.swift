//
//  PersistenceStorage.swift
//  GitHubExplorer
//
//  Created by Malik Abdul Ghani on 17/10/25.
//

import Foundation

/// A protocol that defines the core requirements for persisting, retrieving,
/// and removing objects from a storage service.
protocol PersistenceStorage {
    /// Retrieves a persisted object by its unique identifier.
    ///
    /// - Parameters:
    ///   - id: The identifier of the object to fetch.
    ///   - type: The concrete type of the object to decode.
    /// - Returns: The object with the specified identifier, if it exists.
    func fetch<T: ObjectPersistable>(forId id: String, as type: T.Type) -> T?

    /// Retrieves all persisted objects of the given type.
    ///
    /// - Parameter type: The concrete type of objects to decode.
    /// - Returns: An array of stored objects matching the specified type.
    func fetch<T: ObjectPersistable>(for type: T.Type) -> [T]

    /// Persists (saves or updates) the given object in storage.
    ///
    /// - Parameter object: The object to store.
    func store<T: ObjectPersistable>(object: T)

    /// Removes an object with the given identifier from storage.
    ///
    /// - Parameters:
    ///   - id: The identifier of the object to remove.
    ///   - type: The concrete type of the object to remove.
    func remove<T: ObjectPersistable>(forId id: String, as type: T.Type)
}
