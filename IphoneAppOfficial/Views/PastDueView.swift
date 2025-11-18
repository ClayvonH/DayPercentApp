//
//  PastDueView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 11/15/25.
//



import SwiftUI
import CoreData

struct PastDueView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var goalVM: GoalViewModel
    @ObservedObject var timerVM: TimerViewModel
    @State private var isCompactView = false
    var goal: Goal?
    @State private var selectedTaskForSheet: AppTask? = nil
    @State private var isShowingSheet = false
    
    @State private var isEditView = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteAllTasksConfirmation = false
    @State private var taskToDelete: AppTask? = nil
    @State private var showDeleteForDayConfirmation = false
    @State private var selectedDate: Date? = nil
    @State private var showBoth = true

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
    
    var displayedTasks: [AppTask] {
        taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
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
                if isEditView {
                    Button(action: {
                        showDeleteForDayConfirmation.toggle()
                        
                    }, label: {
                        Text("delete all tasks")
                    })
                }
                ScrollViewReader { proxy in
                    
                    
                    ScrollView (){
                        if let goal = goal {
                            HStack {
                                Text("Past Due:")
                                    .foregroundStyle(.red)
                                    .font(.title2)
                                    .bold()
                                Text("\(goal.title ?? "No Title")")
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            HStack {
                                Text("Past Due Tasks")
                                    .foregroundStyle(.red)
                                    .font(.title)
                                    .bold()
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        LazyVStack (spacing: 5){
                            
                            
                            ForEach(displayedTasks, id: \.objectID) { task in
                                
                                if !task.isComplete {
                                    HStack {
                                        
                                        EditTaskView(task: task, isEditView: $isEditView, taskToDelete: $taskToDelete, showDeleteConfirmation: $showDeleteConfirmation, selectedSort: $selectedSort, taskVM: taskVM, timerVM: timerVM, goalVM: goalVM)
                                        
                                        
                                        if isCompactView {
                                            
                                            
                                            
                                            
                                            if task.timer != nil && !task.isComplete {
                                                TaskRectangularNavLinkSmall(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task, selectedSort: $selectedSort, proxy: proxy)
                                                
                                                
                                            } else if task.quantityval != nil && !task.isComplete {
                                                QValTaskRectangularNavLinkSmall(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task, selectedTask: $selectedTaskForSheet, isShowingUpdateSheet: $isShowingSheet,selectedSort: $selectedSort, proxy: proxy)
                                            } else if !task.isComplete {
                                                TaskRectangularNavLinkSimpleSmall(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task)
                                                
                                            }
                                        } else {
                                            
                                            if task.timer != nil && !task.isComplete {
                                                TaskRectangularNavLink(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task, selectedSort: $selectedSort, proxy: proxy, showBoth: showBoth)
                                            } else if task.quantityval != nil && !task.isComplete {
                                                QValTaskRectangularNavLink(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task, selectedTask: $selectedTaskForSheet, isShowingUpdateSheet: $isShowingSheet,selectedSort: $selectedSort, proxy: proxy, showBoth: showBoth)
                                            } else if !task.isComplete {
                                                TaskRectangularNavLinkSimple(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task, showBoth: showBoth)
                                            }
                                        }
                                    }
                                }
                            }
                            
                                                    
                        }
                        .frame(maxWidth: .infinity)
                    }
                    //            TaskRectangularNavLink(taskVM: taskVM, timerVM: timerVM, task: taskVM.newTask)
                }
                
                
                VStack (spacing: 0) {
                    
                    DailyTaskProgressFooter(taskVM: taskVM, timerVM: timerVM, goalVM: goalVM, displayedTasks: displayedTasks)
                    
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
            .onAppear {
                if let goal = goal {
                    taskVM.fetchTasksPastDue(goal: goal)
                } else {
                    taskVM.fetchTasksPastDue()
                }
                timerVM.updateAllRunningTaskTimers()
                timerVM.setAllTimerVals()
                timerVM.beginProgressUpdates(for: Date())
                //                timerVM.countDownTimer(task: taskVM.newTask, seconds: 10, minutes: 1, hours: 0)
                //                displayedTasks = taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
            }
            .alert("Delete all tasks for this date?  Tasks will be permanently deleted.", isPresented: $showDeleteForDayConfirmation) {
                
                Button(action: {
                    
                    taskVM.deleteMultipleTasksInView(tasks: displayedTasks)
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
    }
}
