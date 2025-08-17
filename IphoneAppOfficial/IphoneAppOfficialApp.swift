//
//  IphoneAppOfficialApp.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 7/30/25.
//

import SwiftUI

@main
struct IphoneAppOfficialApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
           // Ask for notification permission when the app launches
           NotificationManager.shared.requestAuthorization()
       }

    var body: some Scene {
        WindowGroup {
            DailyTasksView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
