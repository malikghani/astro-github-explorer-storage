//
//  CoreDataPersistenceStorage.swift
//  GitHubExplorer
//
//  Created by Malik Abdul Ghani on 17/10/25.
//

@preconcurrency import CoreData
import Foundation

/// A concrete Core Data–backed implementation of `PersistenceStorage`.
public final class CoreDataPersistenceStorage: PersistenceStorage {
    @MainActor
    public static let shared = CoreDataPersistenceStorage()

    private let container: NSPersistentContainer

    private var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(container: NSPersistentContainer? = nil) {
        if let container {
            self.container = container
        } else {
            let persistentContainer = NSPersistentContainer(name: "GitHubExplorer")
            persistentContainer.loadPersistentStores { _, error in
                if let error {
                    fatalError("Failed to load persistent stores: \(error)")
                }
            }

            persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            self.container = persistentContainer
        }
    }

    public func fetch<T: ObjectPersistable>(forId id: String, as type: T.Type) -> T? {
        guard let coreDataType = type as? CoreDataPersistable.Type else {
            return nil
        }
        
        do {
            let request = makeFetchRequest(for: coreDataType, limit: 1, identifier: id)
            
            guard let entity = try viewContext.fetch(request).first else {
                return nil
            }

            return coreDataType.init(managedObject: entity) as? T
        } catch {
            print("CoreDataPersistenceStorage fetch(forId:as:) error:", error)
            
            return nil
        }
    }

    public func fetch<T: ObjectPersistable>(for type: T.Type) -> [T] {
        guard let coreDataType = type as? CoreDataPersistable.Type else {
            return []
        }

        let request = makeFetchRequest(for: coreDataType)
        request.sortDescriptors = coreDataType.sortDescriptors

        do {
            return try viewContext
                .fetch(request)
                .compactMap { coreDataType.init(managedObject: $0) as? T }
        } catch {
            print("CoreDataPersistenceStorage fetch(for:) error:", error)
            
            return []
        }
    }

    public func store<T: ObjectPersistable>(object: T) {
        guard let coreDataObject = object as? CoreDataPersistable else {
            return
        }

        let type = Swift.type(of: coreDataObject)

        do {
            let entity = try fetchEntity(identifier: coreDataObject.persistenceIdentifier, type: type)
                ?? NSEntityDescription.insertNewObject(
                    forEntityName: type.entityName,
                    into: viewContext
                )

            coreDataObject.updateManagedObject(entity)
            try saveContextIfNeeded()
        } catch {
            print("CoreDataPersistenceStorage store(object:) error:", error)
        }
    }

    public func remove<T: ObjectPersistable>(forId id: String, as type: T.Type) {
        guard let coreDataType = type as? CoreDataPersistable.Type else {
            return
        }

        do {
            guard let entity = try fetchEntity(identifier: id, type: coreDataType) else {
                return
            }

            viewContext.delete(entity)
            try saveContextIfNeeded()
        } catch {
            print("CoreDataPersistenceStorage remove(forId:as:) error:", error)
        }
    }
}

// MARK: - Private helpers
private extension CoreDataPersistenceStorage {
    func makeFetchRequest(for type: CoreDataPersistable.Type, limit: Int = .zero, identifier: String? = nil
    ) -> NSFetchRequest<NSManagedObject> {
        let request = NSFetchRequest<NSManagedObject>(entityName: type.entityName)

        if let identifier {
            request.predicate = NSPredicate(
                format: "%K == %@",
                type.identifierKey,
                identifier
            )
        }
        
        request.fetchLimit = limit

        return request
    }

    func fetchEntity(identifier: String, type: CoreDataPersistable.Type) throws -> NSManagedObject? {
        let request = makeFetchRequest(for: type, limit: 1, identifier: identifier)
        
        return try viewContext.fetch(request).first
    }

    func saveContextIfNeeded() throws {
        guard viewContext.hasChanges else {
            return
        }

        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
            throw error
        }
    }
}
