
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
        normalizeAllTaskTitles()
//        normalizeAllTaskTimes()
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
    
    func normalizeAllTaskTitles() {
        let request = NSFetchRequest<AppTask>(entityName: "AppTask")

        do {
            let tasks = try container.viewContext.fetch(request)
            var changed = false

            for task in tasks {
                if let title = task.title {

                    // Clean trailing spaces
                    let trimmed = title.trimmingCharacters(in: .whitespaces)

                    // If different → update
                    if trimmed != title {
                        task.title = trimmed
                        changed = true
                    }
                }
            }

            if changed {
                try container.viewContext.save()
                print("🔧 Task titles normalized.")
            } else {
                print("✔ No task titles needed cleaning.")
            }

        } catch {
            print("❌ Error normalizing task titles: \(error)")
        }
    }
    
    func normalizeAllTaskTimes() {
        let request = NSFetchRequest<AppTask>(entityName: "AppTask")

        do {
            let tasks = try container.viewContext.fetch(request)
            var changed = false

            for task in tasks {
                if task.title == "Code An Extra Hour", let timer = task.timer, (task.dateDue ?? Date() <= Date()) {
                    timer.elapsedTime = 3600.0
                    timer.countdownTimer = 0
                    timer.percentCompletion = 100
                    changed = true
                }
            }

            if changed {
                try container.viewContext.save()
                print("🔧 Task times normalized.")
            } else {
                print("✔ No task times needed updating.")
            }

        } catch {
            print("❌ Error normalizing task times: \(error)")
        }
    }

}
