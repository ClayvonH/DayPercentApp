//
//  TaskView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 7/31/25.
//

import SwiftUI
import CoreData


struct TaskRectangularNavLink: View {
    
    @ObservedObject var goalVM: GoalViewModel
    
    @ObservedObject var taskVM: TaskViewModel
    
    @ObservedObject var timerVM: TimerViewModel
    
    
    @ObservedObject var task: AppTask
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var selectedSort: TaskSortOption
    
    var proxy: ScrollViewProxy
    
    var goal: Goal?
    
    var showBoth: Bool?
    
    
    var body: some View {
        NavigationLink(destination: TaskView( goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task)) {
            ZStack {
      
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? .gray.opacity(0.20) : .white)
                HStack {
                    VStack (alignment: .leading, spacing: 7) {
                        TaskTitleView(task: task)
                        
                        TaskElapsedTimeView(task: task, timerVM: timerVM)
                        
                        TaskRemainingTimeView(task: task, timerVM: timerVM)
                        
                        TaskPercentView(task: task, timerVM: timerVM)
                        
                        TaskProgressBarView(task: task, timerVM: timerVM)
                            .padding(.top, 8)
                        
                    }
                    .padding(.top, 3)
                    .padding(.leading)
                    Spacer()
                    VStack {
                        if let both = showBoth {
                            TaskDateTimeView(task: task, timerVM: timerVM, showBoth: both)
                        }
                        
                        if let goal = goal {
                            TaskDateTimeView(task: task, timerVM: timerVM, goal: goal)
            
                            Spacer()
                        } else if showBoth == false || showBoth == nil {
                            TaskDateTimeView(task: task, timerVM: timerVM)
                            Spacer()
                        }
                        StartTaskButtonView(task: task, timerVM: timerVM, taskVM: taskVM, selectedSort: $selectedSort, proxy: proxy)
                            .padding(.trailing, 25)
                        Spacer()
                        
                    }
                    
                   
                }
                .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140, alignment: .topLeading)
//                .background(colorScheme == .dark ? .black.opacity(0.25) : .white)
                
            }
            
            
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity, minHeight: 170, maxHeight:180)
        .padding(.horizontal, 10)
        
        
    
    }
}

struct TaskRectangularNavLinkSmall: View {
    @ObservedObject var goalVM: GoalViewModel
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var task: AppTask
    @Binding var selectedSort: TaskSortOption
    var proxy: ScrollViewProxy
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink(destination: TaskView( goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task)) {
            ZStack(alignment: .topLeading) { // <-- Align content to top-left
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? .gray.opacity(0.20) : .white)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        TaskTitleView(task: task)
//                            .background(Color.white)

                        HStack(spacing: 7) {
                            TaskElapsedTimeViewSmall(task: task, timerVM: timerVM)
//                                .background(Color.white)
                            
                            Spacer()
                            TaskProgressBarViewSmall(task: task, timerVM: timerVM)
                                .frame(width: 150)
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(.leading, 20) // <-- Push content closer to left
//                    .padding(.top, 8)
                    
                    Spacer()
                    
                    StartTaskButtonView(task: task, timerVM: timerVM, taskVM: taskVM, selectedSort: $selectedSort, proxy: proxy)
                        .padding(.trailing, 35)
                        .padding(.top, 25)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 80, alignment: .topLeading)
//                .background(Color.red)
            }
            .frame(maxWidth: .infinity, maxHeight: 80)
//            .background(Color.green)
          
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity, maxHeight: 80)
        .padding(.horizontal, 10)
    }
}

struct TaskRectangularNavLinkSimple: View {
    @ObservedObject var goalVM: GoalViewModel
    
    @ObservedObject var taskVM: TaskViewModel
    
    @ObservedObject var timerVM: TimerViewModel
    
    @ObservedObject var task: AppTask
    
    @Environment(\.colorScheme) var colorScheme
    
    var goal: Goal?
    
    var showBoth: Bool?
    
