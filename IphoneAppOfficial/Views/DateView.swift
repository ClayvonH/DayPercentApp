//
//  DateView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/19/25.
//


import SwiftUI
import CoreData

struct DateView: View {
    @State var date: Date
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var goalVM: GoalViewModel
    @ObservedObject var timerVM: TimerViewModel
    @State private var isCompactView = true
    
    @State private var selectedTaskForSheet: Task? = nil
    @State private var isShowingSheet = false
    
    @State private var isEditView = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteAllTasksConfirmation = false
    @State private var taskToDelete: Task? = nil
    
    

    
//    var dummyTask: Task
    
    @State private var showCreateTask = false
    
//    init() {
//         let taskVM = TaskViewModel()
//         let goalVM = GoalViewModel()
//         let timerVM = TimerViewModel(taskViewModel: taskVM, goalViewModel: goalVM)
//
//         self._taskVM = StateObject(wrappedValue: taskVM)
//         self._goalVM = StateObject(wrappedValue: goalVM)
//         self._timerVM = StateObject(wrappedValue: timerVM)
//
//     }
    
    @State private var selectedSort: TaskSortOption = .title
    
    var displayedTasks: [Task] {
//        taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
        taskVM.sortedTasksDate(date: date, option: selectedSort)
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
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        
       
        
            VStack {
                Button(action: {taskVM.deleteAllTasks()}, label: {
                    Text("delete all tasks")
                })
                ScrollViewReader { proxy in
                    
                    
                    ScrollView (){
                        
                        HStack {
                            Text("Tasks For \(formatDate(date))")
                                .font(.largeTitle)
                                .bold()
                                .padding(.leading)
                                .id("top")
                            
                            
                            Spacer()
                            
                            TaskSortMenu(selectedSort: $selectedSort)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        
                        LazyVStack (spacing: 5){
                            
                            
                            ForEach(displayedTasks, id: \.objectID) { task in
                                
                                if !task.isComplete {
                                    HStack {
                                        
                                        EditTaskView(task: task, isEditView: $isEditView, taskToDelete: $taskToDelete, showDeleteConfirmation: $showDeleteConfirmation, selectedSort: $selectedSort, taskVM: taskVM, timerVM: timerVM, goalVM: goalVM)
                                           
                                        
                                        if isCompactView {
                                            
                                            
                                            
                                            
                                            if task.timer != nil && !task.isComplete {
                                                TaskRectangularNavLinkSmall(taskVM: taskVM, timerVM: timerVM, task: task, selectedSort: $selectedSort, proxy: proxy)
                                                  
                                                
                                            } else if task.quantityval != nil && !task.isComplete {
                                                QValTaskRectangularNavLinkSmall(taskVM: taskVM, timerVM: timerVM, task: task, selectedTask: $selectedTaskForSheet, isShowingUpdateSheet: $isShowingSheet,selectedSort: $selectedSort, proxy: proxy)
                                            } else if !task.isComplete {
                                                TaskRectangularNavLinkSimpleSmall(taskVM: taskVM, timerVM: timerVM, task: task)
                                                
                                            }
                                        } else {
                                            
                                            if task.timer != nil && !task.isComplete {
                                                TaskRectangularNavLink(taskVM: taskVM, timerVM: timerVM, task: task, selectedSort: $selectedSort, proxy: proxy)
                                            } else if task.quantityval != nil && !task.isComplete {
                                                QValTaskRectangularNavLink(taskVM: taskVM, timerVM: timerVM, task: task, selectedTask: $selectedTaskForSheet, isShowingUpdateSheet: $isShowingSheet,selectedSort: $selectedSort, proxy: proxy)
                                            } else if !task.isComplete {
                                                TaskRectangularNavLinkSimple(taskVM: taskVM, timerVM: timerVM, task: task)
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
                                    CompletedTaskNavLink(taskVM: taskVM, timerVM: timerVM, task: task)
                                }
                            }
                            
                                                    }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    //            TaskRectangularNavLink(taskVM: taskVM, timerVM: timerVM, task: taskVM.newTask)
                }
                
                .navigationDestination(isPresented: $showCreateTask) {
                    CreateTaskView(taskVM: taskVM, goalVM: goalVM, timerVM: timerVM)
                }
                
                VStack (spacing: 0) {
                    
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
                            //                                                       .font(.title2)
                            //                                                   } else {
                            //                                                   Image(systemName: "rectangle")
                            //
                            //                                               }
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
                    .background(Color.gray.opacity(0.15))
                    .sheet(item: $selectedTaskForSheet) { task in
                        IncrementView(task: task, taskVM: taskVM)
                        
                    }
                }
                
            }
            .background(Color.gray.opacity(0.15))
            .onAppear {
                taskVM.fetchTasksForDate(for: date)
                timerVM.updateAllRunningTaskTimers()
                timerVM.setAllTimerVals()
                timerVM.beginProgressUpdates(for: Date())
//                timerVM.countDownTimer(task: taskVM.newTask, seconds: 10, minutes: 1, hours: 0)
//                displayedTasks = taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    NavigationLink(destination: GoalsView(taskVM: taskVM, timerVM: timerVM, goalVM: goalVM)) {
//                        Text("Goals")
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: Text("goal")) {
//                        Image(systemName: "calendar")
//                            .font(.title)
//                            .foregroundColor(.blue)
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: Text("goal")) {
//                        Text("Tasks")
//                    }
//                }
//            }
//            .onChange(of: taskVM.savedTasks) {
//                displayedTasks = taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
//            }
//            .onChange(of: selectedSort) {
//                displayedTasks = taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
//            }
            
//            DailyTaskProgressFooter(taskVM: taskVM, timerVM: timerVM, displayedTasks: displayedTasks)
            
            
//            HStack {
//                                            Button(action: {
//                                                isEditView.toggle()
//                                            }) {
//                                                Image(systemName: "minus")
//                                                    .foregroundStyle(.blue)
//                                                    .frame(width: 30, height: 30)
//                                                    .background(Color(.secondarySystemBackground))
//                                                    .clipShape(Circle())
//                                            }
//                                            .padding(.leading)
//                                            .font(.body.bold())
//                                            .foregroundColor(.blue)
//
//                                            Spacer()
//                Button(action: {
//                    withAnimation(.easeInOut(duration: 0.2)) {
//                        isCompactView.toggle()
//                    }
//                }) {
//
//                    if isCompactView {
//                        Image(systemName: "rectangle")
//
//                         } else {
//                            Image(systemName: "rectangle")
//                                 .font(.title2)
//
//                        }
////                                                       .font(.title2)
////                                                   } else {
////                                                   Image(systemName: "rectangle")
////
////                                               }
//                }
//
//                Spacer()
//                Button(action: {
//
//                    showCreateTask.toggle()
//                }) {
//                    Image(systemName: "plus")
//                        .foregroundStyle(.blue)
//                        .frame(width: 30, height: 30)
//                        .background(Color(.secondarySystemBackground))
//                        .clipShape(Circle())
//                }
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 8)
//            .background(Color.gray.opacity(0.15))
//            .sheet(item: $selectedTaskForSheet) { task in
//                IncrementView(task: task, taskVM: taskVM)
//
//            }
        
        
       
        
        
    }
}
