//
//  GoalsView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/12/25.
//


import SwiftUI
import CoreData

struct GoalsView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var goalVM: GoalViewModel
    @State private var showCreateGoal = false
    @State private var isCompactView = false
    
    @State private var isEditView = false
    @State private var showDeleteConfirmation = false
    @State private var goalToDelete: Goal? = nil
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Goals")
                    .font(.largeTitle.bold())
                    .fontDesign(.serif)
                    .padding(.horizontal)
                    .foregroundStyle(.primary)
                
                ScrollView {
                    VStack(alignment: .center, spacing: 5) {
                        ForEach(goalVM.savedGoals) { goal in
                            
                            HStack {
                                if isEditView {
                                    HStack {
                                        Button(action: {
                                            showDeleteConfirmation = true
                                            goalToDelete = goal
                                           
                                        }){
                                            Image(systemName: "minus")
                                                .foregroundStyle(.red)
                                                .frame(width: 30, height: 30)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        
                                        .font(.body.bold())
                                        .foregroundColor(.blue)
                                        .alert("Are you sure you want to delete this goal?  All tasks associated with this goal will also be deleted.", isPresented: $showDeleteConfirmation) {
                                                    Button("Delete", role: .destructive) {
                                                        if let goal = goalToDelete {
                                                            goalVM.deleteGoal(goal)
                                                            goalVM.fetchGoals()
                                                        }
                                                        
                                                    }
                                                    Button("Cancel", role: .cancel) {
                                                       
                                                        
                                                    }
                                                }
                                        
                                    }
                                }
                                NavigationLink(destination: GoalView(taskVM: taskVM, timerVM: timerVM, goalVM: goalVM, goal: goal)) {
                                    ZStack {
                                        
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(colorScheme == .dark ? Color(.gray.opacity(0.1)) : Color.white)
                                        
                                       
                                        VStack {
                                            
                                            VStack (alignment: .center) {
                                                
                                                Text(goal.title ?? "No title")
                                                    .font(.title).bold()
                                                    .foregroundColor(.primary)
                                                
                                                Text("Due: \(goal.dateDue ?? Date(), style: .date)")
                                                    .font(.headline)
                                                    .bold()
                                                
                                                   
                                                
                                                if let tasks = goal.task as? Set<Task> {
                                                    let completed = tasks.filter { $0.isComplete }.count
                                                    let total = tasks.count
                                                    
                                                    let _: Double = total > 0 ? (Double(completed) / Double(total)) * 100 : 0.0
//                                                    let percentString = String(format: "%.2f", percent)
                                                    HStack {
                                                        Text("Tasks Completed:")
                                                            .font(.headline)
                                                            .bold()

                                                             Text("\(completed)/\(total)")
                                                            
                                                        
                                                    }
                                                    
                                                }
                                                
                                           
                                                 
                                                
                                                
                                                HStack {
                                                    Text("Time Remaining:")
                                                        .bold()
                                                        .font(.headline)
                                                    Text(" \(goal.estimatedTimeRemaining.asHoursMinutesSecondsWithLabels())")
                                                       
                                                    
                                                    if let tasks = goal.task as? Set<Task>, !tasks.isEmpty {
                                                        ProgressView(value: goal.combinedElapsed, total: goal.overAllTimeCombined)
                                                            .frame(width: 50, height: 10)
                                                            .tint(Color.accentColor)
                                                            .clipShape(Capsule())

                                                        Text(" \(Int(goal.percentComplete))%")
                                                           
                                                            .foregroundColor(.black)
                                                    }

                                                   
                                                }
    //                                            .background(Color.blue)
                                                .frame(maxWidth: 350)
                                                
                                                


                                            }
                                            .frame(maxWidth: 380, alignment: .center)
                                            .padding(.leading)
//                                            .background(Color.green)
                                            
                                            
                              
                                            
                                
                                           
                                           
                                            
                                            
                                            
                                            
                                        }
//                                        .background(Color.red)
                                        .frame(maxWidth: 370, alignment: .center)
                                        
                                        
                                        
                                    }
                                    
                                    
                                    
                                }
                                .frame(maxWidth: .infinity, minHeight: 150)
                              
                                
                            }
                            .padding(.horizontal, 12)
                            .frame(maxHeight: 180)
                            
                        }
                    }
                    
                    
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 5)
                
                HStack {
                    
                    Button(action: {
                        isEditView.toggle()
                    }, label: {
                        Text("edit")
                    })
                    Spacer()
                    
                    Button(action: {
                        showCreateGoal = true
                    }, label: {
                        Text("Create Goal")
                    })
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                .padding(.leading, 20)
                
                .toolbar {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        NavigationLink(destination: GPTDailyTaskVisuals(vm: vm)) {
//                            Text("Daily Tasks")
//                        }
//                    }
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        NavigationLink(destination: CalPracticeVM(vm:vm)) {
//                            Image(systemName: "calendar")
//                                .font(.title)
//                                .foregroundColor(.blue)
//                        }
//                    }
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        NavigationLink(destination: ProfileView()) {
//                            Text("Tasks")
//                        }
//                    }
                }
                
            }
            .sheet(isPresented: $showCreateGoal) {
                CreateGoalView(goalVM: goalVM)
                    }
            .padding(.top)
            .background(
                LinearGradient(
                    colors: colorScheme == .dark ? [Color.gray.opacity(0.15)] : [Color(.systemGray6), Color(.systemGray5)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            
            
            
        }
        .onAppear{
            goalVM.fetchGoals()
            goalVM.goalElapsedTimeAll(goals: goalVM.savedGoals)
            
        }
        
        
        
    }
    
}

//#Preview {
//    
//    
////    GoalsView(goalVM: GoalViewModel())
//}
