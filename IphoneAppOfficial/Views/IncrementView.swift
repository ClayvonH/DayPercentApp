//
//  IncrementView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/4/25.
//
import SwiftUI
import CoreData

struct IncrementView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    let task: AppTask
    @State var goal: Goal?
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var goalVM: GoalViewModel
    @ObservedObject var timerVM: TimerViewModel
    @State private var inputNumberText: String = ""
    @State private var showAlert: Bool = false
//    @Binding var displayedTasks: [Task]
//    @Binding var selectedSort: TaskSortOption
    var body: some View {
        
        VStack {
            Text("\(task.title ?? "")")
                .font(.title)
                .bold()
            
            Text("\(Int(task.quantityval?.currentQuantity ?? 0))/ \(Int(task.quantityval?.totalQuantity ?? 0))")
                .font(.title)
                .bold()
        }
        .padding(.bottom)
       
        
        VStack {
            
         
            
            Text("Increment")
                .font(.title)
                .bold()
            
            
            TextField(" Enter New Quantity Value", text: $inputNumberText)
                .font(.title)
                .foregroundColor(colorScheme == .dark ? .white : .black)
//                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                .keyboardType(.decimalPad)
                .padding() // Adds padding inside the field
                .frame(height: 55) // Makes it taller and easier to tap
                .multilineTextAlignment(.center) 
                .cornerRadius(10)
                .contentShape(Rectangle()) // Ensures the whole rectangle is tappable
           
            
            Button(action: {
                
                let newNumber = Double(inputNumberText) ?? 0
                if newNumber > task.quantityval?.totalQuantity ?? 0 {
                    showAlert.toggle()
                } else {
                    taskVM.incrementQuantityVal(task: task, incVal: newNumber)
//                    displayedTasks = vm.sortedTasksAll(allTasks: vm.savedTasks, option: selectedSort)
                    if let goal = goal {
                        taskVM.GoalElapsedTime(goal: goal)
                        taskVM.fetchTasks(for: goal)
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
            
            Button(action: {
                
                dismiss()
                
            }, label: {
                
                Text("CANCEL")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            })
            
            .frame(width: 350,height: 40)
            .foregroundStyle(colorScheme == .dark ? .white : .black)
            .background(Color(.gray.opacity(0.2)))
            .cornerRadius(15)
            .padding(.top, 40)
            .padding(.leading, 9)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Invalid Quantity"),
                message: Text("Number is greater than total quantity."),
                dismissButton: .default(Text("OK"))
            )
        }
        
        
    }
       
    
}
