//
//  EditTaskView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/7/25.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var date: Date?
    @State var goal: Goal?
    @ObservedObject var task: Task
    @Binding var isEditView: Bool
    @Binding var taskToDelete: Task?
    @Binding var showDeleteConfirmation: Bool
    @Binding var selectedSort: TaskSortOption
    //    @Binding var displayedTasks: [Task]
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var goalVM: GoalViewModel
    @State private var showFinalDeleteConfirmation = false
    
    var body: some View {
        HStack {
            if isEditView {
                Button(action: {
                    taskToDelete = task
                    showDeleteConfirmation = true
                }) {
                    Image(systemName: "minus")
                        .foregroundStyle(.red)
                        .frame(width: 30, height: 30)
                        .background(colorScheme == .dark ? .gray.opacity(0.20) : .white)
                        .clipShape(Circle())
                }
                .font(.body.bold())
                .padding(.leading)
                .alert("Are you sure you want to delete this task?", isPresented: $showDeleteConfirmation) {
                    if let task = taskToDelete {
                        if task.repeating {
                            Button("Delete this task", role: .destructive) {
                                if let date = date {
                                    taskVM.deleteTaskForDate(date: date, task: taskToDelete ?? task)
                                    
                                } else if let goal = goal {
                                    taskVM.deleteTaskForGoal(goal: goal, task: taskToDelete ?? task)
                                    goalVM.GoalElapsedTime(goal: goal)
                                } else {
                                    taskVM.deleteTask(task)
                                }
                                
                                
                                
                                
                            }
                            Button("Delete all repeating tasks: \(taskToDelete?.title ?? "")", role: .destructive) {
                                
                                showFinalDeleteConfirmation = true
                   
                            }
                        } else {
                            Button("Delete: \(taskToDelete?.title ?? "no title")", role: .destructive) {
                                if let date = date {
                                    taskVM.deleteTaskForDate(date: date, task: taskToDelete ?? task)
                                } else {
                                    taskVM.deleteTask(taskToDelete ?? task)
                                }
                                if let goal = goal {
                                    goalVM.GoalElapsedTime(goal: goal)
                                    taskVM.fetchTasks(for: goal)
                                }
                                
                                //                                displayedTasks = taskVM.sortedTasksAll(allTasks: displayedTasks, option: selectedSort)
                                
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        isEditView = false
                    }
                }
                .alert("Are you absolutely sure? All repeating tasks \(taskToDelete?.title ?? "no title")in storage will be permanently deleted.", isPresented: $showFinalDeleteConfirmation) {
                    Button("Yes, Delete All Repeating Tasks", role: .destructive) {
                        // Now actually delete
                        if let date = date {
                            taskVM.deleteRepeatingTasks(date: date, task: taskToDelete ?? task)
                        } else if let goal = goal {
                            taskVM.deleteRepeatingTasks(goal: goal, task: taskToDelete ?? task)
                            goalVM.GoalElapsedTime(goal: goal)
                            
                        } else {
                            taskVM.deleteRepeatingTasks(task: taskToDelete ?? task)
                        }
                        
                        
                        
                      
                    }
                    Button("Cancel", role: .cancel) {
                        isEditView = false
                    }
                }
                
                // Your actual Task card UI (or another subview)
            }
            
        }
    }
}

//
//#Preview {
//    EditTaskView()
//}
