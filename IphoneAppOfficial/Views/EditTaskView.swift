//
//  EditTaskView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/7/25.
//

import SwiftUI

struct EditTaskView: View {
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
    

    var body: some View {
        HStack {
            if isEditView {
                Button(action: {
                    taskToDelete = task
                    showDeleteConfirmation = true
                }) {
                    Image(systemName: "minus")
                        .foregroundStyle(.red)
                        .frame(width: 20, height: 20)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .font(.body.bold())
                .padding(.leading)
                .alert("Are you sure you want to delete this task?", isPresented: $showDeleteConfirmation) {
                    if let task = taskToDelete {
                        if task.repeating {
                            Button("Delete this task", role: .destructive) {
                                taskVM.deleteTask(task)
                                isEditView = false
                                if let goal = goal {
                                    goalVM.GoalElapsedTime(goal: goal)
                                }
                               
                                
                            }
                            Button("Delete all tasks with title: \(task.title ?? "")", role: .destructive) {
                                taskVM.deleteMultipleTasks(task: task)
                                isEditView = false
                                if let goal = goal {
                                    goalVM.GoalElapsedTime(goal: goal)
                                }
                               
                            }
                        } else {
                            Button("Delete \(task.title ?? "no title")", role: .destructive) {
                                taskVM.deleteTask(task)
                                if let goal = goal {
                                    goalVM.GoalElapsedTime(goal: goal)
                                }
                                isEditView = false
//                                displayedTasks = taskVM.sortedTasksAll(allTasks: displayedTasks, option: selectedSort)
                                
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        isEditView = false
                    }
                }
            }

            // Your actual Task card UI (or another subview)
        }
        
    }
}

//
//#Preview {
//    EditTaskView()
//}
