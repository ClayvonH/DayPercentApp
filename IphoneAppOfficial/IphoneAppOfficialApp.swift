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
    
    @StateObject private var taskVM: TaskViewModel
    @StateObject private var goalVM: GoalViewModel
    @StateObject private var timerVM: TimerViewModel
    
    // store user preference (system by default)
    @AppStorage("appearance") private var appearance: Appearance = .system

    init() {
        let taskVM = TaskViewModel()
        let goalVM = GoalViewModel()
        let timerVM = TimerViewModel(taskViewModel: taskVM, goalViewModel: goalVM)
        
        _taskVM = StateObject(wrappedValue: taskVM)
        _goalVM = StateObject(wrappedValue: goalVM)
        _timerVM = StateObject(wrappedValue: timerVM)
        
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            DailyTasksView(
                taskVM: taskVM,
                goalVM: goalVM,
                timerVM: timerVM
            )
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .preferredColorScheme(appearance.colorScheme) // 👈 apply theme
        }
    }
}

// MARK: - Appearance options
enum Appearance: String, CaseIterable, Identifiable {
    case system, light, dark
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
