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
    @State private var selectedSort: GoalSortOption = .recent
    
    var displayedGoals: [Goal] {
//        taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
        goalVM.sortedGoals(goals: goalVM.savedGoals, option: selectedSort)
    }
    
    
    var body: some View {
      
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Goals")
                        .font(.largeTitle.bold())
                        .padding(.horizontal)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    GoalSortView(selectedSort: $selectedSort)
                }
                .frame(maxWidth: .infinity)
                
                ScrollView {
                    VStack(alignment: .center, spacing: 5) {
                        ForEach(displayedGoals) { goal in
                            if !goal.isComplete {
                                
                                
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
                                                    .background(colorScheme == .dark ? .gray.opacity(0.20) : .white)
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
                                                .fill(colorScheme == .dark ? Color(.gray.opacity(0.20)) : Color.white)
                                            
                                            
                                            VStack {
                                                
                                                VStack (alignment: .center) {
                                                    
                                                    Text(goal.title ?? "No title")
                                                        .font(.title2).bold()
                                                        .foregroundColor(.primary)
                                                        .multilineTextAlignment(.center)
                                                    
                                                    
                                                    HStack {
                                                        Text("Due: ")
                                                            .font(.headline)
                                                            .bold()
                                                        
                                                        Text("\(goal.dateDue ?? Date(), style: .date)")
                                                    }
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    if let tasks = goal.task as? Set<AppTask> {
                                                        let completed = tasks.filter { $0.isComplete }.count
                                                        let total = tasks.count
                                                        let percentDone = (Double(completed) / Double(total)) * 100
                                                        
                                                        let _: Double = total > 0 ? (Double(completed) / Double(total)) * 100 : 0.0
                                                        //                                                    let percentString = String(format: "%.2f", percent)
                                                        HStack {
                                                            Text("Tasks Completed:")
                                                                .font(.headline)
                                                                .bold()
                                                            
                                                            Text("\(completed)/\(total)")
                                                            
                                                            if total > 0 {
                                                                Text("\(String(format: "%.1f", percentDone))%")
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    HStack {
                                                        if goal.estimatedTimeRemaining > 0 {
                                                            Text("Time Remaining:")
                                                                .bold()
                                                                .font(.headline)
                                                            Text(" \(goal.estimatedTimeRemaining.asHoursMinutesSecondsWithLabels())")
                                                            
                                                            
                                                            
                                                        }
                                                        
                                                    }
                                                    //                                            .background(Color.blue)
                                                    .frame(maxWidth: 350)
                                                    
                                                    
                                                    HStack {
                                                        if let tasks = goal.task as? Set<AppTask>, !tasks.isEmpty && goal.overAllTimeCombined > 0 {
                                                            if goal.combinedElapsed < goal.overAllTimeCombined {
                                                                ProgressView(value: goal.combinedElapsed, total: goal.overAllTimeCombined)
                                                                    .frame(width: 50, height: 10)
                                                                    .tint(Color.accentColor)
                                                                    .clipShape(Capsule())
                                                                
                                                                Text(" \(Int(goal.percentComplete))%")
                                                                
                                                            }
                                                        }
                                                    }
                                                    
                                                }
                                                .frame(maxWidth: 380, alignment: .center)
                                                .padding(.leading)
                                                //                                            .background(Color.green)
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                            }
                                            //                                        .background(Color.red)
                                            .frame(maxWidth: 370, alignment: .center)
                                            
                                            
                                            
                                        }
                                        
                                        
                                        
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 140)
                                    
                                    
                                }
                                .padding(.horizontal, 12)
                                .frame(maxHeight: 180)
                                
                            }
                            
                        }
                    }
                    
                    
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 5)
                
                HStack {
                    
                    Button(action: {
                        isEditView.toggle()
                    }, label: {
                        if isEditView == false {
                            Text("Delete Goal")
                        } else {
                            Text("Done")
                        }
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
                    ToolbarItem(placement: .navigationBarTrailing) {
                                   NavigationLink(
                                       destination: CompletedGoals(
                                           taskVM: taskVM,
                                           timerVM: timerVM,
                                           goalVM: goalVM
                                       )
                                   ) {
                                       Text("Completed Goals")
                                           .padding(.top, 7)
                                   }
                               }
                }
                
            }
            .sheet(isPresented: $showCreateGoal) {
                CreateGoalView(goalVM: goalVM)
                    }
            .padding(.top)
            .background(colorScheme == .dark ? .black.opacity(0.10) : .gray.opacity(0.15))
            
            
            
        
        .onAppear{
            goalVM.fetchGoals()
            goalVM.goalElapsedTimeAll(goals: goalVM.savedGoals)
            goalVM.lastActive(goals: goalVM.savedGoals)
        }
        
        
        
    }
    
}

//#Preview {
//    
//    
////    GoalsView(goalVM: GoalViewModel())
//}
