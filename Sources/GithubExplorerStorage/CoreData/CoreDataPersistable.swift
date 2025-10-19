//
//  CoreDataPersistable.swift
//  GitHubExplorer
//
//  Created by Malik Abdul Ghani on 17/10/25.
//

import CoreData

/// A Core Data specific refinement of `ObjectPersistable`.
protocol CoreDataPersistable: ObjectPersistable {
    /// The Core Data entity name associated with this model.
    static var entityName: String { get }

    /// The managed object's identifier key path (used when building predicates).
    static var identifierKey: String { get }

    /// Default sort descriptors for fetch requests targeting this model. Defaults to `[]`.
    static var sortDescriptors: [NSSortDescriptor] { get }

    /// Initializes the model from a managed object instance.
    init?(managedObject: NSManagedObject)

    /// Applies the model state onto the provided managed object.
    func updateManagedObject(_ managedObject: NSManagedObject)
}
