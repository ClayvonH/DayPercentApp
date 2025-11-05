//
//  LightDarkMode.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 9/27/25.
//
import SwiftUI
import CoreData

    struct LightDarkMode: View {
        @Binding var appearance: Appearance
        @ObservedObject var taskVM: TaskViewModel
        @ObservedObject var goalVM: GoalViewModel
        @State private var showDeleteAllTasksAlert: Bool = false
        var body: some View {
         
            VStack {
                
               Text("Settings")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                    .padding(.bottom, 20)
                   
                VStack {
             
                    VStack {
                        Text("Light Mode / Dark Mode")
                            .font(.title3)
                            .bold()
                        HStack {
                            ForEach(Appearance.allCases) { option in
                                Button {
                                    appearance = option
                                } label: {
                                    Label(option.rawValue.capitalized, systemImage: option.iconName)
                                        .bold()
                                        .font(.headline)
                                        .padding()
                                }
                            }
                        }
                    }
                   
                }
//                Button(action: {
//               
//                        showDeleteAllTasksAlert = true
//                   
//                    
//                }, label: {
//         
//                        Text("Delete All Tasks")
//                        .foregroundColor(.red)
//                        .bold()
//                        .font(.title3)
//                        .padding()
//                })
//                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .transaction { $0.disablesAnimations = true } // prevents flicker
            .alert("This will delete ALL NON GOAL TASKS stored in app.  Tasks will be permanently deleted.  Are you sure?", isPresented: $showDeleteAllTasksAlert) {
                
                Button(action: {
//                    goalVM.deleteAllGoalsTasks(goals: goalVM.savedGoals)
                    taskVM.deleteAllTasksWithoutGoals()
//                    goalVM.resetAllGoalsInfo()
                    
                    
                }, label: {
                    Text("Delete All Tasks")
                        .foregroundColor(.red)
                })
                
                Button("Cancel", role: .cancel) {
                    showDeleteAllTasksAlert = false
        
                }
            }
            .onAppear {
                goalVM.fetchGoals()
             
            }
        }
    }


extension Appearance {
    var iconName: String {
        switch self {
        case .system: return "gearshape"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}
//
//var body: some View {
//    Menu {
//        ForEach(TaskSortOption.allCases) { option in
//            Button(action: {
//               
//                selectedSort = option
//                
//                
//            
//            }) {
//                Text(option.rawValue).bold()
//            }
//        }
//    } label: {
//        Text("Sort")
//            .padding(.trailing, 30)
//            .padding(.top, 20)
//    }
//    .transaction { $0.disablesAnimations = true }
//}
