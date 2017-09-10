import UIKit
import CoreData

public enum CoreDataError: Error {
    case invalidManagedObjectModel
    case foundationError(NSError)
}

open class CoreManagedObjectContext: NSManagedObjectContext {

    public init(bundle: Bundle, mom: String, inMemory: Bool = false) throws {

        super.init(concurrencyType: .mainQueueConcurrencyType)

        guard let modelURL = bundle.url(forResource: mom, withExtension: "momd") else {
            throw CoreDataError.invalidManagedObjectModel
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataError.invalidManagedObjectModel
        }
        if inMemory {
            self.persistentStoreCoordinator = createInMemoryPersistentStoreCoordinator(forManagedObjectModel: managedObjectModel)
        } else {
            self.persistentStoreCoordinator = createSQLitePersistentStoreCoordinator(forManagedObjectModel: managedObjectModel, fileName: mom)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate lazy var applicationDocumentsDirectory: URL = self.getApplicationDocumentsDirectory()

    fileprivate func getApplicationDocumentsDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }

    fileprivate func createSQLitePersistentStoreCoordinator(forManagedObjectModel mom: NSManagedObjectModel,
                                                                              fileName: String) -> NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(fileName).sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print("error: \(error)")
        }
        return coordinator
    }

    fileprivate func createInMemoryPersistentStoreCoordinator(forManagedObjectModel mom: NSManagedObjectModel) -> NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        do {
            try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("error: \(error)")
        }
        return coordinator
    }

}
