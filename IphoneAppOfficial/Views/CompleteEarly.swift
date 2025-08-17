//
//  CompleteEarly.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/8/25.
//

import SwiftUI


struct CompleteEarly: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var timerVM: TimerViewModel
    @Binding var task: Task
    
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                Button {
                    taskVM.completeTaskEarly(task: task)
                    timerVM.updateCombinedTimers()
                    dismiss()
                } label: {
                    Text("Complete Early")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
                .frame(width: 150,height: 40)
                
                .foregroundStyle(.white)
                
                .background(Color.blue)
                .cornerRadius(15)
                
                .padding(.top)
                
                
                Spacer()
                
                Button {
                    taskVM.completeTask(task: task)
                    timerVM.updateCombinedTimers()
                    dismiss()
                } label: {
                    Text("Complete Task")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
                .frame(width: 150,height: 40)
                
                .foregroundStyle(.white)
                
                .background(Color.blue)
                .cornerRadius(15)
                
                .padding(.top)
                Spacer()
            }
            
            
            Button(action: {
                dismiss()
                
            }, label: {
                
                Text("CANCEL")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            })
            
            .frame(width: 150,height: 40)
            
            .foregroundStyle(.white)
            
            .background(Color.gray.opacity(0.3))
            .cornerRadius(15)
            
            .padding(.top, 20)
       
            
        }
    }
}

//
//#Preview {
//    let context = PersistenceController.preview.container.viewContext
//    let mockTask = Task(context: context)
//    mockTask.title = "Preview Task"
//    let mockTimer = TimerEntity(context: context)
//    mockTimer.elapsedTime = 42
//    mockTimer.cdTimerEndDate = Date().addingTimeInterval(100)
//    mockTimer.cdTimerStartDate = Date()
//    mockTimer.countdownTimer = 100
//    mockTimer.countdownNum = 100
//    mockTimer.isRunning = true
//    mockTask.timer = mockTimer
//    
// CompleteEarly(taskVM: TaskViewModel(), timerVM: TimerViewModel(taskViewModel: TaskViewModel(), goalViewModel: GoalViewModel()), task: mockTask)
//}
