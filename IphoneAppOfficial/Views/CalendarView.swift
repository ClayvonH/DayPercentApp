//
//  CalendarView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/19/25.


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
    
    private func determineColor(for date: Date) -> Color {
        if calendar.isDateInToday(date) {
            return .blue
        } else if goalVM.savedGoals.contains(where: {
            guard let goalDate = $0.dateDue else { return false }
            return calendar.isDate(goalDate, inSameDayAs: date)
        }) {
            return .green
        } else if taskVM.savedTasks.contains(where: {
            guard let taskDate = $0.dateDue else { return false }
            return calendar.isDate(taskDate, inSameDayAs: date)
        }) {
            return .red
        } else {
            if colorScheme == .dark {
                return .white.opacity(0.8)
            } else {
                return .black
            }
        }
    }

    var body: some View {
        VStack {
            
            monthNavigation
            monthPicker
            calendarGrid
            dateColors
        }
        .padding(.top, 30)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(colorScheme == .dark ? .gray.opacity(0.15) : .white)
        .onAppear {
            
            taskVM.fetchTasks(month: displayedMonth)
            goalVM.fetchGoals()
        }
        .onChange(of: displayedMonth) {
            taskVM.fetchTasks(month: displayedMonth)
        }
        
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
    
    
    struct MonthYearPickerView: View {
        
        @Environment(\.colorScheme) var colorScheme
        @Binding var selectedMonth: Int
        @Binding var selectedYear: Int

        let months = Calendar.current.monthSymbols
        let years = Array(2020...2045)

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

    private var calendarGrid: some View {
        VStack {
            // Weekday labels
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol.prefix(3)) // e.g. "Sun", "Mon"
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days of the month
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(paddedMonthDates, id: \.self) { date in
                    if let date = date {
                        NavigationLink(destination: LazyView(DateView(
                            date: date,
                            taskVM: taskVM,
                            goalVM: goalVM,
                            timerVM: timerVM
                        ))) {
                            Text("\(calendar.component(.day, from: date))")
                                .foregroundColor(determineColor(for: date))
                                .frame(width: 40, height: 60)
                                .bold()
                                .clipShape(Circle())
                        }
                    } else {
                        // Empty slot for padding
                        Text("")
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .onAppear {
                updateDisplayedMonth()
            }
            .padding()
        }
        .padding(.top)
    }
    
    

    private var paddedMonthDates: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        // Day of week offset (0 = Sunday, 6 = Saturday)
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)

        // Padding before the 1st
        let padding = Array(repeating: nil as Date?, count: firstWeekday - 1)

        // Actual days of the month
        let days = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }

        return padding + days
    }

    private var dateColors: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                Text("Tasks Due")
                    .padding(.trailing, 4)
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                Text("Goal Due")
            }
         
            HStack {
                Circle()
                    .fill(colorScheme == .light ? Color.black : Color.white)
                    .frame(width: 12, height: 12)
                Text("No Tasks")
                    .padding(.trailing, 4)
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                Text("Current Day")
            }
      
        }
        .font(.subheadline) // smaller text for legend
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

