//
//  QValTaskRectangularNavLink.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/4/25.
//

import SwiftUI
import CoreData


struct QValTaskRectangularNavLink: View {
    @ObservedObject var taskVM: TaskViewModel
    
    @ObservedObject var timerVM: TimerViewModel
    
    @ObservedObject var task: Task
    
    @Binding var selectedTask: Task?
    @Binding var isShowingUpdateSheet: Bool
    
    @Binding var selectedSort: TaskSortOption
    var proxy: ScrollViewProxy
    
    @Environment(\.colorScheme) var colorScheme
    
    
    
    var body: some View {
        NavigationLink(destination: TaskView(taskVM: taskVM, timerVM: timerVM, task: task)) {
            ZStack {
                
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(.gray.opacity(0.15)) : Color.white)
                HStack {
                    VStack (alignment: .leading, spacing: 7) {
                        
                        TaskTitleView(task: task)
                        
                        QValCurrentQuantityView(task: task, timerVM: timerVM)
                        
                        QValTaskRemainingTimeView(task: task, timerVM: timerVM)
                        
                        QValTaskPercentView(task: task, timerVM: timerVM)
                        
                        QValTaskProgressBarView(task: task, timerVM: timerVM)
                            .padding(.top, 8)
                            
                        
                      
//                        TaskTitleView(task: task)
//                        
//                        TaskElapsedTimeView(task: task, timerVM: timerVM)
//                        
//                        TaskRemainingTimeView(task: task, timerVM: timerVM)
//                        
//                        TaskPercentView(task: task, timerVM: timerVM)
//                        
//                        TaskProgressBarView(task: task, timerVM: timerVM)
//                            .padding(.top, 8)
                        
                    }
                    .padding(.top, 3)
                    .padding(.leading)
                    Spacer()
                    VStack {
                        TaskDateTimeView(task: task, timerVM: timerVM)
                        Spacer()
                        
                        UpdateTaskButtonView(task: task, timerVM: timerVM, taskVM: taskVM, selectedTaskForSheet: $selectedTask, isShowingSheet: $isShowingUpdateSheet, selectedSort: $selectedSort, proxy: proxy)
                            .padding(.trailing, 25)
                        Spacer()
                    }
                    
                   
                }
                .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 150, alignment: .topLeading)
                .background(Color.white)
                
                
                
            }
        }
        .frame(maxWidth: .infinity, minHeight: 170, maxHeight:180)
        .padding(.horizontal, 10)
        .buttonStyle(PlainButtonStyle())
    
    }
}

struct QValTaskRectangularNavLinkSmall: View {
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var task: Task
    
    @Binding var selectedTask: Task?
    @Binding var isShowingUpdateSheet: Bool
    
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
                            QValCurrentQuantityViewSmall(task: task, timerVM: timerVM)
//                                .background(Color.white)
                            
                            Spacer()
                            QValTaskProgressBarViewSmall(task: task, timerVM: timerVM)
                                .frame(width: 150)
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(.leading, 20) // <-- Push content closer to left
//                    .padding(.top, 8)
                    
                    Spacer()
                    
                    UpdateTaskButtonView(task: task, timerVM: timerVM, taskVM: taskVM, selectedTaskForSheet: $selectedTask, isShowingSheet: $isShowingUpdateSheet, selectedSort: $selectedSort, proxy: proxy)
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
        .padding(.horizontal, 10)
    }
}



//struct TaskTitleView: View {
//    @ObservedObject var task: Task
//
//    
//    
//    var body: some View {
//        
//        Text("\(task.title ?? "")")
//            .font(.system(size: 24, weight: .bold, design: .default))
//            .foregroundColor(Color.black)
//    }
//}

struct QValCurrentQuantityView: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
        Text("\(Int(task.quantityval?.currentQuantity ?? 0)) / \(Int(task.quantityval?.totalQuantity ?? 0))")
            .font(.title2)
            .bold()
                .foregroundColor(Color.black)
        }
    
}

