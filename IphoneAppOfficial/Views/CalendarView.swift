////
////  CalendarView.swift
////  IphoneAppOfficial
////
////  Created by Clayvon Hatton on 8/19/25.
////
//
//
//import SwiftUI
//
//struct CalendarView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @ObservedObject var taskVM: TaskViewModel
//    @ObservedObject var timerVM: TimerViewModel
//    @ObservedObject var goalVM: GoalViewModel
//    @State private var selectedDate: Date? = nil
//
//    @State private var newGoalTitle: String = ""
//    @State private var newDate: Date = Date()
//
//    @State private var displayedMonth: Date = Date()
//
//    @State private var selectedMonth = Calendar.current.component(.month, from: Date()) - 1
//    @State private var selectedYear = Calendar.current.component(.year, from: Date())
//
//    @State private var showSelectMonth: Bool = false
//
//    private let calendar = Calendar.current
//
//    var body: some View {
//            VStack {
//
////                Text("Calendar")
////                    .font(.largeTitle)
////                    .padding()
//
//                // Month navigation buttons
//                HStack {
//                    Button(action: {
//                        if let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
//                            displayedMonth = newMonth
//                        }
//                    }) {
//                        Image(systemName: "chevron.left")
//                    }
//
//                    Text(displayedMonthFormatted)
//                        .font(.title)
//                        .fontDesign(.serif)
//                        .padding(.horizontal)
//
//                    Button(action: {
//                        if let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
//                            displayedMonth = newMonth
//                        }
//                    }) {
//                        Image(systemName: "chevron.right")
//                    }
//                }
//                .padding(.vertical)
//
//                Button(action: {
//                    self.showSelectMonth.toggle() } ) {
//
//                        if showSelectMonth {
//                            Text("CLOSE")
//                        } else {
//                            Text("Select Month")
//                        }
//                    }
//                if showSelectMonth {
//                    MonthYearPickerView(selectedMonth: $selectedMonth, selectedYear: $selectedYear)
//                        .onChange(of: selectedMonth) { oldValue, newValue in
//                            updateDisplayedMonth()
//                        }
//                        .onChange(of: selectedYear) { oldValue, newValue in
//                            updateDisplayedMonth()
//                        }
//
//                }
//
//                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
//                    ForEach(currentMonthDates, id: \.self) { date in
//                        NavigationLink(destination: {
//                            if goalVM.savedGoals.first(where: {
//                                guard let goalDate = $0.date else { return false }
//                                return calendar.isDate(goalDate, inSameDayAs: date)
//                            }) != nil {
//                                DateView(date: date, taskVM: taskVM, goalVM: goalVM, timerVM: timerVM)
//                            } else if taskVM.savedTasks.first(where: {
//                                guard let taskDate = $0.dateDue else { return false }
//                                return calendar.isDate(taskDate, inSameDayAs: date)
//                            }) != nil {
//                                DateView(date: date, taskVM: taskVM, goalVM: goalVM, timerVM: timerVM)
//                            } else {
//                                DateView(date: date, taskVM: taskVM, goalVM: goalVM, timerVM: timerVM)
//                            }
//                        }) {
//                            Text("\(calendar.component(.day, from: date))")
//                                .fontWeight(.bold)
//                                .foregroundColor(determineColor(for: date))
//                                .frame(width: 40, height: 80)
//                                .background(isSelected(date) ? Color.yellow : Color.clear)
//                                .clipShape(Circle())
//                        }
//                    }
//                }
//                .padding()
//            }
//            .padding(.top, 30)
//            .frame(maxHeight: .infinity, alignment: .top)
//            .background(colorScheme == .dark ? Color.gray.opacity(0.11) : Color.white)
//            
//        
//    }
//
//    private var currentMonthDates: [Date] {
//        generateDates(for: displayedMonth)
//    }
//
//    private var displayedMonthFormatted: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "LLLL yyyy"
//        return formatter.string(from: displayedMonth)
//    }
//
//    private func isSelected(_ date: Date) -> Bool {
//        if let selectedDate = selectedDate {
//            return calendar.isDate(date, inSameDayAs: selectedDate)
//        }
//        return false
//    }
//
//    private func determineColor(for date: Date) -> Color {
//        if calendar.isDateInToday(date) {
//            return .blue
//        } else if isSelected(date) {
//            return .red
//        } else if goalVM.savedGoals.contains(where: {
//            guard let goalDate = $0.date else { return false }
//            return calendar.isDate(goalDate, inSameDayAs: date)
//        }) {
//            return .green
//        } else if taskVM.savedTasks.contains(where: {
//            guard let taskDate = $0.dateDue else { return false }
//            return calendar.isDate(taskDate, inSameDayAs: date)
//        }) {
//            return .red
//        } else {
//            if colorScheme == .dark {
//                return .white.opacity(0.8)
//            } else {
//                return .black
//            }
//        }
//    }
//
//    func generateDates(for date: Date) -> [Date] {
//        guard let range = calendar.range(of: .day, in: .month, for: date),
//              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
//            return []
//        }
//
//        return range.compactMap { day in
//            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
//        }
//    }
//
//    private func updateDisplayedMonth() {
//        var components = calendar.dateComponents([.day, .month, .year], from: Date())
//        components.month = selectedMonth + 1
//        components.year = selectedYear
//        components.day = 1
//        if let newDate = calendar.date(from: components) {
//            displayedMonth = newDate
//        }
//    }
//}
//
//
////struct GoalDetailFullScreenView: View {
////    @Environment(\.managedObjectContext) private var viewContext
////    @ObservedObject var goal: Goal
////
////    @State private var newTaskTitle: String = ""
////
////    var body: some View {
////        VStack(spacing: 20) {
////            Text(goal.title ?? "Untitled Goal")
////                .font(.title)
////                .padding()
////
////            Text("\(goal.percentComplete) Complete")
////
////            Text("Edit Goal Title")
////                .font(.headline)
////
////            TextField("Edit Goal Title", text: Binding(
////                get: { goal.title ?? "" },
////                set: { goal.title = $0 }
////            ))
////            .textFieldStyle(RoundedBorderTextFieldStyle())
////            .padding()
////
////            Button("Save Changes") {
////                saveGoal()
////            }
////            .buttonStyle(.borderedProminent)
////
////            Divider()
////
////            TextField("New Task Title", text: $newTaskTitle)
////                .textFieldStyle(RoundedBorderTextFieldStyle())
////                .padding()
////
////            Button("Add Task") {
////                addTask()
////            }
////            .buttonStyle(.borderedProminent)
////
////            Divider()
////
////            Text("Tasks:")
////                .font(.headline)
////
////            List {
////                ForEach(getTasks(), id: \.self) { task in
////                    Text(task.title ?? "Untitled Task")
////                }
////            }
////        }
////        .padding()
////        .navigationTitle("Goal Detail")
////    }
////
////    private func getTasks() -> [Task] {
////        let taskSet = goal.task as? Set<Task> ?? []
////        return taskSet.sorted { ($0.dateCreated ?? Date()) < ($1.dateCreated ?? Date()) }
////    }
////
////    private func saveGoal() {
////        do {
////            try viewContext.save()
////            print("Goal saved successfully!")
////        } catch {
////            print("Error saving goal: \(error.localizedDescription)")
////        }
////    }
////
////    private func addTask() {
////        guard !newTaskTitle.isEmpty else { return }
////
////        let newTask = Task(context: viewContext)
////        newTask.title = newTaskTitle
////        newTask.dateCreated = Date()
////        newTask.goal = goal
////
////        do {
////            try viewContext.save()
////            newTaskTitle = ""
////        } catch {
////            print("Error adding task: \(error.localizedDescription)")
////        }
////    }
////}
//
struct MonthYearPickerView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int

    let months = Calendar.current.monthSymbols
    let years = Array(2000...2040)

    var body: some View {
        HStack {
            Picker("Month", selection: $selectedMonth) {
                ForEach(0..<months.count, id: \..self) { index in
                    Text(months[index]).tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())

            Picker("Year", selection: $selectedYear) {
                           ForEach(years, id: \.self) { year in
                               Text(String(year)) // <- ensures no commas
                                   .tag(year)
                           }
                       }
                       .pickerStyle(WheelPickerStyle())
        }
        .frame(height: 150)
    }
}
////
////#Preview {
////    
////    CalPracticeVM(vm: CreateGoalViewModelTwo())
////    
////}
//
import SwiftUI

