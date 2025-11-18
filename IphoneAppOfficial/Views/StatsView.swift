//
//  StatsView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 11/5/25.
//

import SwiftUI
import CoreData

struct StatsView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var goalVM: GoalViewModel

    
    @State private var isEditView = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteAllTasksConfirmation = false
    @State private var taskToDelete: AppTask? = nil
    @State private var currentYear: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var currentWeek: Date = Date()
    @State private var monthView: Bool = false
    @State private var weekView: Bool = false
    @State private var showMonthViewAlert: Bool = false
    @State private var selectedSort: GoalSortOption = .recent
    @State private var period: String = "week"
    @State private var showDateOnly = false
    
    var displayedTasks: [AppTask] {
        taskVM.savedTasks
    }
    
    var displayedGoals: [Goal] {
        goalVM.sortedGoals(goals: goalVM.savedGoals, option: selectedSort)
     
    }
    
    var currentPeriodDate: Date {
        switch period.lowercased() {
        case "year":
            return currentYear
        case "month":
            return currentMonth
        case "week":
            return currentWeek
        default:
            return Date()
        }
    }

    var currentPeriodText: String {
        let formatter = DateFormatter()
//        let calendar = Calendar.current
        switch period {
        case "year":
            formatter.dateFormat = "yyyy"
            return formatter.string(from: currentYear)
        case "month":
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentMonth)
        case "week":
            var calendar = Calendar.current
            calendar.firstWeekday = 2 // Monday = 2
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentWeek)) ?? Date()
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? Date()
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
        default:
            return ""
        }
    }



    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Text("Stats")
                    .font(.largeTitle)
                    .bold()
                
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            
            HStack {
                Spacer()
                        Button(action: {
                            let calendar = Calendar.current
                            if period == "year" {
                                currentYear = calendar.date(byAdding: .year, value: -1 , to: currentYear) ?? currentYear
                                taskVM.fetchTasks(year: currentYear)
                            } else if period == "month" {
                                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                                         taskVM.fetchTasks(month: currentMonth)
                            } else if period == "week" {
                                currentWeek = calendar.date(byAdding: .day, value: -7, to: currentWeek) ?? currentWeek
                                           taskVM.fetchTasks(week: currentWeek)
                            }
                            
                        }) {
                            Image(systemName: "chevron.left")
                                .padding()
                        }
                            .font(.title3)
                            .bold()
//                            .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                VStack {
                    HStack {
                        
                        Button {
                            showDateOnly.toggle()
                        } label: {
                            Text(period.capitalized)
                                .font(.title2)
                            
                            Text(currentPeriodText)
                                .font(.title2)
                            
                        }
                        
                        
                        
                    }
                    
                    
                    if showDateOnly {
                        HStack {
                            
                            Text("Select Date")
                                .padding(.trailing)
                            DatePicker(
                                "Select Date",
                                selection: $currentWeek,
                                displayedComponents: [.date]
                                
                            )
                            .datePickerStyle(.compact) // rectangular field only
                            .labelsHidden()
                            
                        }
                        //                    .frame(maxWidth: .infinity)
                    }
                    //                .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Spacer()

                        Button(action: {   let calendar = Calendar.current
                            if period == "year" {
                                currentYear = calendar.date(byAdding: .year, value: 1 , to: currentYear) ?? currentYear
                                taskVM.fetchTasks(year: currentYear)
                            } else if period == "month" {
                                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                                         taskVM.fetchTasks(month: currentMonth)
                            } else if period == "week" {
                                currentWeek = calendar.date(byAdding: .day, value: 7, to: currentWeek) ?? currentWeek
                                           taskVM.fetchTasks(week: currentWeek)
                            }}) {
                            Image(systemName: "chevron.right")
                                .padding()
                        }
                            .font(.title3)
                            .bold()
//                            .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
                    }
            .frame(maxWidth: .infinity, alignment: .center)
            
            HStack {
                
                Button(action: {
                    period = "year"
                    taskVM.fetchTasks(year: currentYear)
                }) {
                    if period == "year" {
                        Text("Yearly")
                            .font(.headline)
                            .bold()
                    } else {
                    
                        Text("Yearly")
                            .font(.headline)
                        
                    }
                
                    
                }
                Button(action: {
                    period = "month"
                    taskVM.fetchTasks(month: currentMonth)
                }) {
                    if period == "month" {
                        Text("Monthly")
                            .font(.headline)
                            .bold()
                        
                    } else {
                        Text("Monthly")
                            .font(.headline)
                            
                    }
                }
                
                Button(action: {
                    period = "week"
                    taskVM.fetchTasks(week: currentWeek)
                }) {
                    if period == "week" {
                        Text("Weekly")
                            .font(.headline)
                            .bold()
                    } else {
                        Text("Weekly")
                            .font(.headline)
                        
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
    
         
            ScrollView(.vertical) {
                
//
//                HStack {
//                    Text("Goals")
//                        .font(.largeTitle)
//                        .bold()
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
            
                VStack {
                    HStack {
                        Text("Time Invested \(period.capitalized) Tasks:")
                            .bold()
                        Text("\(timerVM.combinedElapsedProgress.asHoursMinutesSecondsWithLabels())")
                        
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    
                    HStack {
                        Text("Time Remaining \(period.capitalized) Tasks:")
                            .bold()
                        Text("\(timerVM.taskTimeRemaining.asHoursMinutesSecondsWithLabels())")
//                            .bold()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }

                    
                    HStack {
                        Text("Past Due Tasks:")
                            .bold()
                        if taskVM.getIncompleteTasksCount(tasks: displayedTasks) > 0 {
                            
                            NavigationLink(destination: PastDueView(taskVM: taskVM, goalVM: goalVM, timerVM: timerVM)) {
                                Text("\(taskVM.getIncompleteTasksCount(tasks: displayedTasks))")
                                    .bold()
                                         .foregroundColor(.white)
                                         .padding(4)
                                         .background(Color.red)
                                         .clipShape(Circle())
                                    
                            }
                        } else {
                            Text("\(taskVM.getIncompleteTasksCount(tasks: displayedTasks))")
//                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    
                    HStack {
                        Text("Completed Tasks:")
                            .bold()
                        Text("\(taskVM.getCompletedTasks(tasks: displayedTasks))")
//                            .bold()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                HStack {
                    GoalSortView(selectedSort: $selectedSort)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
                    ForEach(displayedGoals) {
                        goal in
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("\(goal.title ?? "No Title")")
                                    .font(.title3)
                                    .bold()
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            HStack {
                                Text("Due:")
                                    .bold()
                                
                                Text("\(goal.dateDue ?? Date(), style: .date)")
                                
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            
                        
                        HStack {
                            Text("Total Time Invested:")
                                .bold()
                            
                            Text("\(goalVM.goalElapsedTimeToggle(goal: goal, period: period, date: currentPeriodDate).asHoursMinutesSecondsWithLabels())")
                            
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                            
                            HStack {
                                
                                Text("Time Remaining:")
                                    .bold()
                                
                                //                        Text("\(goal.estimatedTimeRemaining.asHoursMinutesSecondsWithLabels())")
                                Text("\(goalVM.goalTimeRemaining(goal: goal, period: period, date: currentPeriodDate).asHoursMinutesSecondsWithLabels())")
                                
                            }
                        
                        HStack {
                            Text("Past Due Tasks:")
                                .bold()
                            
                            if goalVM.pastDueGoalTasks(goal: goal) > 0 {
                                
                                NavigationLink(destination: PastDueView(taskVM: taskVM, goalVM: goalVM, timerVM: timerVM, goal: goal)) {
                                    Text("\(goalVM.pastDueGoalTasks(goal: goal))")
                                        .bold()
                                             .foregroundColor(.white)
                                             .padding(4)
                                             .background(Color.red)
                                             .clipShape(Circle())
                                }
                                   
                                   
                            } else {
                                
                                Text("\(goalVM.pastDueGoalTasks(goal: goal))")
//                                    .bold()
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                        }
                        
                     
                      
                            
                        HStack {
                            Text("Total Completed:")
                                .bold()
                            
                            Text("\(goalVM.goalCompletedTasks(goal: goal, period: period, date: currentPeriodDate))/\(goalVM.goalTotalTasks(goal: goal, period: period, date: currentPeriodDate))")
                            
//                            Text("\(goalVM.getCompletedTasks(goal: goal, period: period, date: Date()))/\(goal.taskCount)")
                         
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        
                        
                        
                        
                        // Filter tasks that belong to the current goal
                        let tasksForGoal = displayedTasks.filter { $0.goal == goal }
                        
                        // Group these tasks by title
                        let groupedTasks = Dictionary(grouping: tasksForGoal) { $0.title ?? "Untitled" }
                        
                        
                        // Now loop once per title
                            
                            if goal.taskCount > 0 {
                                
                                HStack {
                                    Text("Tasks")
                                        .font(.title2)
                                        .bold()
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                
                                ForEach(groupedTasks.keys.sorted(), id: \.self) { title in
                                    
                                    
                                    if let sameTitleTasks = groupedTasks[title] {
                                        
                                        
                                        
                                        // Calculate total elapsed time for this title
                                        let totalElapsed = sameTitleTasks.reduce(0.0) { sum, task in
                                            var elapsed = 0.0
                                            if let timer = task.timer {
                                                elapsed += timer.elapsedTime
                                            }
                                            if let quantity = task.quantityval {
                                                elapsed += quantity.timeElapsed
                                            }
                                            return sum + elapsed
                                        }
                                        
                                        HStack {
                                            if totalElapsed == 0.0 {
                                                Text("-")
                                                Text("\(title): No Timer Data")
                                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                            } else {
                                                
                                                Text("-")
                                                Text("\(title):")
                                                    .font(.headline)
                                                
                                                
                                                Text(totalElapsed.asHoursMinutesSecondsWithLabels())
                                                //                                                .bold()
                                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                            }
                                        }
                                        .padding(.bottom, 5)
                                        
                                    }
                                    
                                }
                            }
                        
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color.gray.opacity(0.25) : Color.white)
                        
                        
                        
                    }
                // Filter tasks that do not belong to any goal
                
                let nonGoalTasks = displayedTasks.filter { $0.goal == nil }

                if !nonGoalTasks.isEmpty {
                    // Move these OUTSIDE the VStack 👇
                    let groupedTasks = Dictionary(grouping: nonGoalTasks) { $0.title ?? "Untitled" }

                    let totalElapsed = nonGoalTasks.reduce(0.0) { sum, task in
                        var elapsed = 0.0
                        if let timer = task.timer {
                            elapsed += timer.elapsedTime
                        }
                        if let quantity = task.quantityval {
                            elapsed += quantity.timeElapsed
                        }
                        return sum + elapsed
                    }

                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Non-Goal Tasks")
                                .font(.title2)
                                .bold()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)

                        HStack {
                            Text("Total Time Invested:")
                                .bold()
                            Text(totalElapsed.asHoursMinutesSecondsWithLabels())
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }

                        ForEach(groupedTasks.keys.sorted(), id: \.self) { title in
                            if let sameTitleTasks = groupedTasks[title] {
                                let taskElapsed = sameTitleTasks.reduce(0.0) { sum, task in
                                    var elapsed = 0.0
                                    if let timer = task.timer {
                                        elapsed += timer.elapsedTime
                                    }
                                    if let quantity = task.quantityval {
                                        elapsed += quantity.timeElapsed
                                    }
                                    return sum + elapsed
                                }

                                HStack {
                                    if taskElapsed == 0.0 {
                                        Text("-")
                                        Text("\(title):")
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            .bold()
                                        Text("No Timer Data")
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    } else {
                                        Text("-")
                                        Text("\(title):")
                                            .font(.headline)
                                        Text(taskElapsed.asHoursMinutesSecondsWithLabels())
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    }
                                }
                                .padding(.bottom, 5)
                            }
                        }
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.gray.opacity(0.25) : Color.white)
                }


                
            }
            .padding(.horizontal, 10)
            
        }
        .background(colorScheme == .dark ? .black.opacity(0.10) : .gray.opacity(0.15))
//        .padding(.horizontal, 10)
        .onAppear {
            goalVM.fetchGoals()
            goalVM.goalElapsedTimeAll(goals: goalVM.savedGoals)
//            goalVM.lastActive(goals: goalVM.savedGoals)
            
            if period == "year" {
                taskVM.fetchTasks(year: currentYear)
            } else if period == "month" {
                taskVM.fetchTasks(month: currentMonth)
            } else if period == "week" {
                taskVM.fetchTasks(week: currentWeek)
            }
          
            timerVM.updateAllRunningTaskTimers()
            timerVM.setAllTimerVals()
            timerVM.beginProgressUpdates(for: Date())
            //                timerVM.countDownTimer(task: taskVM.newTask, seconds: 10, minutes: 1, hours: 0)
            //                displayedTasks = taskVM.sortedTasksAll(allTasks: taskVM.savedTasks, option: selectedSort)
        }
        .onChange(of: currentWeek) {
            currentYear = currentWeek
            currentMonth = currentWeek
            if period == "week" {
                taskVM.fetchTasks(week: currentWeek)
            } else if period == "month" {
                taskVM.fetchTasks(month: currentWeek)
            } else if period == "year" {
                taskVM.fetchTasks(year: currentWeek)
            }
        }
    }
}

//#Preview {
//    StatsView()
//}
