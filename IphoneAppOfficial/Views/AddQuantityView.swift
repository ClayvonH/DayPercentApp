//
//  AddQuantityView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 9/5/25.
//

import SwiftUI
import CoreData

struct AddQuantityView: View {
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
    @State private var showEmptyQuantityValAlert = false
    
    var body: some View {
   
            VStack {
                Text("Select quantity value for ")
                    .font(.title2)
                    .bold()
                Text("\(task.title ?? "Task")")
                    .font(.title2)
                    .bold()
                    
                
                TextField("Enter Quantity Value", text: $inputNumberText)
                    .font(.title)
                    .bold()
                    .padding(.leading, 10)
                    .keyboardType(.decimalPad)
                    .frame(height: 40)
                
                VStack {
                    Text("Select time estimate per quantity for ")
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
                    guard Double(inputNumberText) != nil else {
                        showEmptyQuantityValAlert = true
                        return
                    }
                    
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
            .alert("Please enter a quantity value.", isPresented: $showEmptyQuantityValAlert) {
                Button("OK", role: .cancel) { }
            }
            
            
            
        }
    
}

