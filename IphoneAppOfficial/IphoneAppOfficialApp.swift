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
    
    @StateObject var taskVM = TaskViewModel()
    @StateObject var goalVM = GoalViewModel()
    @StateObject var timerVM: TimerViewModel

       init() {
           let taskVM = TaskViewModel()
           let goalVM = GoalViewModel()
           _taskVM = StateObject(wrappedValue: taskVM)
           _goalVM = StateObject(wrappedValue: goalVM)
           _timerVM = StateObject(wrappedValue: TimerViewModel(taskViewModel: taskVM, goalViewModel: goalVM))
           
           NotificationManager.shared.requestAuthorization()
       }
    
    
//    init() {
//           // Ask for notification permission when the app launches
//           NotificationManager.shared.requestAuthorization()
//       }

    var body: some Scene {
        WindowGroup {
            DailyTasksView(
//                        date: Date(),
                        taskVM: taskVM,
                        goalVM: goalVM,
                        timerVM: timerVM
                    )
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
