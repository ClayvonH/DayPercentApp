//
//  DailyTasksProgressFooter.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/11/25.
//
import SwiftUI
import CoreData


struct DailyTaskProgressFooter: View {
    
    
    var goal: Goal?
    var date: Date?
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var goalVM: GoalViewModel
   var displayedTasks: [Task]
    @Environment(\.colorScheme) var colorScheme

    var completedCount: Int {
        displayedTasks.filter { $0.isComplete }.count
    }

    var totalCount: Int {
        displayedTasks.count
    }

    var body: some View {
//        if displayedTasks.count > 0 {
        
            VStack {
                Text("Tasks Completed:  \(completedCount)/\(totalCount)")
                    .bold()
                    .foregroundColor(.primary)

                HStack {
                    Spacer()
                    if let goal = goal {
                        if goal.estimatedTimeRemaining > 0 {
                            
                            
                            Text("Time Remaining: \(goal.estimatedTimeRemaining.asHoursMinutesSeconds())")
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    } else if (date == nil) {
                        if timerVM.taskTimeRemaining > 0 {
                            
                            Text("Time Remaining: \(timerVM.taskTimeRemaining.asHoursMinutesSeconds())")
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        Spacer()
                    } else if (date != nil ){
                         
                            Text("Time Remaining: \(timerVM.dayTaskTimeRemaining.asHoursMinutesSeconds())")
                                    .bold()
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                        
                    }
                    //                    if let tasks = goal.task as? Set<Task>, !tasks.isEmpty {
                    //                        ProgressView(value: goal.combinedElapsed, total: goal.overAllTimeCombined)
                    //                            .frame(width: 50, height: 10)
                    //                            .tint(Color.accentColor)
                    //                            .clipShape(Capsule())
                    //
                    //                        Text(" \(Int(goal.percentComplete))%")
                    //
                    //                            .foregroundColor(.black)
                    //                    }
                    if let goal = goal {
                        if goal.overAllTimeCombined > 0 {
                            
                            
                            ProgressView(value: goal.combinedElapsed, total: goal.overAllTimeCombined)
                                .frame(width: 120, height: 20)
                            Text("\(Int(goal.percentComplete))%")
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                        }
                    } else if (date == nil){
                        if timerVM.totalTaskTime > 0 {
                            
                            
                            
                            ProgressView(value: timerVM.combinedElapsedProgress, total: timerVM.totalTaskTime)
                                .frame(width: 120, height: 20)
                            Text("\(Int(timerVM.taskProgressPercent))%")
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                        }
                    } else {
                        if timerVM.dayCombinedElapsedProgress > 0 {
                            ProgressView(value: timerVM.dayCombinedElapsedProgress, total: timerVM.dayTotalTaskTime)
                                .frame(width: 120, height: 20)
                        }
                        
                        Text("\(Int(timerVM.dayTaskProgressPercent))%")
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                        
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 75, maxHeight: 75)
            .background(colorScheme == .light ? Color.white : Color(.secondarySystemBackground))
            .onAppear {
//                path.removeAll()
//                taskVM.fetchTasks()
                if let date = date {
                    timerVM.beginProgressUpdatesDate(date: date, tasks: displayedTasks)
//                    timerVM.ElapsedTimeForTasks(allTasks: displayedTasks)
                }
             
//                vm.startSharedUITimer()
//                vm.beginProgressUpdates(for: Date())
                
//                  vm.fetchTasks()
//                  vm.fetchGoals()
//                  vm.startSharedUITimer()
                  
                    
            }
            .onChange(of: goal?.combinedElapsed) {
                
                
                }
            .onChange(of: displayedTasks) {
                if let date = date {
                    timerVM.beginProgressUpdatesDate(date: date, tasks: displayedTasks)
                    //                    timerVM.
                    
                }
                if let goal = goal {
                    goalVM.GoalElapsedTime(goal: goal)
                }
                
                }
        
            
        }

//    }
    
}
