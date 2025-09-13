
//
//  TaskView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/7/25.
//


import SwiftUI
import CoreData

struct TaskView2: View {
    @ObservedObject var taskVM: TaskViewModel
    @ObservedObject var timerVM: TimerViewModel
    @State var task: Task
    @Environment(\.managedObjectContext) private var context
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isEditView = false
    @State private var showDeleteConfirmation = false
    @State private var showChangeDateSheet = true
    
    @State private var selectedDate: Date = Date()
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showCountdownAlert: Bool = false
    @State private var CDAlertMessage = ""
    
    @State private var editDate: Bool = false
    @State private var editElapsedTime: Bool = false
    @State private var editCountdownTime: Bool = false
    @State private var editTitle: Bool = false
    @State private var editTimePerVal: Bool = false
    @State private var editRepeatingTasks: Bool = false
    @State private var showSheet: Bool = false
    
    
    @State var seconds:  Double = 0
    @State var minutes: Double = 0
    @State var hours: Double = 0
    @State private var titleText: String = ""
    
    @State private var selectedWeekdays: Set<Weekday> = []
    @State private var selectedEndDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    @State private var generatedDates: [Date] = []
    @State private var repeatingTasks: Bool = false
    
    @State private var completeTaskSheet: Bool = false
    
    func toggle(_ day: Weekday) {
        if selectedWeekdays.contains(day) {
            selectedWeekdays.remove(day)
        } else {
            selectedWeekdays.insert(day)
        }
    }
    
    
    var body: some View {
        VStack {
            
            ScrollView {
                VStack(alignment: .leading, spacing: 35) {
                    
                    HStack(spacing: 7) {
                        
                        
                        
                        Text("\(task.title ?? "Untitled Task")")
                            .font(.largeTitle)
                            .fontDesign(.serif)
                            .bold()
                        
                        
                        if isEditView {
                            Button(action: {
                                editTitle.toggle()
                            } ) {
                                Text("edit")
                                    .font(.title2)
                                
                            }
                            
                        }
                        
                        
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.trailing, 15)
                    if editTitle && isEditView == true {VStack {
                        
                        TextField("Insert New Name Here", text: $titleText)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(height: 40)
                            .background(colorScheme == .dark ? .gray.opacity(0.20) : .white)
                        
                        Button(action: {
                            taskVM.updateTaskTitle(task: task, newTitle: titleText)
                            editTitle.toggle()
                            isEditView.toggle()
                        } ) {
                            Text("Change Task Name")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 10)
                            
                                .padding(.vertical, 8)
                                .frame(maxWidth: 200)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            
                        }
                    }
                        
                    }
                    
                    if let timer = task.timer  {
                        
                        
                        HStack {
                            
                            Text(timer.elapsedTime.asHoursMinutesSeconds())
                                .font(.largeTitle)
                                .fontDesign(.serif)
                                .bold()
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.trailing, 15)
                        
                        
                    }
                    
                    if let quantity = task.quantityval  {
                        
                        
                        HStack {
                            
                            Text("\(Int(quantity.currentQuantity)) / \(Int(quantity.totalQuantity))")
                                .font(.largeTitle)
                                .fontDesign(.serif)
                                .bold()
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.trailing, 15)
                        
                        
                    }
                    
                    HStack {
                        Text("Date Scheduled:")
                            .font(.title2).bold()
                        
                        if let dueDate = task.dateDue {
                            Text("\(dueDate.formatted(.dateTime.month().day().year()))  \(dueDate.formatted(.dateTime.hour().minute()))")
                                .font(.title3)
                        } else {
                            Text("N/A")
                        }

                            
                        Spacer()
                        if isEditView {
                            Button(action: {
                                editDate.toggle()
                            } ) {
                                Text("edit")
                                    .font(.title2)
                                
                            }
                            .padding(.trailing, 20)
                        }
                    }
                    .cornerRadius(10)
                    if editDate {VStack {
                        DatePicker("Select Date", selection: $selectedDate)
                            .padding(.horizontal)
                        Button(action: {
                            taskVM.addDateDueToTask(task: task, date: selectedDate)
                            editDate.toggle()
                        } ) {
                            Text("Change Due Date")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 10)
                            
                                .padding(.vertical, 8)
                                .frame(maxWidth: 200)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            
                        }
                    }
                    }
                    HStack {
                        Text("Created:")
                            .font(.title2).bold()
                        Text(task.dateCreated?.formatted(.dateTime.month().day().year()) ?? "N/A")
                            .font(.title2)
                    }
                    
                    if let timer = task.timer {
                        HStack {
                            Text("Elapsed Time:")
                                .font(.title2).bold()
                            Text(timer.elapsedTime.asHoursMinutesSeconds())
                                .font(.title2)
                            //                                .foregroundColor(
                            //                                            task.timer?.isRunning == true
                            //                                                ? .blue
                            //                                                : (colorScheme == .dark ? .white : .black)
                            //                                            )
                            //                                .fontWeight(task.timer?.isRunning == true ? .bold : .regular)
                            
                            Spacer()
                            if isEditView {
                                Button(action: {
                                    editElapsedTime.toggle()
                                } ) {
                                    Text("edit")
                                        .font(.title2)
                                    
                                    
                                    
                                }
                                .padding(.trailing, 20)
                            }
                            
                        }
                        
                        if editElapsedTime && isEditView == true {
                            VStack {
                            Text("Change Elapsed Time")
                                .font(.title3)
                                .bold()
                            HStack {
                                
                                VStack {
                                    
                                    Picker("Hours", selection: $hours, content: {
                                        Text("Hours")
                                        ForEach(0..<24, content: {
                                            number in
                                            Text("\(number)").tag(Double(number))
                                        })
                                    }).pickerStyle(WheelPickerStyle())
                                }
                                
                                VStack {
                                    Picker("Minutes", selection: $minutes, content: {
                                        Text("Minutes")
                                        ForEach(0..<60, content: {
                                            number in
                                            Text("\(number)").tag(Double(number))
                                        })
                                    }).pickerStyle(WheelPickerStyle())
                                }
                                
                                VStack {
                                    
                                    Picker("Seconds", selection: $seconds, content: {
                                        Text("Seconds")
                                        ForEach(0..<60, content: {
                                            number in
                                            Text("\(number)").tag(Double(number))
                                        })
                                    }).pickerStyle(WheelPickerStyle())
                                }
                            }
                            Button(action: {
                                let elapsedInput = (hours * 60 * 60) + (minutes * 60) + seconds
                                
                                if elapsedInput <= (task.timer?.countdownNum ?? 0) {
                                    timerVM.updateElapsedTime(task: task, seconds: seconds, minutes: minutes, hours: hours)
                                } else {
                                    alertMessage = "Elapsed time cannot be greater than the countdown value."
                                    showAlert = true
                                    
                                    
                                }
                                
                                editElapsedTime.toggle()
                            } ) {
                                Text("Change Elapsed Time")
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 10)
                                
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: 200)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                
                            }
                        }
                        }
                        
                        HStack {
                            Text("Countdown Value:")
                                .font(.title2).bold()
                            Text(timer.countdownNum.asHoursMinutesSeconds())
                                .font(.title2)
                            Spacer()
                            if isEditView {
                                Button(action: {
                                    editCountdownTime.toggle()
                                } ) {
                                    Text("edit")
                                        .font(.title2)
                                    
                                    
                                    
                                }
                                .padding(.trailing, 20)
                            }
                            
                        }
                        
                        if editCountdownTime && isEditView == true {
                            VStack {
                            Text("Change CountDown Time")
                                .font(.title3)
                                .bold()
                            HStack {
                                
                                VStack {
                                    
                                    Picker("Hours", selection: $hours, content: {
                                        Text("Hours")
                                        ForEach(0..<24, content: {
                                            number in
                                            Text("\(number)").tag(Double(number))
                                        })
                                    }).pickerStyle(WheelPickerStyle())
                                }
                                
                                VStack {
                                    Picker("Minutes", selection: $minutes, content: {
                                        Text("Minutes")
                                        ForEach(0..<60, content: {
                                            number in
                                            Text("\(number)").tag(Double(number))
                                        })
                                    }).pickerStyle(WheelPickerStyle())
                                }
                                
                                VStack {
                                    
                                    Picker("Seconds", selection: $seconds, content: {
                                        Text("Seconds")
                                        ForEach(0..<60, content: {
                                            number in
                                            Text("\(number)").tag(Double(number))
                                        })
                                    }).pickerStyle(WheelPickerStyle())
                                }
                            }
                            Button(action: {
                                let elapsedInput = (hours * 60 * 60) + (minutes * 60) + seconds
                                
                                if elapsedInput >= (task.timer?.elapsedTime ?? 0) {
                                    timerVM.updateCountDownTimer(task: task, seconds: seconds, minutes: minutes, hours: hours)
                                } else {
                                    CDAlertMessage = "Timer already greater than countdown. To adjust completed time, restart timer."
                                    showCountdownAlert = true
                                    
                                    
                                }
                                editCountdownTime.toggle()
                                
                            } ) {
                                Text("Change CountDown")
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 10)
                                
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: 200)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                
                            }
                        }
                        }
                        
                        HStack {
                            Text("Time Remaining:")
                                .font(.title2).bold()
                            Text(timer.countdownTimer.asHoursMinutesSeconds())
                                .font(.title2)
                        }
                        
                        HStack {
                            Text("Percent Complete:")
                                .font(.title2).bold()
                            
                            Text("\(Int(timer.percentCompletion))%")
                                .font(.title2)
                        }
                        
                        ProgressView(value: timer.elapsedTime, total: timer.countdownNum)
                            .frame(width: 380, height: 12)
                            .tint(timer.isRunning == true ? Color.red : Color.accentColor)
                            .clipShape(Capsule())
                    }
                    
                }
                .background(Color(.systemGray5))
            }
            .frame(maxWidth: .infinity)
            .background(Color(.yellow))
            
        }
        .padding(.horizontal)
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(.black) : Color(.green))
//        .sheet(isPresented: $showSheet) {
//            IncrementView(task: task, taskVM: taskVM)
//        }
//        .alert("Number Too High", isPresented: $showAlert) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(alertMessage)
//                .font(.headline)
//        }
//        .alert("Number Too Low", isPresented: $showCountdownAlert) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(alertMessage)
//                .font(.headline)
//        }
        
    }
}


//#Preview {
//    let context = PersistenceController.preview.container.viewContext
//    let mockTask = Task(context: context)
//    mockTask.title = "Preview Task"
//    let mockTimer = TimerEntity(context: context)
//    mockTimer.elapsedTime = 42
//    mockTimer.cdTimerEndDate = Date().addingTimeInterval(100)
//    mockTimer.cdTimerStartDate = Date()
//    mockTimer.countdownTimer = 100
//    mockTimer.countdownNum = 100
//    mockTimer.isRunning = true
//    mockTask.timer = mockTimer
//
//    
//    return TaskView(taskVM: TaskViewModel(), timerVM: TimerViewModel(taskViewModel: TaskViewModel(), goalViewModel: GoalViewModel()), task: mockTask)
//}
