//
//  TaskView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 7/31/25.
//

import SwiftUI
import CoreData


struct TaskRectangularNavLink: View {
    @ObservedObject var taskVM: TaskViewModel
    
    @ObservedObject var timerVM: TimerViewModel
    
    @ObservedObject var task: Task
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var selectedSort: TaskSortOption
    
    var proxy: ScrollViewProxy
    
    
    
    var body: some View {
        NavigationLink(destination: TaskView(taskVM: taskVM, timerVM: timerVM, task: task)) {
            ZStack {
                
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(.gray.opacity(0.15)) : Color.white)
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
                        
                        TaskDateTimeView(task: task, timerVM: timerVM)
                        Spacer()
                        
                        StartTaskButtonView(task: task, timerVM: timerVM, taskVM: taskVM, selectedSort: $selectedSort, proxy: proxy)
                            .padding(.trailing, 25)
                        Spacer()
                        
                    }
                    
                   
                }
                .frame(minWidth: 395, minHeight: 140, maxHeight: 150, alignment: .topLeading)
                .background(Color.white)
                
                
                
            }
        }
        .frame(minWidth: 400, maxWidth: 405, minHeight: 170, maxHeight:180)
        .buttonStyle(PlainButtonStyle())
    
    }
}

struct TaskRectangularNavLinkSmall: View {
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var task: Task
    @Binding var selectedSort: TaskSortOption
    var proxy: ScrollViewProxy
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink(destination: TaskView(taskVM: taskVM, timerVM: timerVM, task: task)) {
            ZStack(alignment: .topLeading) { // <-- Align content to top-left
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(.gray.opacity(0.15)) : Color.white)

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
            .frame(width: 410, height: 80)
//            .background(Color.green)
          
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TaskRectangularNavLinkSimple: View {
    @ObservedObject var taskVM: TaskViewModel
    
    @ObservedObject var timerVM: TimerViewModel
    
    @ObservedObject var task: Task
    
    @Environment(\.colorScheme) var colorScheme
    
    
    
    var body: some View {
        NavigationLink(destination: TaskView(taskVM: taskVM, timerVM: timerVM, task: task)) {
            ZStack {
                
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(.gray.opacity(0.15)) : Color.white)
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
                        
                        TaskDateTimeView(task: task, timerVM: timerVM)
                        Spacer()
                        
                        CompleteTaskButtonView(task: task, timerVM: timerVM, taskVM: taskVM)
                            .padding(.trailing, 25)
                        Spacer()
                        
                    }
                    
                   
                }
                .frame(minWidth: 395, minHeight: 80, maxHeight: 100, alignment: .topLeading)
                .background(Color.white)
                
                
                
            }
        }
        .frame(minWidth: 400, maxWidth: 405, minHeight: 130, maxHeight:140)
        .buttonStyle(PlainButtonStyle())
    
    }
}

struct TaskRectangularNavLinkSimpleSmall: View {
    @ObservedObject var taskVM: TaskViewModel
    
    @ObservedObject var timerVM: TimerViewModel
    
    @ObservedObject var task: Task
    
    @Environment(\.colorScheme) var colorScheme
    
    
    
    var body: some View {
        NavigationLink(destination: TaskView(taskVM: taskVM, timerVM: timerVM, task: task)) {
            ZStack {
                
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(.gray.opacity(0.15)) : Color.white)
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
                .background(Color.white)
                
                
                
            }
        }
        .frame(width: 410, height: 80)
        .buttonStyle(PlainButtonStyle())
    
    }
}



struct TaskTitleView: View {
    @ObservedObject var task: Task

    
    
    var body: some View {
        
        Text("\(task.title ?? "")")
            .font(.system(size: 24, weight: .bold, design: .default))
            .foregroundColor(Color.black)
    }
}

struct TaskElapsedTimeView: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
            Text("\(timerVM.countDownViewElapsed[task.objectID]?.asHoursMinutesSeconds() ?? "")")
            .font(.title2)
            .bold()
                .foregroundColor(Color.black)
        }
    
}

struct TaskElapsedTimeViewSmall: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
            Text("\(timerVM.countDownViewElapsed[task.objectID]?.asHoursMinutesSeconds() ?? "")")
            .font(.headline)
            .bold()
                .foregroundColor(Color.black)
        }
    
}

struct TaskRemainingTimeView: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
            Text("Remaining: \(timerVM.countDownView[task.objectID]?.asHoursMinutesSeconds() ?? "")")
            
                .foregroundColor(Color.black)
        }
    
}

struct TaskPercentView: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
        Text("Progress: \(Int(timerVM.percentageValues[task.objectID] ?? 0))%")
                .foregroundColor(Color.black)
        }
    
}

struct TaskDateTimeView: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
        if let dateDue = task.dateDue {
            Text(dateDue.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))
        }
        }
    
}

struct TaskProgressBarView: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    
    
    
    
    
    var body: some View {
        
        
        if let timerTask = task.timer {
            
            
            HStack {
                ProgressView(value: timerVM.countDownViewElapsed[task.objectID] ?? 0.0, total: timerTask.countdownNum)
                //                    .frame(width: isEditView  == true ? 100 : 120, height: 12)
                    .tint(timerTask.isRunning == true ? Color.red : Color.accentColor)
                    .clipShape(Capsule())
                
                //                    .animation(.none, value: isCompactView)
                
//                Text("\(Int(timerTask.percentCompletion))%")
                //                    .animation(.none, value: isCompactView)
            }
            
        }
    }
}


struct TaskProgressBarViewSmall: View {
    
    @ObservedObject var task: Task
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
                //                    .animation(.none, value: isCompactView)
            }
        }
    }
}


struct StartTaskButtonView: View {
    @ObservedObject var task: Task
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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 2)
            }
            .transition(.opacity)
            
        }
    }
}


struct CompleteTaskButtonView: View {
    @ObservedObject var task: Task
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
