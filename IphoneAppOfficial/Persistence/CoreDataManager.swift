//
//  CoreDataManager.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 7/30/25.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
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
