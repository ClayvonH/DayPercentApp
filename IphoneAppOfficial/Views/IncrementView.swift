//
//  IncrementView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/4/25.
//
import SwiftUI
import CoreData

struct IncrementView: View {
    @Environment(\.dismiss) var dismiss

    let task: Task
    @ObservedObject var taskVM: TaskViewModel
    @State private var inputNumberText: String = ""
    @State private var showAlert: Bool = false
//    @Binding var displayedTasks: [Task]
//    @Binding var selectedSort: TaskSortOption
    var body: some View {
        
        VStack {
            Text("Increment")
                .font(.title2)
                .bold()
            
            
            TextField("Enter Quantity Value", text: $inputNumberText)
                .font(.title2)
                .foregroundColor(.black)
                .keyboardType(.decimalPad)
                .padding() // Adds padding inside the field
                .frame(height: 55) // Makes it taller and easier to tap
            
                .cornerRadius(10)
                .contentShape(Rectangle()) // Ensures the whole rectangle is tappable
               
            
            Button(action: {
                
                let newNumber = Double(inputNumberText) ?? 0
                if newNumber > task.quantityval?.totalQuantity ?? 0 {
                    showAlert.toggle()
                } else {
                    taskVM.incrementQuantityVal(task: task, incVal: newNumber)
//                    displayedTasks = vm.sortedTasksAll(allTasks: vm.savedTasks, option: selectedSort)
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
            .foregroundStyle(.black)
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
