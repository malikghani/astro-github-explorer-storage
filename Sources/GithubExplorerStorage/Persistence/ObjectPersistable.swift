//
//  ObjectPersistable.swift
//  GitHubExplorer
//
//  Created by Malik Abdul Ghani on 17/10/25.
//

import Foundation

/// A lightweight protocol adopted by models that can be persisted by any storage service.
///
/// Concrete persistence layers can extend this protocol (via additional, storage-specific
/// refinements) to add the information they need without forcing every adopter to depend on a
/// particular framework such as Core Data.
public protocol ObjectPersistable {
    /// A unique identifier used to persist and look up the object.
    var persistenceIdentifier: String { get }
}
