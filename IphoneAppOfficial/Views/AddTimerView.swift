//
//  AddTimerView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 9/5/25.
//
import SwiftUI
import CoreData

struct AddTimerView: View {
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
    
    @State private var cannotChooseZeroAlert = false
    
    var body: some View {
        
            
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
                
                guard (seconds + minutes + hours > 0) else {
                    cannotChooseZeroAlert = true
                    return
                }
                
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
            .alert("Timer cannot be zero.", isPresented: $cannotChooseZeroAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        
    
        
    
}