    var body: some View {
        NavigationLink(destination: TaskView( goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task)) {
            ZStack {
                
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? .gray.opacity(0.20) : .white)
                HStack {
                    VStack (alignment: .leading, spacing: 7) {
                        
                        Spacer()
                        TaskTitleView(task: task)
                        Spacer()
                        
                    }
                    .padding(.top, 3)
                    .padding(.leading)
                    Spacer()
                    VStack {
                        if let both = showBoth {
                            TaskDateTimeView(task: task, timerVM: timerVM, showBoth: both)
                        }
                        
                        if let goal = goal {
                            TaskDateTimeView(task: task, timerVM: timerVM, goal: goal)
                            Spacer()
                        } else if showBoth == nil || showBoth == false {
                            TaskDateTimeView(task: task, timerVM: timerVM)
                            Spacer()
                        }
                        CompleteTaskButtonView(task: task, timerVM: timerVM, taskVM: taskVM)
                            .padding(.trailing, 25)
                        Spacer()
                        
                    }
                    
                   
                }
                .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 100, alignment: .topLeading)
        
                
                
                
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity, minHeight: 130, maxHeight:140)
        .padding(.horizontal, 10)
        
    
    }
}

struct TaskRectangularNavLinkSimpleSmall: View {
    @ObservedObject var goalVM: GoalViewModel
    
    @ObservedObject var taskVM: TaskViewModel
    
    @ObservedObject var timerVM: TimerViewModel
    
    @ObservedObject var task: AppTask
    
    @Environment(\.colorScheme) var colorScheme
    
    
    
    var body: some View {
        NavigationLink(destination: TaskView( goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task)) {
            ZStack {
                
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? .gray.opacity(0.20) : .white)
                HStack {
                    VStack (alignment: .leading, spacing: 7) {
                        
                        
                       Spacer()
                        TaskTitleView(task: task)
                    Spacer()
                        
                    }
                    .padding(.leading)
                    Spacer()
                    VStack {
                        
                        CompleteTaskButtonView(task: task, timerVM: timerVM, taskVM: taskVM)
                            .padding(.trailing, 25)
                        
                    }
                    
                   
                }
                .frame(maxWidth: .infinity, maxHeight: 50, alignment: .topLeading)
          
                
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: 80)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
        .padding(.horizontal, 10)
    
    }
}



struct TaskTitleView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var task: AppTask

    
    
    var body: some View {
        
        Text("\(task.title ?? "")")
            .font(.system(size: 24, weight: .bold, design: .default))
            .foregroundColor(colorScheme == .dark ? .white : .black)
//            .fill(colorScheme == .dark ? .gray.opacity(0.30) : .white)
    }
}

struct TaskElapsedTimeView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var task: AppTask
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
            Text("\(timerVM.countDownViewElapsed[task.objectID]?.asHoursMinutesSeconds() ?? "")")
            .font(.title2)
            .bold()
            .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    
}

struct TaskElapsedTimeViewSmall: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var task: AppTask
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
            Text("\(timerVM.countDownViewElapsed[task.objectID]?.asHoursMinutesSeconds() ?? "")")
            .font(.headline)
            .bold()
            .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    
}

struct TaskRemainingTimeView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var task: AppTask
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        if let timer = task.timer {
            
            HStack {
                Text("Remaining:")
                    .foregroundColor(timer.isRunning ? Color.red : (colorScheme == .dark ? .white : .black))
                Text("\(timerVM.countDownView[task.objectID]?.asHoursMinutesSeconds() ?? "")")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
    }
}

struct TaskPercentView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var task: AppTask
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
        Text("Progress: \(Int(timerVM.percentageValues[task.objectID] ?? 0))%")
            .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    
}

struct TaskDateTimeView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var task: AppTask
    @ObservedObject var timerVM: TimerViewModel
    var goal: Goal?
    var showBoth: Bool? 
    

    
    
    
    var body: some View {
        
        if showBoth == true {
            if let dateDue = task.dateDue {
                if task.dateOnly == false {
                    VStack {
                        Text(
                            dateDue.formatted(
                                Date.FormatStyle
                                    .dateTime
                                    .month(.twoDigits)
                                    .day(.twoDigits)
                                    .year(.twoDigits)
                            )
                        )
                        Text(dateDue.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))
                    }
                } else {
                    Text(
                        dateDue.formatted(
                            Date.FormatStyle
                                .dateTime
                                .month(.twoDigits)
                                .day(.twoDigits)
                                .year(.twoDigits)
                        )
                    )
                    
                }
            }
        }
        
        
        
        if goal != nil {
            if let dateDue = task.dateDue {
                if task.dateOnly == false {
                    VStack {
                        Text(
                            dateDue.formatted(
                                Date.FormatStyle
                                    .dateTime
                                    .month(.twoDigits)
                                    .day(.twoDigits)
                                    .year(.twoDigits)
                            )
                        )
                        Text(dateDue.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))
                    }
                } else {
                    Text(
                        dateDue.formatted(
                            Date.FormatStyle
                                .dateTime
                                .month(.twoDigits)
                                .day(.twoDigits)
                                .year(.twoDigits)
                        )
                    )
                    
                }
            }
            
        } else if showBoth == nil {
            if let dateDue = task.dateDue {
                if task.dateOnly == false {
                    Text(dateDue.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))
                } else {
                    Text(
                        dateDue.formatted(
                            Date.FormatStyle
                                .dateTime
                                .month(.twoDigits)
                                .day(.twoDigits)
                                .year(.twoDigits)
                        )
                    )
                }
            }
        }
    }
}