struct QValCurrentQuantityViewSmall: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
        Text("\(Int(task.quantityval?.currentQuantity ?? 0)) / \(Int(task.quantityval?.totalQuantity ?? 0))")
            .bold()
                .foregroundColor(Color.black)
        }
    
}

struct QValTaskRemainingTimeView: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
        Text("Remaining: \(task.quantityval?.estimatedTimeRemaining.asHoursMinutesSeconds() ?? "")")
            
                .foregroundColor(Color.black)
        }
    
}

struct QValTaskPercentView: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    

    
    
    
    var body: some View {
        
       
            
        Text("Progress: \(Int(task.quantityval?.percentCompletion ?? 0))%")
                .foregroundColor(Color.black)
        }
    
}

struct QValTaskProgressBarView: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    
    
    
    
    
    var body: some View {
        
        

            
            
            HStack {
                ProgressView(value: task.quantityval?.currentQuantity ?? 0.0, total: task.quantityval?.totalQuantity ?? 0.0)
                //                    .frame(width: isEditView  == true ? 100 : 120, height: 12)
                    .tint(Color.accentColor)
                    .clipShape(Capsule())
                
                //                    .animation(.none, value: isCompactView)
                
//                Text("\(Int(timerTask.percentCompletion))%")
                //                    .animation(.none, value: isCompactView)
            }
            
        
    }
}


struct QValTaskProgressBarViewSmall: View {
    
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    
    
    
    
    
    var body: some View {
        
        
       
            
            
            HStack {
                ProgressView(value: task.quantityval?.currentQuantity ?? 0.0, total: task.quantityval?.totalQuantity ?? 0.0)
                //                    .frame(width: isEditView  == true ? 100 : 120, height: 12)
                    .tint(Color.accentColor)
                    .clipShape(Capsule())
                //                    .animation(.none, value: isCompactView)
                
                Text("\(Int(task.quantityval?.percentCompletion ?? 0.0))%")
                //                    .animation(.none, value: isCompactView)
            }
        
    }
}


struct UpdateTaskButtonView: View {
    @ObservedObject var task: Task
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var taskVM: TaskViewModel
    @Binding var selectedTaskForSheet: Task?
    @Binding var isShowingSheet: Bool
    @Binding var selectedSort: TaskSortOption
    var proxy: ScrollViewProxy
    
//    @Binding var displayedTasks: [Task]
//    @Binding var selectedSort: TaskSortOption

    
    
    var body: some View {
        
        Button(action: {
            taskVM.lastActive(task: task)
            selectedTaskForSheet = task
//            displayedTasks = taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
//            if selectedSort == .recent {
//                withAnimation {
//                    proxy.scrollTo("top", anchor: .top)
//                }
//            }
            if selectedSort == .recent {
                withAnimation {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
            
        }) {
            Text("Update")
                .font(.subheadline.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(radius: 2)
        }
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
//       let mockQuantity = QuantityValue(context: context)
//       mockQuantity.timeElapsed = 20
//       mockQuantity.totalQuantity = 100
//       mockQuantity.currentQuantity = 20
//       mockQuantity.timePerQuantityVal = 1
//       mockQuantity.percentCompletion = 20
//      
////       mockTimer.cdTimerEndDate = Date().addingTimeInterval(100)
////       mockTimer.cdTimerStartDate = Date()
////       mockTimer.countdownTimer = 100
////       mockTimer.countdownNum = 100
////       mockTimer.isRunning = true
////       mockTask.timer = mockTimer
//       
//       // ✅ Manually simulate dictionary values
////       timerVM.countDownViewElapsed[mockTask.objectID] = 42
////       timerVM.countDownView[mockTask.objectID] = 58
//    
//    mockTask.quantityval = mockQuantity
////
////   return QValTaskRectangularNavLinkSmall(taskVM: tvm, timerVM: timerVM, task: mockTask)
//}
