//
//  CreateTaskView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/2/25.
//

//
//  CreateTaskSheet.swift
//  LazyVGridPractice
//
//  Created by Clayvon Hatton on 6/15/25.
//


import SwiftUI
import CoreData

struct CreateTaskView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State var newTask: Task?
//    @ObservedObject var task: Task
    @State var goal: Goal?
    @State var date: Date?
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var goalVM: GoalViewModel
    @ObservedObject var timerVM: TimerViewModel
    @State private var taskTitle: String = ""
    @State private var selectedDate: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    

    @State private var timeBased: Bool = true
    @State var seconds:  Double = 0
    @State var minutes: Double = 0
    @State var hours: Double = 0
    @State private var titleEnter: Bool = false
    
    @State private var repeatingTasks: Bool = false
  
    @State private var selectedWeekdays: Set<Weekday> = []
    @State private var selectedEndDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    @State private var generatedDates: [Date] = []

    
    @State private var showTimerSelectView = false
    @FocusState private var titleIsFocused: Bool
    @State private var showEmptyTitleAlert = false
    
    @State private var showSheet = false
    @State private var showDateAndTimer = false
    @State private var showDateOnly = false
    @State private var dateOnly = false

    
    func toggle(_ day: Weekday) {
        if selectedWeekdays.contains(day) {
            selectedWeekdays.remove(day)
        } else {
            selectedWeekdays.insert(day)
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        if showTimerSelectView == false {
        ScrollView {
            
           
                
                VStack (alignment: .leading){
                    HStack {
                        Text("Create Task")
                            .font(.largeTitle)
                            .bold()
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom,10)
                    .padding(.top,10)
                    if let goal = goal {
                        Text("For: \(goal.title ?? "")")
                            .font(.title)
                            .bold()
                            .padding(.bottom)
                        
                    }
                    
                    if let date = date {
                        Text("Tasks For \(formatDate(date))")
                            .font(.title)
                            .bold()
                            .padding(.bottom)
                        
                    }
                    
                    Text("Task Title")
                        .font(.title)
                        .bold()
                    
                    HStack {
                        TextField("Enter task Title", text: $taskTitle)
                            .padding(.leading)
                            .frame(maxWidth: titleIsFocused ? 320 : 395, minHeight: 44)
                            .font(.title)
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                            .focused($titleIsFocused)
                        
                        if titleIsFocused {
                            Button("Done") {
                                titleIsFocused = false // This dismisses the keyboard
                            }
                            .padding(.trailing, 5)
                            .transition(.opacity)
                            .animation(.easeInOut, value: titleIsFocused)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    
                    
                    
                    
                    Button(action: {
                        repeatingTasks.toggle()
                    }, label: {
                        Text("Repeats")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                        
                    }
                    )
                    .frame(width: 350,height: 40)
                    .foregroundStyle(.white)
                    .background(Color(.blue))
                    .cornerRadius(15)
                    .padding(.leading, 9)
                    .padding(.top, 13)
                    
                    if repeatingTasks {
                        HStack {
                            Spacer()
                            Text("Every")
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        .padding(.bottom, 10)
                        HStack {
                            Spacer()
                            ForEach(Weekday.allCases) { day in
                                Spacer()
                                Button {
                                    toggle(day)
                                } label: {
                                    HStack {
                                        
                                        
                                        if selectedWeekdays.contains(day) {
                                            Text(day.name)
                                                .foregroundColor(.red)
                                        } else {
                                            Text(day.name)
                                                
                                        }
                                        
                                        
                                    }
                                    //                            .padding()
                                    //                            .background(Color.blue.opacity(0.1))
                                    //                            .cornerRadius(8)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, 10)
                        .padding(.bottom, 3)
                        Text("Until")
                            .font(.title)
                            .bold()
                        
                    }
                    
                    Text("Scheduled Date")
                        .font(.title)
                        .bold()
                        .padding(.trailing, 10)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            showDateAndTimer.toggle()
                            showDateOnly = false
                            dateOnly = false
                            
                        }, label: {
                            Text("Date & Time")
                                .contentShape(Rectangle())
                        })
                        .frame(width: 150,height: 35)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        
                        Text("Or")
                        
                        Button(action: {
                            showDateOnly.toggle()
                            showDateAndTimer = false
                            dateOnly = true
                        }, label: {
                            Text("Date Only")
                                .contentShape(Rectangle())
                        })
                        .frame(width: 150,height: 35)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        
                       Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    if showDateAndTimer {
                        
                        DatePicker("Select Date", selection: $selectedDate)
                            .padding(.horizontal)
                            .onTapGesture {
                                titleIsFocused = false
                            }
                    }
                    
                    
                    if showDateOnly {
                        HStack {
                            Spacer()
                            Text("Select Date")
                                .padding(.trailing)
                            DatePicker(
                                "Select Date",
                                selection: $selectedDate,
                                displayedComponents: [.date] // only date, no time
                            )
                            .datePickerStyle(.compact) // rectangular field only
                            .labelsHidden()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }
                  
                    
                    Button(action: {
                        
                        guard !taskTitle.isEmpty else {
                            showEmptyTitleAlert = true
                            return
                        }
                        
                        if selectedWeekdays.isEmpty {repeatingTasks = false}
                        
                        if let goal = goal {
                            if repeatingTasks == false {
                                let task = goalVM.addTaskToGoalTwo(goalr: goal, title: taskTitle, dueDate: selectedDate, dateOnly: dateOnly)
                                newTask = task
                                showTimerSelectView = true
                            } else {
                                let newDates = taskVM.generateDates(for: selectedWeekdays, until: selectedDate, usingTimeFrom: selectedDate)
                                
                                let task = goalVM.addTaskToGoalTwo(goalr: goal, title: taskTitle, dueDate: selectedDate)
                                taskVM.repeatingTrue(task: task)
                                taskVM.repeatTask(task: task, dates: newDates)
                                newTask = task
                                
                                
                                showTimerSelectView = true
                            }
                        } else {
                            if repeatingTasks == false {
                                let task = taskVM.createTaskAndReturn(title: taskTitle, dueDate: selectedDate, dateOnly: dateOnly)
                                newTask = task
                                showTimerSelectView = true
                            } else {
                                let newDates = taskVM.generateDates(for: selectedWeekdays, until: selectedDate, usingTimeFrom: selectedDate)
                                
                                let task = taskVM.createTaskAndReturn(title: taskTitle, dueDate: selectedDate, dateOnly: dateOnly)
                                taskVM.repeatingTrue(task: task)
                                taskVM.repeatTask(task: task, dates: newDates)
                                newTask = task
                                
                                
                                showTimerSelectView = true
                            }
                            
                        }
                    }, label: {
                        
                        Text("CREATE TASK")
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
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                                .contentShape(Rectangle())
                        })
                        .frame(width: 150,height: 40)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.4) : Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        
                        .padding(.top)
                        Spacer()
                    }
                    
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 30)
          
                
                .padding(.horizontal, 20)
                
                //            .navigationDestination(isPresented: $showTimerSelectView) {
                //
                //                TimerSelectView(taskVM: taskVM, goalVM: goalVM, timerVM: timerVM, goal: goal, task: newTask ?? Task())
                //
                //            }
                //            .sheet(isPresented: $showTimerSelectView) {
                //                TimerSelectView(
                //                    taskVM: taskVM,
                //                    goalVM: goalVM,
                //                    timerVM: timerVM,
                //                    goal: goal,
                //                    task: newTask ?? Task()
                //                )
                //            }
                
                .alert("Please enter a task title", isPresented: $showEmptyTitleAlert) {
                    Button("OK", role: .cancel) { }
                }
            }
        .background(colorScheme == .dark ? .gray.opacity(0.15) : .gray.opacity(0.15))
        .navigationBarHidden(true)
            
        } else {
            
            
            TimerSelectView(
                taskVM: taskVM,
                goalVM: goalVM,
                timerVM: timerVM,
                goal: goal,
                task: newTask ?? Task()
            )
        
    }

        
        
        
    }
       


        

}

#Preview {
//    let context = PersistenceController.preview.container.viewContext
//    let sampleGoal = Goal(context: context)
//    sampleGoal.title = "Sample Goal"
//    
//    return CreateTaskView(
//        goal: sampleGoal,
//        vm: CreateGoalViewModelTwo())
//    
}

