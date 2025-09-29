//
//  DailyTasksView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 7/31/25.
//


import SwiftUI
import CoreData

struct DailyTasksView: View {
    @AppStorage("appearance") private var appearance: Appearance = .system
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) private var scenePhase   // 👈 Track app lifecycle
    
    @State private var today = Calendar.current.startOfDay(for: Date())
    
    private var date: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var goalVM: GoalViewModel
    @ObservedObject var timerVM: TimerViewModel
    
    @State private var isCompactView = false
    @State private var selectedTaskForSheet: Task? = nil
    @State private var isShowingSheet = false
    @State private var isEditView = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteAllTasksConfirmation = false
    @State private var taskToDelete: Task? = nil
    @State private var showDeleteForDayConfirmation = false
    @State private var currentDay = Calendar.current.startOfDay(for: Date())
    @State private var showCreateTask = false
    @State private var selectedSort: TaskSortOption = .dueDate
    
    var displayedTasks: [Task] {
        taskVM.sortedTasksDate(date: today, option: selectedSort)
    }
    
    var sortedTasks: [Task] {
        taskVM.sortedTasksDate(date: date, option: selectedSort)
    }
    
    var completedCount: Int {
        displayedTasks.filter { $0.isComplete }.count
    }

    var totalCount: Int {
        displayedTasks.count
    }
    
    // 🔄 Refresh logic encapsulated
    private func refreshFor(date: Date) {
        taskVM.fetchTasksForDate(for: date)
        goalVM.fetchGoalsForDate(for: date)
        timerVM.updateAllRunningTaskTimers(date: date, tasks: displayedTasks)
        timerVM.setAllTimerVals(date: date, tasks: displayedTasks)
        timerVM.beginProgressUpdates(for: date, tasks: displayedTasks)
        timerVM.startSharedUITimerDate(date: date, tasks: displayedTasks)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
//#if DEBUG
//Button("Simulate Next Day") {
//    today = Calendar.current.date(byAdding: .day, value: -1, to: today)!
//}
//.padding()
//#endif
                if isEditView {
                    Button(action: {
                        showDeleteForDayConfirmation.toggle()
                    }, label: {
                        Text("delete all tasks")
                            .foregroundColor(.red)
                    })
                }
                
                ScrollViewReader { proxy in
                    ScrollView {
                        HStack {
                            Text("Daily Tasks")
                                .font(.largeTitle) 
                                .bold()
                                .padding(.leading)
                                .id("top")
                            
                            if goalVM.dateGoals.count > 0 {
                                NavigationLink(destination: GoalsDueView(date: date, taskVM: taskVM, timerVM: timerVM, goalVM: goalVM)) {
                                    Text("Goal Due!")
                                        .bold()
                                        .foregroundColor(.red)
                                        .padding(.top, 20)
                                        .padding(.leading)
                                }
                            } else {
                                Text(taskVM.formatDate(Date()))
                                    .bold()
                                    .font(.title2)
                                    .padding(.leading)
                            }
                            Spacer()
                            
                            TaskSortMenu(selectedSort: $selectedSort)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if displayedTasks.count == 0 {
                            Text("Press the (+) button to add a task!")
                                .foregroundColor(colorScheme == .dark ? .white: .black)
                                .bold()
                                .padding(.top, 250)
                        }
                        
                        LazyVStack(spacing: 5) {
                            ForEach(displayedTasks, id: \.objectID) { task in
                                if !task.isComplete {
                                    HStack {
                                        EditTaskView(
                                            date: date,
                                            task: task,
                                            isEditView: $isEditView,
                                            taskToDelete: $taskToDelete,
                                            showDeleteConfirmation: $showDeleteConfirmation,
                                            selectedSort: $selectedSort,
                                            taskVM: taskVM,
                                            timerVM: timerVM,
                                            goalVM: goalVM
                                        )
                                        if isCompactView {
                                            if task.timer != nil && !task.isComplete {
                                                TaskRectangularNavLinkSmall(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task, selectedSort: $selectedSort, proxy: proxy)
                                            } else if task.quantityval != nil && !task.isComplete {
                                                QValTaskRectangularNavLinkSmall(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task, selectedTask: $selectedTaskForSheet, isShowingUpdateSheet: $isShowingSheet, selectedSort: $selectedSort, proxy: proxy)
                                            } else if !task.isComplete {
                                                TaskRectangularNavLinkSimpleSmall(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task)
                                            }
                                        } else {
                                            if task.timer != nil && !task.isComplete {
                                                TaskRectangularNavLink(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task, selectedSort: $selectedSort, proxy: proxy)
                                            } else if task.quantityval != nil && !task.isComplete {
                                                QValTaskRectangularNavLink(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task, selectedTask: $selectedTaskForSheet, isShowingUpdateSheet: $isShowingSheet, selectedSort: $selectedSort, proxy: proxy)
                                            } else if !task.isComplete {
                                                TaskRectangularNavLinkSimple(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if displayedTasks.contains(where: { $0.isComplete }) {
                                Text("Completed Tasks")
                                    .font(.title)
                                    .bold()
                                ForEach(displayedTasks, id: \.objectID) { task in
                                    if task.isComplete {
                                        HStack {
                                            EditTaskView(date: date, task: task, isEditView: $isEditView, taskToDelete: $taskToDelete, showDeleteConfirmation: $showDeleteConfirmation, selectedSort: $selectedSort, taskVM: taskVM, timerVM: timerVM, goalVM: goalVM)
                                            CompletedTaskNavLink(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                .navigationDestination(isPresented: $showCreateTask) {
                    CreateTaskView(taskVM: taskVM, goalVM: goalVM, timerVM: timerVM)
                }
                
                VStack(spacing: 0) {
                    DailyTaskProgressFooter(date: date, taskVM: taskVM, timerVM: timerVM, goalVM: goalVM, displayedTasks: displayedTasks)
                    
                    HStack {
                        Button(action: {
                            isEditView.toggle()
                        }) {
                            Image(systemName: "minus")
                                .foregroundStyle(.blue)
                                .frame(width: 30, height: 30)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(Circle())
                        }
                        .padding(.leading)
                        .font(.body.bold())
                        .foregroundColor(.blue)
                        
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isCompactView.toggle()
                            }
                        }) {
                            if isCompactView {
                                Image(systemName: "rectangle")
                            } else {
                                Image(systemName: "rectangle")
                                    .font(.title2)
                            }
                        }
                        
                        Spacer()
                        Button(action: {
                            showCreateTask.toggle()
                        }) {
                            Image(systemName: "plus")
                                .foregroundStyle(.blue)
                                .frame(width: 30, height: 30)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(colorScheme == .dark ? .black.opacity(0.10) : .gray.opacity(0.15))
                    .sheet(item: $selectedTaskForSheet) { task in
                        IncrementView(task: task, taskVM: taskVM, goalVM: goalVM, timerVM: timerVM)
                    }
                }
            }
            .background(colorScheme == .dark ? .black.opacity(0.10) : .gray.opacity(0.15))
            
            // ✅ Refresh when app becomes active
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    let newToday = Calendar.current.startOfDay(for: Date())
                    if newToday != today {
                        today = newToday
                        refreshFor(date: today)
                    }
                }
            }
            
            // ✅ Initial fetch
            .onAppear {
                refreshFor(date: today)
            }
            
            .alert("Delete all tasks for this date?  Tasks will be permanently deleted.", isPresented: $showDeleteForDayConfirmation) {
                Button(action: {
                    taskVM.deleteMultipleTasksInView(tasks: displayedTasks, date: date)
                    isEditView = false
                }, label: {
                    Text("Delete All Tasks")
                        .foregroundColor(.red)
                })
                
                Button("Cancel", role: .cancel) {
                    showDeleteForDayConfirmation = false
                    isEditView = false
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: GoalsView(taskVM: taskVM, timerVM: timerVM, goalVM: goalVM)) {
                        Text("Goals")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CalendarView(taskVM: taskVM, timerVM: timerVM, goalVM: goalVM)) {
                        Image(systemName: "calendar")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: TasksView(taskVM: taskVM, goalVM: goalVM, timerVM: timerVM)) {
                        Text("Tasks")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: LightDarkMode(appearance: $appearance)) {
                        Image(systemName: "lightbulb")
                          
                    }
                }
            }
        }
    }
}
