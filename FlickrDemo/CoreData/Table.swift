import Foundation
import CoreData

public struct Table<T: NSManagedObject> {
    fileprivate let context: NSManagedObjectContext
    fileprivate let entityDescription: NSEntityDescription

    public init(context: CoreManagedObjectContext) {
        let managedObjectClassName = NSStringFromClass(T.self)
        let managedObjectModel = context.persistentStoreCoordinator!.managedObjectModel
        self.entityDescription = managedObjectModel.entities.filter({ $0.managedObjectClassName == managedObjectClassName }).first!
        self.context = context
    }

    public init(context: CoreManagedObjectContext, entityName: String) {
        let managedObjectModel = context.persistentStoreCoordinator!.managedObjectModel
        self.entityDescription = managedObjectModel.entities.filter({ $0.name == entityName }).first!
        self.context = context
    }

    public func createEntity() -> T {
        return NSManagedObject(entity: entityDescription, insertInto: context) as! T  // swiftlint:disable:this force_cast
    }

    public func deleteEntity(_ entity: T) throws {
        self.context.delete(entity)
        try self.context.save()
    }

    public func save() throws {
        try self.context.save()
    }

    public func query(withPredicate predicate: NSPredicate?) throws -> [T] {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.entity = self.entityDescription
        return try context.fetch(fetchRequest) as! [T] // swiftlint:disable:this force_cast
        } catch {
            throw CoreDataError.foundationError(error as NSError)
        }
    }
}
