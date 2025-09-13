//
//  GoalView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/13/25.
//


import SwiftUI
import CoreData

struct GoalView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var goalVM: GoalViewModel
    @ObservedObject var goal: Goal
    
    @State private var isCompactView = false
    
    @State private var selectedTaskForSheet: Task? = nil
    @State private var isShowingSheet = false
    
    @State private var isEditView = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteAllTasksConfirmation = false
    @State private var taskToDelete: Task? = nil
    @State private var editGoalTitle: String = ""
    @State private var editGoalTitleButton: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var editDueDate: Bool = false
    @State private var editDate: Bool = false
    @State private var showDeleteForGoalConfirmation = false
    
    

    
//    var dummyTask: Task
    
    @State private var showCreateTask = false
    
    @State private var selectedSort: TaskSortOption = .dueDate
    
    var displayedTasks: [Task] {
        taskVM.sortedTasks(goal: goal, option: selectedSort)
    }
    
    
//    var sortedTasks: [Task] {
//        taskVM.sortedTasks(goal: goal, option: selectedSort)
//    }
    
    var completedCount: Int {
        displayedTasks.filter { $0.isComplete }.count
    }

    var totalCount: Int {
        displayedTasks.count
    }
    
    
    var body: some View {
        
       
        
            VStack {
                
                if isEditView {
                    Button(action: {
                        showDeleteForGoalConfirmation.toggle()
                    }){
                        Text("Delete All Tasks For Goal")
                            .foregroundColor(.red)
                            .padding(.leading)
                    }
                }

                ScrollViewReader { proxy in
                    
                    
                    ScrollView (){
                        
                        HStack {
                            if isEditView {
                                Button(action: {
                                   editGoalTitleButton.toggle()
                                    isEditView.toggle()
                                }){
                                    Text("edit")
                                        .padding(.leading)
                                }
                                
                              
                            }
                            if editGoalTitleButton {
                                VStack {
                                    TextField("Enter New Title", text: $editGoalTitle)
                                        .padding(.leading)
                                        .frame(minHeight: 44)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                                        .font(.title)
                                        .bold()
                                    
                                    HStack {
                                        Button(action: {
                                            goalVM.changeTitle(goal: goal, text: editGoalTitle)
                                            editGoalTitleButton.toggle()
                                        }) {
                                            Text("Save Changes")
                                        }
                                        .frame(width: 150,height: 35)
                                        .foregroundStyle(.white)
                                        .background(Color.blue)
                                        .cornerRadius(15)
                                        
                                        Button(action: {
                                            editGoalTitleButton.toggle()
                                            editGoalTitle = ""
                                        }) {
                                            Text("Cancel")
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                        }
                                        .frame(width: 150,height: 35)
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .background(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
                                        .cornerRadius(15)
                                    }
                                }
                            } else {
                                
                                Text("\(goal.title ?? "No Title")")
                                    .font(.largeTitle)
                                    .bold()
                                    .padding(.leading)
                                    .id("top")
                                
                                
                                Spacer()
                                
                                TaskSortMenu(selectedSort: $selectedSort)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        
                        if editDueDate {
                            VStack {
                            HStack {
                                Spacer()
                                Text("Change Due Date")
                                    .padding(.trailing)
                                DatePicker(
                                    "Select Date",
                                    selection: $selectedDate,
                                    displayedComponents: [.date] // only date, no time
                                )
                                .datePickerStyle(.compact) // rectangular field only
                                .labelsHidden()
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            
                            HStack {
                                Button(action: {
                                    goalVM.editDate(for: goal, newDueDate: selectedDate)
                                    editDueDate.toggle()
                                } ) {
                                    Text("Change Due Date")
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 10)
                                    
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: 150)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    
                                }
                                
                                Button(action: {
                                    editDueDate.toggle()
                                   
                                }) {
                                    Text("Cancel")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                                .frame(width: 150,height: 35)
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .background(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
                                .cornerRadius(15)
                            }
                        }
                            .padding(.bottom)
                        } else {
                            HStack {
                                if isEditView {
                                    Button(action: {
                                       editDueDate.toggle()
                                        isEditView.toggle()
                                    }){
                                        Text("edit")
                                          
                                    }
                                    
                                  
                                }
                                
                                Text("Due:")
                                    .font(.title3)
                                    .bold()
                                
                                Text(goalVM.formatDate(goal.dateDue ?? Date()))
                                    .font(.title3)
                                    .bold()
                                    
                                 
                            }
                            .padding(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                            
                        
                      
                        
                        LazyVStack (spacing: 5){
                            
                            
                            ForEach(displayedTasks, id: \.objectID) { task in
                                
                                if !task.isComplete {
                                    HStack {
                                        
                                        EditTaskView(goal: goal, task: task, isEditView: $isEditView, taskToDelete: $taskToDelete, showDeleteConfirmation: $showDeleteConfirmation, selectedSort: $selectedSort, taskVM: taskVM, timerVM: timerVM, goalVM: goalVM)
                                        
                                        if isCompactView {
                                            
                                            
                                            
                                            
                                            if task.timer != nil && !task.isComplete {
                                                TaskRectangularNavLinkSmall(goalVM: goalVM,taskVM: taskVM, timerVM: timerVM, task: task, selectedSort: $selectedSort, proxy: proxy)
                                            } else if task.quantityval != nil && !task.isComplete {
                                                QValTaskRectangularNavLinkSmall(goalVM: goalVM,taskVM: taskVM, timerVM: timerVM, task: task, selectedTask: $selectedTaskForSheet, isShowingUpdateSheet: $isShowingSheet,selectedSort: $selectedSort, proxy: proxy)
                                            } else if !task.isComplete {
                                                TaskRectangularNavLinkSimpleSmall(goalVM: goalVM,taskVM: taskVM, timerVM: timerVM, task: task)
                                                
                                            }
                                        } else {
                                            
                                            if task.timer != nil && !task.isComplete {
                                                TaskRectangularNavLink(goalVM: goalVM,taskVM: taskVM, timerVM: timerVM, task: task, selectedSort: $selectedSort, proxy: proxy)
                                            } else if task.quantityval != nil && !task.isComplete {
                                                QValTaskRectangularNavLink(goalVM: goalVM,taskVM: taskVM, timerVM: timerVM, task: task, selectedTask: $selectedTaskForSheet, isShowingUpdateSheet: $isShowingSheet,selectedSort: $selectedSort, proxy: proxy)
                                            } else if !task.isComplete {
                                                TaskRectangularNavLinkSimple(goalVM: goalVM,taskVM: taskVM, timerVM: timerVM, task: task)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            //                        if taskVM.savedTasks.contains(where: { $0.isComplete }) {
//                            Text("\(goal.title ?? "No Title")")
//                                .font(.title)
//                                .bold()
                            
                            ForEach(displayedTasks, id: \.objectID) { task in
                                if task.isComplete {
                                    HStack {
                                        EditTaskView(goal: goal, task: task, isEditView: $isEditView, taskToDelete: $taskToDelete, showDeleteConfirmation: $showDeleteConfirmation, selectedSort: $selectedSort, taskVM: taskVM, timerVM: timerVM, goalVM: goalVM)
                                        CompletedTaskNavLink(goalVM: goalVM,taskVM: taskVM, timerVM: timerVM, task: task)
                                    }
                                }
                            }
                            
                            //                        }
                        }
                    }
                    //            TaskRectangularNavLink(taskVM: taskVM, timerVM: timerVM, task: taskVM.newTask)
                }
                
                .navigationDestination(isPresented: $showCreateTask) {
                    CreateTaskView(goal: goal, taskVM: taskVM, goalVM: goalVM, timerVM: timerVM)
                }
                
                VStack (spacing: 0) {
                    
                    DailyTaskProgressFooter(goal: goal, taskVM: taskVM, timerVM: timerVM, goalVM: goalVM, displayedTasks: displayedTasks)
                    
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
                    .background(colorScheme == .dark ? .black.opacity(0.10) : .gray.opacity(0.15))
                    .sheet(item: $selectedTaskForSheet) { task in
                        IncrementView(task: task, goal: goal, taskVM: taskVM, goalVM: goalVM, timerVM: timerVM)
                        
                    }
                }
                
            }
            .background(colorScheme == .dark ? .black.opacity(0.10) : .gray.opacity(0.15))
            .onAppear {
                taskVM.fetchTasks(for: goal)
                timerVM.updateAllRunningTaskTimers(goal: goal, goalTasks: displayedTasks)
                timerVM.setAllTimerVals(goal: goal, goalTasks: displayedTasks)
                timerVM.beginProgressUpdates(for: Date(), goalTasks: displayedTasks)
                goalVM.GoalElapsedTime(goal: goal)
//                timerVM.countDownTimer(task: taskVM.newTask, seconds: 10, minutes: 1, hours: 0)
//                displayedTasks = taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
            }
            .onChange(of:  goal.estimatedTimeRemaining) {
                
                timerVM.setAllTimerVals(goal: goal, goalTasks: displayedTasks)
                
            }
            .alert("Delete all tasks for this goal?  Tasks will be permanently deleted.", isPresented: $showDeleteForGoalConfirmation) {
                
                Button(action: {
                    taskVM.deleteMultipleTasksInView(tasks: displayedTasks, goal: goal)
                    isEditView = false 
                    
                }, label: {
                    Text("Delete All Tasks")
                        .foregroundColor(.red)
                })
                
                Button("Cancel", role: .cancel) {
                    showDeleteForGoalConfirmation = false
                    isEditView = false
                }
            }

//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    NavigationLink(destination: GoalsView(goalVM: goalVM)) {
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

//#Preview {
//    let context = PersistenceController.preview.container.viewContext
//    
//    let mockGoal = Goal(context: context)
//    mockGoal.title = "Test Goal"
//    
//    let goalVM = GoalViewModel()
//    goalVM.savedGoals = [mockGoal] // Or however your VM stores goals
//    
//    GoalView(
//        taskVM: TaskViewModel(),
//        goalVM: goalVM,
//        timerVM: TimerViewModel(
//            taskViewModel: TaskViewModel(),
//            goalViewModel: goalVM
//        ),
//        goal: mockGoal
//    )
//    .environment(\.managedObjectContext, context)
//}
