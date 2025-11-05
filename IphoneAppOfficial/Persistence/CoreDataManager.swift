
//  CoreDataManager.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 7/30/25.
//

import CoreData

class OldCoreDataManager {
    static let shared = OldCoreDataManager()
    
    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "IphoneAppOfficial") // Make sure this matches your model name
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ Error loading Core Data: \(error)")
            } else {
                print("✅ Core Data loaded successfully")
            }
        }
  
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Saved context successfully")
            } catch {
                print("❌ Failed to save context: \(error)")
            }
        }
    }

}

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentCloudKitContainer
    
    private init() {
        container = NSPersistentCloudKitContainer(name: "IphoneAppOfficial") // must match your .xcdatamodeld name

        // Set up CloudKit options
        if let storeDescription = container.persistentStoreDescriptions.first {
            // Keep same local file path (so data isn't lost)
            let storeURL = FileManager.default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("IphoneAppOfficial.sqlite")

            storeDescription.url = storeURL

            // Enable CloudKit sync
            storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.ClayvonStudios.IphoneAppOfficial" // replace with your actual identifier
            )
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ Error loading Core Data + iCloud: \(error)")
            } else {
                print("✅ Core Data with CloudKit loaded successfully at \(description.url?.absoluteString ?? "unknown")")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Saved context successfully")
            } catch {
                print("❌ Failed to save context: \(error)")
            }
        }
    }
//    
//    func migrateFromOldManagerWithRelationships() {
//        let oldContext = OldCoreDataManager.shared.context
//        let newContext = self.context
//        
//        guard let entities = oldContext.persistentStoreCoordinator?.managedObjectModel.entities else { return }
//        
//        // Keep track of old -> new objects
//        var objectMapping: [NSManagedObjectID: NSManagedObject] = [:]
//        
//        // Step 1: Copy all objects (attributes only)
//        for entity in entities {
//            guard let entityName = entity.name else { continue }
//            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
//            
//            do {
//                let oldObjects = try oldContext.fetch(fetchRequest)
//                for oldObject in oldObjects {
//                    let newObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: newContext)
//                    
//                    // Copy attributes
//                    for (name, _) in oldObject.entity.attributesByName {
//                        newObject.setValue(oldObject.value(forKey: name), forKey: name)
//                    }
//                    
//                    // Store mapping
//                    objectMapping[oldObject.objectID] = newObject
//                }
//            } catch {
//                print("Failed to fetch old objects for \(entity.name ?? "unknown"): \(error)")
//            }
//        }
//        
//        // Step 2: Copy relationships
//        for entity in entities {
//            guard let entityName = entity.name else { continue }
//            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
//            
//            do {
//                let oldObjects = try oldContext.fetch(fetchRequest)
//                for oldObject in oldObjects {
//                    guard let newObject = objectMapping[oldObject.objectID] else { continue }
//                    
//                    for (name, rel) in oldObject.entity.relationshipsByName {
//                        if rel.isToMany {
//                            // To-many relationship
//                            if let oldSet = oldObject.value(forKey: name) as? NSSet {
//                                let newSet = NSMutableSet()
//                                for oldRelated in oldSet {
//                                    if let oldRelatedObject = oldRelated as? NSManagedObject,
//                                       let newRelated = objectMapping[oldRelatedObject.objectID] {
//                                        newSet.add(newRelated)
//                                    }
//                                }
//                                newObject.setValue(newSet, forKey: name)
//                            }
//                        } else {
//                            // To-one relationship
//                            if let oldRelated = oldObject.value(forKey: name) as? NSManagedObject,
//                               let newRelated = objectMapping[oldRelated.objectID] {
//                                newObject.setValue(newRelated, forKey: name)
//                            }
//                        }
//                    }
//                }
//            } catch {
//                print("Failed to copy relationships for \(entityName): \(error)")
//            }
//        }
//        
//        // Save the new context
//        do {
//            try newContext.save()
//            print("✅ Migration with relationships complete")
//        } catch {
//            print("❌ Failed to save new context: \(error)")
//        }
//    }

}
