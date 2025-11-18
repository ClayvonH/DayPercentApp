//
//  CreateGoalView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/12/25.
//


import SwiftUI
import CoreData

struct CreateGoalView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var goalVM: GoalViewModel
    @State private var goalTitle: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showEmptyTitleAlert = false
    
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading){
                
                HStack {
                    Text("Create Goal")
                        .font(.largeTitle)
                        .bold()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)
                .padding(.bottom, 20)
                
                    Text("GOAL TITLE")
                        .font(.title)
                        .bold()
            
                
                TextField("Enter Goal Title", text: $goalTitle)
                    .padding(.leading)
                    .font(.title)
                    .bold()
                    .frame(width: 350,height: 40)
                    .background(Color(.systemGray6))
                
                Text("Due Date")
                    .font(.title)
                    .bold()
                
                DatePicker("Select Date", selection: $selectedDate)
                    .padding(.horizontal)
                    
                
                Button(action: {
                    guard !goalTitle.isEmpty else {
                          showEmptyTitleAlert = true
                          return
                      }
                    
                    while goalTitle.last == " " {
                        goalTitle.removeLast()
                    }
                    
                    goalVM.addGoal(text: goalTitle, date: selectedDate)
                    goalVM.fetchGoals()
                    dismiss()
                }, label: {
                    
                    Text("CREATE GOAL")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                })
                
                .frame(width: 350,height: 40)
                .foregroundStyle(.white)
                .background(Color(.blue))
                .cornerRadius(15)
                .padding(.top, 40)
                .padding(.leading, 9)
                
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                        
                    }, label: {
                        
                        Text("CANCEL")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                    })
                    
                    .frame(width: 150,height: 40)
                    
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    
                    .padding(.top)
                    Spacer()
                }
                
                   
                
            }
            .frame(maxWidth: .infinity, maxHeight: 600, alignment: .topLeading)
            .padding(.horizontal)
            
            
            
        }
        .alert("Must enter a goal title", isPresented: $showEmptyTitleAlert) {
            Button("OK", role: .cancel) {
                
            }
        }
        
        
    }
        

        

}

#Preview {
    CreateGoalView(goalVM: GoalViewModel())
}
