//
//  TaskView.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/7/25.
//


import SwiftUI
import CoreData

struct TaskView: View {
    @ObservedObject var goalVM: GoalViewModel
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
    @State private var editProgressNumQVal: Bool = false
    @State private var showSheet: Bool = false
    @State private var inputNumberText: String = ""
    @State var seconds:  Double = 0
    @State var minutes: Double = 0
    @State var hours: Double = 0
    @State private var titleText: String = ""
    
    @State private var selectedWeekdays: Set<Weekday> = []
    @State private var selectedEndDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    @State private var generatedDates: [Date] = []
    @State private var repeatingTasks: Bool = false
    
    @State private var completeTaskSheet: Bool = false
    
    @State private var showEmptyTitleAlert = false
    @State private var showLowQvalTotalAlert = false
    
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
                    VStack {
                        
                        VStack (spacing: 10){
                            HStack(spacing: 7) {
                                
                                
                                
                                
                                //                        Text("Task: ")
                                //                            .font(.largeTitle)
                                //                            .fontDesign(.serif)
                                //                            .bold()
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
                            .padding(.trailing, 15)
                          
                            
                            
                            
                            
                            
                            if editTitle && isEditView == true {VStack {
                                
                                HStack {
                                    TextField(" Insert New Name Here", text: $titleText)
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .frame(height: 40)
                                        .background(colorScheme == .dark ? .gray.opacity(0.20) : .white)
                                        .padding(.trailing)
                                }
                                .frame(maxWidth: .infinity)
                                HStack {
                                    Button(action: {
                                        guard !titleText.isEmpty else {
                                            showEmptyTitleAlert = true
                                            return
                                        }
                                        taskVM.updateTaskTitle(task: task, newTitle: titleText)
                                        editTitle.toggle()
                                        isEditView.toggle()
                                    } ) {
                                        Text("Change Name")
                                            .font(.subheadline.bold())
                                            .padding(.horizontal, 10)
                                        
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: 150)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                        
                                    }
                                    
                                    Button(action: {
                                        editTitle.toggle()
                                        isEditView.toggle()
                                    } ) {
                                        Text("Cancel")
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            .contentShape(Rectangle())
                                            .padding(.horizontal, 10)
                                        
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: 150)
                                            .background(Color.gray.opacity(0.25))
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                        
                                    }
                                }
                                .alert("Please enter a task title", isPresented: $showEmptyTitleAlert) {
                                    Button("OK", role: .cancel) { }
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
                        }
                    }
                    .padding(.top, 20)
                    
                    HStack {
                        Text("Date Scheduled:")
                            .font(.title2).bold()
                        
                        if let dueDate = task.dateDue {
                            if task.dateOnly {
                                Text("\(dueDate.formatted(.dateTime.month().day().year()))")
                                    .font(.title3)
                            } else {
                                Text("\(dueDate.formatted(.dateTime.month().day().year()))  \(dueDate.formatted(.dateTime.hour().minute()))")
                                    .font(.title3)
                            }
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
                    if isEditView && editDate {VStack {
                        
                        if task.dateOnly {
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
                        } else {
                            
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
                    }
                    HStack {
                        Text("Created:")
                            .font(.title2).bold()
                        Text(task.dateCreated?.formatted(.dateTime.month().day().year()) ?? "N/A")
                            .font(.title2)
                    }
                    
                    if task.timer == nil && task.quantityval == nil {
                        HStack {
                            Text("Completed:")
                                .font(.title2).bold()
                            if task.isComplete == false {
                                Text("False")
                                    .font(.title2)
                            } else {
                                Text("True")
                                    .font(.title2)
                            }
                        }
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
                                isEditView.toggle()
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
                        HStack {
                            Spacer()
                            ProgressView(value: timer.elapsedTime, total: timer.countdownNum)
                                .frame(maxWidth: .infinity, maxHeight: 12)
                                .tint(timer.isRunning == true ? Color.red : Color.accentColor)
                                .clipShape(Capsule())
                                .padding(.trailing, 10)
                            Spacer()
                        }
//                        .background(Color.yellow)
                        .frame(maxWidth: .infinity)
                        if task.timer?.timerComplete == false {
                            
                            
                            HStack {
                                Button(action: {
                                    if timer.timerManualToggled == false && timer.isRunning == false  {
                                        timerVM.toggleTimerOn(task: task)
                                        task.timer?.continueFromRefresh = false
                                        timerVM.startUITimer(task: task)
                                    } else {
                                        timerVM.toggleTimerOff(task: task)
                                        task.timer?.continueFromRefresh = false
                                        timerVM.startUITimer(task: task)
                                    }
                                }) {
                                    Text(timer.isRunning ? "Stop Task" : "Start Task")
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: 150)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 20)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)
                        }
                    }
                    
                    if let quantity = task.quantityval {
                        
                        HStack {
                            Text("Progress:")
                                .font(.title2).bold()
                            Text("\(Int(quantity.currentQuantity)) / \(Int(quantity.totalQuantity))")
                                .font(.title2)
                            
                                .foregroundColor(.primary)
                            
                            Spacer()
                            if isEditView {
                                Button(action: {
                                    editProgressNumQVal.toggle()
                                } ) {
                                    Text("edit")
                                        .font(.title2)
                                    
                                    
                                    
                                }
                                .padding(.trailing, 20)
                            }
                        }
                        if editProgressNumQVal && isEditView == true {
                            VStack {
                                HStack {
                                    
                                    TextField(" Enter New Total Quantity", text: $inputNumberText)
                                        .font(.title)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                                        .keyboardType(.decimalPad)
                                        .frame(height: 35) // Makes it taller and easier to tap
                                        .contentShape(Rectangle()) // Ensures the whole rectangle is tappable
                                        .padding(.trailing, 10)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            HStack {
                                Spacer()
                                Button(action: {
                                    guard (Double(inputNumberText) ?? 0) >= (task.quantityval?.currentQuantity ?? 0) else {
                                        showLowQvalTotalAlert = true
                                        return
                                    }
                                    
                                    taskVM.updateTotalQuantityValue(task: task, totalQuantity: Double(inputNumberText) ?? 0)
                                    inputNumberText = ""
                                    editProgressNumQVal.toggle()
                                    
                                    
                                } ) {
                                    Text("Submit")
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 10)
                                    
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: 200)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    
                                }
                                Spacer()
                            }
                            .alert("Number can't be lower than current quantity \(Int(task.quantityval?.currentQuantity ?? 0))", isPresented: $showLowQvalTotalAlert) {
                                Button("OK", role: .cancel) { }
                            }
                        }
                        
                    
                        
                        HStack {
                            Text("Time Per Val:")
                                .font(.title2).bold()
                            
                            Text("\(quantity.timePerQuantityVal.asHoursMinutesSeconds())")
                                .font(.title2)
                            Spacer()
                            if isEditView {
                                Button(action: {
                                    editTimePerVal.toggle()
                                } ) {
                                    Text("edit")
                                        .font(.title2)
                                    
                                    
                                    
                                }
                                .padding(.trailing, 20)
                            }
                        }
                        if editTimePerVal && isEditView == true {
                            VStack {
                            Text("Change Time Per Value")
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
                                
                                
                                taskVM.timeEstimatePerQuantity(task: task, hours: hours, minutes: minutes, seconds: seconds)
                                editTimePerVal.toggle()
                                
                                
                            } ) {
                                Text("Submit")
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
                            Text("Time Elapsed:")
                                .font(.title2).bold()
                            
                            Text("\(quantity.timeElapsed.asHoursMinutesSeconds())")
                                .font(.title2)
                        }
                        
                        HStack {
                            Text("Time Remaining:")
                                .font(.title2).bold()
                            
                            Text("\(quantity.estimatedTimeRemaining.asHoursMinutesSeconds())")
                                .font(.title2)
                        }
                        
                        
                        HStack {
                            Text("Percent Complete:")
                                .font(.title2).bold()
                            
                            Text("\(Int(quantity.percentCompletion))%")
                                .font(.title2)
                        }
                        
                        ProgressView(value: quantity.currentQuantity, total: quantity.totalQuantity)
                            .frame(maxWidth: .infinity, maxHeight: 12)
                            .tint(Color.accentColor)
                            .clipShape(Capsule())
                            .padding(.trailing, 10)
                    
                      
                            
                            HStack {
                                Button(action: {
                                    showSheet.toggle()
                                }) {
                                    Text("Update")
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: 150)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 20)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                }
//                .padding(.horizontal, 10)
                .padding(.leading, 12)
                .padding(.top, 15)
                .frame(maxWidth: .infinity, minHeight: 750, alignment: .topLeading)
                .background(colorScheme == .dark ? Color(.gray.opacity(0.20)) : Color.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 10)
            .padding(.top, 20)
            .background(colorScheme == .dark ? Color(.black) : Color(.systemGray5))
            
            HStack {
                Button(action: {
                    isEditView.toggle()
                } ) {
                    if !isEditView {
                        Text("edit")
                            
                    } else {
                        Text("Done")
                        
                    }
                    
                }
                Spacer()
                
                if !task.isComplete {
                    
                    Button("Complete Task") {
                        
                        if task.timer == nil && task.quantityval == nil {
                            taskVM.completeTask(task: task)
                        } else {
                            completeTaskSheet.toggle()
                        }
                    }
                }
            }
            .frame(height: 20)
            .padding(.horizontal, 20)
            .background(colorScheme == .dark ? Color(.black) : Color(.systemGray5))
            .sheet(isPresented: $completeTaskSheet) {
                CompleteEarly(taskVM: taskVM, timerVM: timerVM, task: $task)
            }
        
        }
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(.black) : Color(.systemGray5))
        .sheet(isPresented: $showSheet) {
            IncrementView(task: task, taskVM: taskVM, goalVM: goalVM, timerVM: timerVM)
        }
        .alert("Number Too High", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
                .font(.headline)
        }
        .alert("Number Too Low", isPresented: $showCountdownAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
                .font(.headline)
        }
        
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