struct CalendarView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var timerVM: TimerViewModel
    @ObservedObject var goalVM: GoalViewModel
    @State private var currentDay: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var displayedMonth: Date = Date()
    @State private var selectedMonth = Calendar.current.component(.month, from: Date()) - 1
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var showSelectMonth: Bool = false

    private let calendar = Calendar.current

    var body: some View {
        VStack {
            monthNavigation
            monthPicker
            calendarGrid
        }
        .padding(.top, 30)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(colorScheme == .dark ? .gray.opacity(0.15) : .white)
        
    }

    private var monthNavigation: some View {
        HStack {
            Button(action: { changeMonth(by: -1) }) { Image(systemName: "chevron.left") }
            Text(displayedMonthFormatted)
                .font(.title)
                .padding(.horizontal)
            Button(action: { changeMonth(by: 1) }) { Image(systemName: "chevron.right") }
        }
        .padding(.vertical)
    }

    private var monthPicker: some View {
        VStack {
            Button(action: { showSelectMonth.toggle() }) {
                Text(showSelectMonth ? "CLOSE" : "Select Month")
            }
            if showSelectMonth {
                MonthYearPickerView(selectedMonth: $selectedMonth, selectedYear: $selectedYear)
                    .onChange(of: selectedMonth) {
                        updateDisplayedMonth()
                    }
                    .onChange(of: selectedYear) {
                        updateDisplayedMonth()
                    }
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(currentMonthDates, id: \.self) { date in
                NavigationLink(destination: LazyView(DateView(
                    date: date,
                    taskVM: taskVM,
                    goalVM: goalVM,
                    timerVM: timerVM
                ))) {
                    Text("\(calendar.component(.day, from: date))")
                        .fontWeight(.bold)
//                        .foregroundColor(Color.black)
                        .foregroundColor(
                                               calendar.isDateInToday(date)
                                                   ? .blue   // today
                                               : (colorScheme == .dark ? .white.opacity(0.8) : .black) // dark/light
                                           )
                        .bold(
                            calendar.isDateInToday(date) ? true : false
                            )
                        .frame(width: 40, height: 80)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
    }

    private var currentMonthDates: [Date] {
        generateDates(for: displayedMonth)
    }

    private var displayedMonthFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth)
    }

    private func generateDates(for date: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
    }

    private func changeMonth(by offset: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: offset, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func updateDisplayedMonth() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth + 1
        components.day = 1
        if let newDate = calendar.date(from: components) {
            displayedMonth = newDate
        }
    }
}

// LazyView to defer loading
struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) { self.build = build }
    var body: Content { build() }
}
