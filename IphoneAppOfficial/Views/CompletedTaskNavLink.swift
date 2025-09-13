//
//  CompletedTaskNavLink.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/5/25.
//

import SwiftUI

struct CompletedTaskNavLink: View {
    @ObservedObject var goalVM: GoalViewModel
    
    @ObservedObject var taskVM: TaskViewModel
    
    @ObservedObject var timerVM: TimerViewModel
    
    @ObservedObject var task: Task
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink(destination: TaskView( goalVM: goalVM, taskVM: taskVM, timerVM: timerVM, task: task)) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? .gray.opacity(0.20) : .white)
                HStack(alignment: .center) {
                    
                    VStack (alignment: .center, spacing: 7) {
                        Spacer()
                        TaskTitleView(task: task)
                        
//                        TaskElapsedTimeView(task: task, timerVM: timerVM)
//                        
//                        TaskRemainingTimeView(task: task, timerVM: timerVM)
//                        
//                        TaskPercentView(task: task, timerVM: timerVM)
//                        
//                        TaskProgressBarView(task: task, timerVM: timerVM)
//                            .padding(.top, 8)
                        Spacer()
                        
                    }
                    .padding(.top, 3)
                    .padding(.leading)
//                    Spacer()
                    VStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.red)
              
                        
                    }
                    
                   
                }
                .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
           
                
                
                
            }
        }
        .frame(maxWidth: .infinity, minHeight: 80, maxHeight:90)
        .padding(.horizontal, 10)
        .buttonStyle(PlainButtonStyle())
    }
}
//
//#Preview {
//    
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
//       
//       // ✅ Manually simulate dictionary values
//       timerVM.countDownViewElapsed[mockTask.objectID] = 42
//       timerVM.countDownView[mockTask.objectID] = 58
//
//       return CompletedTaskNavLink(taskVM: tvm, timerVM: timerVM, task: mockTask)
//}
