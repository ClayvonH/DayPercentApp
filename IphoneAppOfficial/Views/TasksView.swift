
import SwiftUI
import CoreData

struct TasksView: View {
    @Environment(\.colorScheme) var colorScheme
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
    @State private var currentMonth: Date = Date()
    @State private var monthView: Bool = false
    @State private var showMonthViewAlert: Bool = false
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
    
    @State private var selectedSort: TaskSortOption = .dueDate
    
    @State private var showBoth = true
    
    var displayedTasks: [Task] {
        taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
    }
    
    
    var sortedTasks: [Task] {
        taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
    }
    
    var completedCount: Int {
        taskVM.savedTasks.filter { $0.isComplete }.count
    }
    
    var totalCount: Int {
        taskVM.savedTasks.count
    }
    
    var body: some View {
        
        
        VStack {
            if isEditView {
                Button(action: {taskVM.deleteAllTasks()}, label: {
                    Text("delete all tasks")
                        .foregroundColor(.red)
                })
            }
            ScrollViewReader { proxy in
                
                
                ScrollView (){
                    
                    HStack {
                        Text("All Tasks")
                            .font(.largeTitle)
                            .bold()
                            .padding(.leading)
                            .id("top")
                        
                        Button(action: {
                            if taskVM.countTasks() <= 500 {
                                monthView.toggle()
                                if monthView == true {
                                    taskVM.fetchTasks(month: currentMonth)
                                } else {
                                    taskVM.fetchTasks()
                                }
                                
                            } else {
                                showMonthViewAlert.toggle()
                            }
                       }){
                           if monthView == true {
                               Text("Display All Tasks")
                           } else {
                               Text("Monthly Tasks")
                           }
                       }
                       .padding(.leading)
                        
                        
                        Spacer()
                        
                        TaskSortMenu(selectedSort: $selectedSort)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if displayedTasks.count == 0 {
                        Text("Press the (+) button to add a task!")
                            .foregroundColor(.black)
                            .bold()
                            .padding(.top, 250)
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
                        
                        if taskVM.savedTasks.contains(where: { $0.isComplete }) {
                            Text("Completed Tasks")
                                .font(.title)
                                .bold()
                            
                            ForEach(displayedTasks, id: \.objectID) { task in
                                if task.isComplete {
                                    CompletedTaskNavLink(goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task)
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
                
                
                if monthView == true {
                    DailyTaskProgressFooter( month: currentMonth, taskVM: taskVM, timerVM: timerVM, goalVM: goalVM, displayedTasks: displayedTasks)
                } else {
                    
                    DailyTaskProgressFooter(taskVM: taskVM, timerVM: timerVM, goalVM: goalVM, displayedTasks: displayedTasks)
                }
                
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
                    if monthView == true {
                        Spacer()
                        
                        Button(action: {
                            // Go to previous month
                            if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
                                currentMonth = previousMonth
                                taskVM.fetchTasks(month: currentMonth)
                                timerVM.setAllTimerVals()
                                
                            }
                        }) {
                            Image(systemName: "chevron.left")
                            
                        }
                    }
                   
                    
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
                    if monthView == true {
                        Spacer()
                        
                        Button(action: {
                            // Go to next month
                            if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
                                currentMonth = nextMonth
                                taskVM.fetchTasks(month: currentMonth)
                                timerVM.setAllTimerVals()
                            }
                        }) {
                            Image(systemName: "chevron.right")
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
        .onAppear {
            if taskVM.countTasks() <= 500 {
                taskVM.fetchTasks()
            } else {
                monthView = true 
                taskVM.fetchTasks(month: currentMonth)
            }
          
            timerVM.updateAllRunningTaskTimers()
            timerVM.setAllTimerVals()
            timerVM.beginProgressUpdates(for: Date())
            //                timerVM.countDownTimer(task: taskVM.newTask, seconds: 10, minutes: 1, hours: 0)
            //                displayedTasks = taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
        }
        .alert("Cannot display more than 500 tasks.  You have \(taskVM.countTasks()) tasks", isPresented: $showMonthViewAlert) {

        }
 
    }

       
        
        
    
}

//#Preview {
//
//    DailyTasksView()
//
//}
