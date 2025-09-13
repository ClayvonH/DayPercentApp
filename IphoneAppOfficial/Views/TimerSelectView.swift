//
//  TimerSelectView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/2/25.
//

import SwiftUI
import CoreData

struct TimerSelectView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var goalVM: GoalViewModel
    @ObservedObject var timerVM: TimerViewModel
    @State var goal: Goal?
    @ObservedObject var task: Task
    @State var seconds:  Double = 0
    @State var minutes: Double = 0
    @State var hours: Double = 0
    @State private var addTimer: Bool = false
    @State private var addQuantityVal: Bool = false
    
    @State private var showGoalView: Bool = false
    
    @State private var inputNumberText: String = ""

    

    var body: some View {
        
      
            VStack {
                if addTimer == false && addQuantityVal == false {
                    HStack {
                        Spacer()
                        Text("Add a timer to your task and track your progress.")
                            .frame(width: 130)
                        
                        Spacer()
                        
                        Text("Add a numeric value to task.  Increment until completion.")
                            .frame(width: 130)
                        Spacer()
                    }
                  
                    
                }
                
                HStack {
                    
                    
                    
                    if addTimer == false && addQuantityVal == false {
                        
                        
                        Button(action: {
                            addTimer.toggle()
                            addQuantityVal = false
                        }, label: {
                            
                            
                            Text("Add Timer")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                            
                        })
                        .frame( width: 150,height: 40)
                        .foregroundStyle(.white)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .padding(.top)
                        
                        
                        Text("or")
                            .bold()
                            .padding(.top)
                        
                        
                        Button(action: {
                            addQuantityVal.toggle()
                            addTimer = false
                        }, label: {
                            Text("Add Quantity Value")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        })
                        .frame(width: 170,height: 40)
                        .foregroundStyle(.white)
                        .background(Color.blue)
                        .cornerRadius(15)
                        
                        .padding(.top)
                        
                        
                        
                    }
                }
                
                if addTimer == true {
                    if let goal = goal {
                        AddTimerView(taskVM: taskVM, goalVM: goalVM, timerVM: timerVM, goal: goal, task: task)
                    } else {
                        AddTimerView(taskVM: taskVM, goalVM: goalVM, timerVM: timerVM, task: task)
                    }
                }
                
                if addQuantityVal == true {
                    if let goal = goal {
                        AddQuantityView(taskVM: taskVM, goalVM: goalVM, timerVM: timerVM, goal: goal, task: task)
                    } else {
                        AddQuantityView(taskVM: taskVM, goalVM: goalVM, timerVM: timerVM, task: task)
                    }
                }
            
                
                
                if addTimer == false && addQuantityVal == false {
                    
                    Text("Basic task with no additional features.")
                        .frame(width: 160)
                        .padding(.top)
                    
                HStack {
                    
                    Spacer()
                    
                        Button(action: {
                            if goal != nil {
//                                showGoalView.toggle()
                                
                                dismiss()
                                
                            } else {
                                dismiss()
                            }
  
                        }, label: {
                            
                            Text("Neither")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .contentShape(Rectangle())
                        })
                        .frame(width: 150,height: 40)
                        .foregroundStyle(.black)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.top)

                        Spacer()
                    }
                    
                }
              
                
                HStack {
                    Spacer()
                    
                    if addTimer == true || addQuantityVal == true {
                        Button(action: {
                            if addTimer == true {
                                addTimer.toggle()
                            } else {
                                addQuantityVal.toggle()
                            }
                        }, label: {
                            
                            Text("CANCEL")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .contentShape(Rectangle())
                        })
                        .frame(width: 150,height: 40)
                        .foregroundStyle(.black)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.top)
                        Spacer()
                    }
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme == .dark ? .gray.opacity(0.15) : .white)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showGoalView) {
                if let goal = goal {
                    GoalView(taskVM: taskVM, timerVM: timerVM, goalVM: goalVM, goal: goal)
                }
            }
        }
    
}

#Preview {
//    let context = PersistenceController.preview.container.viewContext
//   
//    let sampleTask = Task(context: context)
//    sampleTask.title = "Sample Task"
//    let sampleGoal = Goal(context: context)
//    sampleGoal.title = "Sample Task"
//    
//    return TimerSelectView(,goal: sampleGoal, task: sampleTask)
}


