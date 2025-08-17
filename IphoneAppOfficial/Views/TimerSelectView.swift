//
//  TimerSelectView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/2/25.
//

import SwiftUI
import CoreData

struct TimerSelectView: View {
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
                HStack {
                    
                    
                    if addTimer == false {
                        Spacer()
                    }
                    if addTimer == false && addQuantityVal == false {
                        
                        
                        Button(action: {
                            addTimer.toggle()
                            addQuantityVal = false
                        }, label: {
                            if addTimer == true {
                                Text("Cancel Timer")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .contentShape(Rectangle())
                            } else {
                                Text("Add Timer")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .contentShape(Rectangle())
                            }
                        })
                        
                        .frame( width: 150,height: 40)
                        
                        .foregroundStyle(.black)
                        
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        
                        .padding(.top)
                    }
                    if addTimer == false && addQuantityVal == false {
                        Text("or")
                            .bold()
                            .padding(.top)
                    }
                    
                    
                    
                    if addTimer == false && addQuantityVal == false {
                        
                        
                        Button(action: {
                            addQuantityVal.toggle()
                            addTimer = false
                        }, label: {
                            Text("Add Quantity Value")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        })
                        .frame(width: 170,height: 40)
                        
                        .foregroundStyle(.black)
                        
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        
                        .padding(.top)
                        Spacer()
                        
                    }
                }
                
                
                if addTimer == true {
                    Text("Select timer value for \(task.title ?? "Task")")
                        .font(.title2)
                        .bold()
                    
                    HStack {
                        
                        VStack {
                            Picker("Hours", selection: $hours, content: {
                                Text("Hours")
                                ForEach(0..<24, content: {
                                    number in
                                    Text("\(number)").tag(Double(number))
                                })
                            }).pickerStyle(WheelPickerStyle())
                        }
                        
                        VStack {
                            Picker("Minutes", selection: $minutes, content: {
                                Text("Minutes")
                                ForEach(0..<60, content: {
                                    number in
                                    Text("\(number)").tag(Double(number))
                                })
                            }).pickerStyle(WheelPickerStyle())
                        }
                        
                        VStack {
                            
                            Picker("Seconds", selection: $seconds, content: {
                                Text("Seconds")
                                ForEach(0..<60, content: {
                                    number in
                                    Text("\(number)").tag(Double(number))
                                })
                            }).pickerStyle(WheelPickerStyle())
                        }
                    }
                    
                    Button(action: {
                        
                        if (task.repeating == false) {
                            taskVM.addTimerToTask(task: task)
                            timerVM.countDownTimer(task: task, seconds: seconds, minutes: minutes, hours: hours)
                            if let goal = goal {
                                goalVM.GoalElapsedTime(goal: goal)
                            }
                                dismiss()
                            
                        } else {
                            taskVM.addMultipleTimers(task: task)
                            taskVM.addMultipleCountdownTimers(task: task, seconds: seconds, minutes: minutes, hours: hours)
                            if let goal = goal {
                                goalVM.GoalElapsedTime(goal: goal)
                            }
                                dismiss()
                            
                        }
                    }, label: {
                        
                        Text("SUBMIT")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                    })
                    
                    .frame(width: 350,height: 40)
                    .foregroundStyle(.white)
                    .background(Color(.blue))
                    .cornerRadius(15)
                    .padding(.top, 40)
                    .padding(.leading, 9)
                }
                
                if addQuantityVal == true {
                    VStack {
                        Text("Select quantity value for ")
                            .font(.title2)
                            .bold()
                        Text("\(task.title ?? "Task")")
                            .font(.title2)
                            .bold()
                            
                        
                        TextField("Enter Quantity Value", text: $inputNumberText)
                            .font(.title2)
                            .padding(.leading, 10)
                            .keyboardType(.decimalPad)
                            .frame(height: 40)
                        
                        VStack {
                            Text("Select time per quantity for ")
                                .font(.title2)
                                .bold()
                            Text("\(task.title ?? "Task")")
                                .font(.title2)
                                .bold()
                        }
                                .padding(.top, 20)
                                
                      
                        
                        HStack {
                            
                            VStack {
                                Picker("Hours", selection: $hours, content: {
                                    Text("Hours")
                                    ForEach(0..<24, content: {
                                        number in
                                        Text("\(number)").tag(Double(number))
                                    })
                                }).pickerStyle(WheelPickerStyle())
                            }
                            
                            VStack {
                                Picker("Minutes", selection: $minutes, content: {
                                    Text("Minutes")
                                    ForEach(0..<60, content: {
                                        number in
                                        Text("\(number)").tag(Double(number))
                                    })
                                }).pickerStyle(WheelPickerStyle())
                            }
                            
                            VStack {
                                
                                Picker("Seconds", selection: $seconds, content: {
                                    Text("Seconds")
                                    ForEach(0..<60, content: {
                                        number in
                                        Text("\(number)").tag(Double(number))
                                    })
                                }).pickerStyle(WheelPickerStyle())
                            }
                        }
                        
                        
                        Button(action: {
                            
                            let newNumber = Double(inputNumberText) ?? 0
                            if task.repeating == false {
                                taskVM.addQuantityVal(task: task, qVal: newNumber)
                                taskVM.timeEstimatePerQuantity(task: task, hours: hours, minutes: minutes, seconds: seconds)
                                if let goal = goal {
                                    goalVM.GoalElapsedTime(goal: goal)
                                }
                               
                                    dismiss()
                                
                            } else {
                                taskVM.addMultipleQuantityVals(task: task, qVal: newNumber)
                                taskVM.timeEstimatePerQuantityMultiple(task: task, hours: hours, minutes: minutes, seconds: seconds)
                                if let goal = goal {
                                    goalVM.GoalElapsedTime(goal: goal)
                                }
                               
                                    dismiss()
                                
                            }
                        }, label: {
                            
                            Text("SUBMIT")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        })
                        
                        .frame(width: 350,height: 40)
                        .foregroundStyle(.white)
                        .background(Color(.blue))
                        .cornerRadius(15)
                        .padding(.top, 40)
                        .padding(.leading, 9)
                    }
                    .frame(minHeight: 500, alignment: .top)
                    
                    
                    
                    
                }
                
                
                HStack {
                    Spacer()
                    
                    if addTimer == false && addQuantityVal == false {
                        Button(action: {
                            if goal != nil {
                                showGoalView.toggle()
                            } else {
                                dismiss()
                            }
                            
                            
                            
                        }, label: {
                            
                            Text("CANCEL")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        })
                        
                        .frame(width: 150,height: 40)
                        
                        .foregroundStyle(.black)
                        
                        .background(Color.gray.opacity(0.2))
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
                                .contentShape(Rectangle())
                        })
                        
                        .frame(width: 150,height: 40)
                        
                        .foregroundStyle(.black)
                        
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        
                        .padding(.top)
                        Spacer()
                    }
                    
                }
            }
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