struct TaskProgressBarView: View {
    
    @ObservedObject var task: AppTask
    @ObservedObject var timerVM: TimerViewModel
    
    
    
    
    
    var body: some View {
        
        
        if let timerTask = task.timer {
            
            HStack {
                ProgressView(
                    value: min(max(timerVM.countDownViewElapsed[task.objectID] ?? 0.0, 0), timerTask.countdownNum),
                    total: timerTask.countdownNum
                )
                .tint(timerTask.isRunning ? .red : .accentColor)
                .clipShape(Capsule())

                
                //                    .animation(.none, value: isCompactView)
                
//                Text("\(Int(timerTask.percentCompletion))%")
                //                    .animation(.none, value: isCompactView)
            }
            
        }
    }
}


struct TaskProgressBarViewSmall: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var task: AppTask
    @ObservedObject var timerVM: TimerViewModel
    
    
    var body: some View {
        
        
        if let timerTask = task.timer {
            
            
            HStack {
                ProgressView(value: timerVM.countDownViewElapsed[task.objectID] ?? 0.0, total: timerTask.countdownNum)
                //                    .frame(width: isEditView  == true ? 100 : 120, height: 12)
                    .tint(timerTask.isRunning == true ? Color.red : Color.accentColor)
                    .clipShape(Capsule())
                //                    .animation(.none, value: isCompactView)
                
                Text("\(Int(timerTask.percentCompletion))%")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                //                    .animation(.none, value: isCompactView)
            }
        }
    }
}


struct StartTaskButtonView: View {
    @ObservedObject var task: AppTask
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var taskVM: TaskViewModel
    @Binding var selectedSort: TaskSortOption
    var proxy: ScrollViewProxy
    
    
    var body: some View {
        
        if let taskTimer = task.timer {
            
            Button(action: {
                if taskTimer.timerManualToggled == false && taskTimer.isRunning == false /*|| taskTimer.timerManualToggled == nil*/ {
                    timerVM.toggleTimerOn(task: task)
                    taskTimer.continueFromRefresh = false
                    timerVM.startUITimer(task: task)
//                    displayedTasks = taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
                    if selectedSort == .recent {
                        withAnimation {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                } else {
                    timerVM.toggleTimerOff(task: task)
                    taskTimer.continueFromRefresh = false
                    timerVM.startUITimer(task: task)
                }
            }) {
                Text(taskTimer.isRunning == false ? "Start" : "Stop")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(taskTimer.isRunning ? Color.red :Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 2)
            }
            .transition(.opacity)
            
        }
    }
}


struct CompleteTaskButtonView: View {
    @ObservedObject var task: AppTask
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var taskVM: TaskViewModel

    
    
    var body: some View {
        
            
            Button(action: {
                taskVM.completeTask(task: task)
            }) {
                Text("Complete")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 2)
            }
            .transition(.opacity)
            
        }
    
}



//#Preview {
//    let gvm = GoalViewModel()
//       let tvm = TaskViewModel()
//       let timerVM = TimerViewModel(taskViewModel: tvm, goalViewModel: gvm)
//       
//       let context = PersistenceController.preview.container.viewContext
//       let mockTask = Task(context: context)
//       mockTask.title = "Preview Task"
//       let mockTimer = TimerEntity(context: context)
//       mockTimer.elapsedTime = 42
//       mockTimer.cdTimerEndDate = Date().addingTimeInterval(100)
//       mockTimer.cdTimerStartDate = Date()
//       mockTimer.countdownTimer = 100
//       mockTimer.countdownNum = 100
//       mockTimer.isRunning = true
//       mockTask.timer = mockTimer
//       mockTask.dateDue = Date()
//    
//       
//       // ✅ Manually simulate dictionary values
//       timerVM.countDownViewElapsed[mockTask.objectID] = 42
//       timerVM.countDownView[mockTask.objectID] = 58
//
//       return TaskRectangularNavLink(taskVM: tvm, timerVM: timerVM, task: mockTask)
//}
