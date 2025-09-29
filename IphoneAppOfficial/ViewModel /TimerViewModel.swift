//
//  TimerViewModel.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 7/31/25.
//

import CoreData
import Combine
import UserNotifications


class TimerViewModel: ObservableObject {
    
   
    
    
    private let taskViewModel: TaskViewModel
    private let goalViewModel: GoalViewModel

    init(taskViewModel: TaskViewModel, goalViewModel: GoalViewModel) {
           self.taskViewModel = taskViewModel
           self.goalViewModel = goalViewModel
         
       }
    
    var sharedUITimer: AnyCancellable?
    
    private var progressUpdateTimer: AnyCancellable?
    
    @Published var newNums: [NSManagedObjectID: Int] = [:]
    @Published var countDownViewElapsed: [NSManagedObjectID: Double] = [:]
    @Published var countDownView: [NSManagedObjectID: Double] = [:]
    @Published var timerValues: [NSManagedObjectID: TimeInterval] = [:]
    @Published var countdownValues: [NSManagedObjectID: TimeInterval] = [:]
    @Published var percentageValues: [NSManagedObjectID: Double] = [:]
    @Published var countdownNums: [NSManagedObjectID: Double] = [:]
    @Published var goalToTasks: [NSManagedObjectID: [NSManagedObjectID]] = [:]
    
    @Published var dailyTasksPercentComplete: Double = 0
    @Published var dailyTasksTimeRemaining: Double = 0
    @Published var goalMonthTimeRemaining: Double = 0
    @Published var combinedElapsedProgress: Double = 0
    @Published var totalTaskTime: Double = 0
    @Published var taskProgressPercent: Double = 0
    @Published var taskTimeRemaining: Double = 0
    @Published var activeTasksNum : Int = 0
    @Published var completedTasksNum : Int = 0
    @Published var dayCombinedElapsedProgress: Double = 0
    @Published var dayTimeRemaining: Double = 0
    @Published var dayTotalTaskTime: Double = 0
    @Published var dayTaskProgressPercent: Double = 0
    @Published var dayTaskTimeRemaining: Double = 0
    
    @Published var timerElapsed: Double = 0

    func startSharedUITimer() {
        sharedUITimer?.cancel()  // Stop existing one if any

        sharedUITimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateAllRunningTaskTimers()
            }
    }
    
    func startSharedUITimerDate(date: Date, tasks: [Task]) {
        sharedUITimer?.cancel()  // Stop existing one if any

        sharedUITimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateAllRunningTaskTimers(date: date, tasks: tasks)
            }
    }
    
    
    func setAllTimerVals(date: Date? = nil, tasks: [Task]? = nil, goal: Goal? = nil, goalTasks: [Task]? = nil) {
        
        if goal !=  nil {
            if let tasks = goalTasks {
                for task in tasks {
                    guard let timerData = task.timer, !timerData.isRunning else { continue }
                    
                    self.countDownViewElapsed[task.objectID] = timerData.elapsedTime
                    self.countDownView[task.objectID] = timerData.countdownTimer
                    self.percentageValues[task.objectID] = timerData.percentCompletion
                    
                    
                }
                
            }
        } else if (date !=  nil) {
            if let tasks = tasks {
                for task in tasks {
                    guard let timerData = task.timer, !timerData.isRunning else { continue }
                    
                    self.countDownViewElapsed[task.objectID] = timerData.elapsedTime
                    self.countDownView[task.objectID] = timerData.countdownTimer
                    self.percentageValues[task.objectID] = timerData.percentCompletion
                    
                    
                }
                
            }
        } else {
            
            for task in self.taskViewModel.savedTasks {
                guard let timerData = task.timer, !timerData.isRunning else { continue }
                
                self.countDownViewElapsed[task.objectID] = timerData.elapsedTime
                self.countDownView[task.objectID] = timerData.countdownTimer
                self.percentageValues[task.objectID] = timerData.percentCompletion
                
                
            }
        }
    }

    

    func updateAllRunningTaskTimers(date: Date? = nil, tasks: [Task]? = nil, goal: Goal? = nil, goalTasks: [Task]? = nil) {
        
        if goal != nil {
            let currentTime = Date()
            if let goalTasks = goalTasks {
                for task in goalTasks {
                    guard let timerData = task.timer, timerData.isRunning else { continue }

                    let newElapsedTime = currentTime.timeIntervalSince(timerData.startDate ?? currentTime)
                    let newCDTime = max(0, timerData.cdTimerEndDate?.timeIntervalSince(currentTime) ?? 0)
                    let uiPvals = max(0, min((newElapsedTime / timerData.countdownNum) * 100, 100))

                    timerData.elapsedTime = newElapsedTime
                    timerData.countdownTimer = newCDTime
                    timerData.percentCompletion = uiPvals
                    
                    self.countDownViewElapsed[task.objectID] = newElapsedTime
                    self.countDownView[task.objectID] = newCDTime
                    self.percentageValues[task.objectID] = uiPvals
                    
                    

                    if let goal = task.goal {
                        goalViewModel.GoalElapsedTimeUIUpdateOnly(goal: goal)
                    }

        //            self.countDownViewElapsed[task.objectID] = newElapsedTime
        //            self.countDownView[task.objectID] = newCDTime
        //            self.percentageValues[task.objectID] = uiPvals

                    if newCDTime <= 0 {
                        stopTimer(task)
                        timerData.timerComplete = true
                        task.isComplete = true

                        // Schedule a local notification
//                        let content = UNMutableNotificationContent()
//                        content.title = "Task Complete"
//                        content.body = "\(task.title ?? "A task") is now complete!"
//                        content.sound = .default
//
//                        let request = UNNotificationRequest(
//                            identifier: task.objectID.uriRepresentation().absoluteString,
//                            content: content,
//                            trigger: nil // Deliver immediately
//                        )
//
//                        UNUserNotificationCenter.current().add(request) { error in
//                            if let error = error {
//                                print("Failed to schedule notification: \(error.localizedDescription)")
//                            }
//                        }
                        checkGoalComplete(task: task)
                    }


                    if !timerData.isRunning {
                        stopTimer(task)
                    }
                }
            }
            
        }
        
        if date != nil {
            let currentTime = Date()
            
            if let tasks = tasks {
                for task in tasks {
                    guard let timerData = task.timer, timerData.isRunning else { continue }

                    let newElapsedTime = currentTime.timeIntervalSince(timerData.startDate ?? currentTime)
                    let newCDTime = max(0, timerData.cdTimerEndDate?.timeIntervalSince(currentTime) ?? 0)
                    let uiPvals = max(0, min((newElapsedTime / timerData.countdownNum) * 100, 100))

                    timerData.elapsedTime = newElapsedTime
                    timerData.countdownTimer = newCDTime
                    timerData.percentCompletion = uiPvals
                    
                    self.countDownViewElapsed[task.objectID] = newElapsedTime
                    self.countDownView[task.objectID] = newCDTime
                    self.percentageValues[task.objectID] = uiPvals
                    
                    

                    if let goal = task.goal {
                        goalViewModel.GoalElapsedTimeUIUpdateOnly(goal: goal)
                    }

        //            self.countDownViewElapsed[task.objectID] = newElapsedTime
        //            self.countDownView[task.objectID] = newCDTime
        //            self.percentageValues[task.objectID] = uiPvals

                    if newCDTime <= 0 {
                        stopTimer(task)
                        timerData.timerComplete = true
                        task.isComplete = true

                        // Schedule a local notification
//                        let content = UNMutableNotificationContent()
//                        content.title = "Task Complete"
//                        content.body = "\(task.title ?? "A task") is now complete!"
//                        content.sound = .default
//
//                        let request = UNNotificationRequest(
//                            identifier: task.objectID.uriRepresentation().absoluteString,
//                            content: content,
//                            trigger: nil // Deliver immediately
//                        )
//
//                        UNUserNotificationCenter.current().add(request) { error in
//                            if let error = error {
//                                print("Failed to schedule notification: \(error.localizedDescription)")
//                            }
//                        }
                        
                        checkGoalComplete(task: task)
                    }


                    if !timerData.isRunning {
                        stopTimer(task)
                    }
                }
            }
            self.updateCombinedTimers(date: date, tasks: tasks)
           
        } else {
            
            let currentTime = Date()
            
            for task in self.taskViewModel.savedTasks {
                guard let timerData = task.timer, timerData.isRunning else { continue }
                
                let newElapsedTime = currentTime.timeIntervalSince(timerData.startDate ?? currentTime)
                let newCDTime = max(0, timerData.cdTimerEndDate?.timeIntervalSince(currentTime) ?? 0)
                let uiPvals = max(0, min((newElapsedTime / timerData.countdownNum) * 100, 100))
                
                timerData.elapsedTime = newElapsedTime
                timerData.countdownTimer = newCDTime
                timerData.percentCompletion = uiPvals
                
                self.countDownViewElapsed[task.objectID] = newElapsedTime
                self.countDownView[task.objectID] = newCDTime
                self.percentageValues[task.objectID] = uiPvals
                
                
                
                if let goal = task.goal {
                    goalViewModel.GoalElapsedTimeUIUpdateOnly(goal: goal)
                }
                
                //            self.countDownViewElapsed[task.objectID] = newElapsedTime
                //            self.countDownView[task.objectID] = newCDTime
                //            self.percentageValues[task.objectID] = uiPvals
                
                if newCDTime <= 0 {
                    stopTimer(task)
                    timerData.timerComplete = true
                    task.isComplete = true
                    
                    // Schedule a local notification
//                    let content = UNMutableNotificationContent()
//                    content.title = "Task Complete"
//                    content.body = "\(task.title ?? "A task") is now complete!"
//                    content.sound = .default
//                    
//                    let request = UNNotificationRequest(
//                        identifier: task.objectID.uriRepresentation().absoluteString,
//                        content: content,
//                        trigger: nil // Deliver immediately
//                    )
//                    
//                    UNUserNotificationCenter.current().add(request) { error in
//                        if let error = error {
//                            print("Failed to schedule notification: \(error.localizedDescription)")
//                        }
//                    }
                    checkGoalComplete(task: task)
                }
                
                
                if !timerData.isRunning {
                    stopTimer(task)
                }
            }
            
            self.updateCombinedTimers()
        }
    }
    
    func ElapsedTimeForTasks(allTasks: [Task]) -> (combinedElapsed: Double, overAllTime: Double, percentComplete: Double, estimatedTimeRemaining: Double) {
        var totalElapsed: Double = 0.0
        var overAllTime: Double = 0.0
        
//        @State private var activeTasksNum : Int = 0
//        @State private var completedTasksNum : Int = 0
        
      

        for task in allTasks {
            // Check if task date matches the provided date (ignoring time)
            
           
                if let timer = task.timer {
                    totalElapsed += timer.elapsedTime
                    overAllTime += timer.countdownNum
                }
                if let quantity = task.quantityval {
                    totalElapsed += quantity.timeElapsed
                    overAllTime += quantity.totalTimeEstimate
                }
            
        }
        
        let percent = overAllTime > 0 ? (totalElapsed / overAllTime) * 100 : 0
        let remaining = max(0, overAllTime - totalElapsed)
        
        return (totalElapsed, overAllTime, percent, remaining)
    }
    
    func beginProgressUpdates(for date: Date, tasks: [Task]? = nil, goalTasks: [Task]? = nil) {
        progressUpdateTimer?.cancel()

        progressUpdateTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                DispatchQueue.global(qos: .userInitiated).async {
                    
                    if let tasks = goalTasks {
                        let result = self.ElapsedTimeForTasks(allTasks: tasks)
                        
                        DispatchQueue.main.async {
                            self.combinedElapsedProgress = result.combinedElapsed
                            self.totalTaskTime = result.overAllTime
                            self.taskProgressPercent = result.percentComplete
                            self.taskTimeRemaining = result.estimatedTimeRemaining
                            self.updateAllRunningTaskTimers(date: date, tasks: tasks)
                        }
                        
                    }
                    if let tasks = tasks {
                        let result = self.ElapsedTimeForTasks(allTasks: tasks)
                        
                        DispatchQueue.main.async {
                            self.combinedElapsedProgress = result.combinedElapsed
                            self.totalTaskTime = result.overAllTime
                            self.taskProgressPercent = result.percentComplete
                            self.taskTimeRemaining = result.estimatedTimeRemaining
                            self.updateAllRunningTaskTimers(date: date, tasks: tasks)
                        }
                        
                    } else {
                        let result = self.ElapsedTimeForTasks(allTasks: self.taskViewModel.savedTasks)
                        
                        DispatchQueue.main.async {
                            self.combinedElapsedProgress = result.combinedElapsed
                            self.totalTaskTime = result.overAllTime
                            self.taskProgressPercent = result.percentComplete
                            self.taskTimeRemaining = result.estimatedTimeRemaining
                            self.updateAllRunningTaskTimers()
                        }
                    }
                }
            }
        
        print("daily progress Update")
    }



      func endProgressUpdates() {
          progressUpdateTimer?.cancel()
          progressUpdateTimer = nil
      }
    
    func beginProgressUpdatesDate(date: Date, tasks: [Task]) {
        progressUpdateTimer?.cancel()

        progressUpdateTimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                DispatchQueue.global(qos: .userInitiated).async {
                    let result = self.ElapsedTimeForTasks(allTasks: tasks)

                    DispatchQueue.main.async {
                        self.dayCombinedElapsedProgress = result.combinedElapsed
                        self.dayTotalTaskTime = result.overAllTime
                        self.dayTaskProgressPercent = result.percentComplete
                        self.dayTaskTimeRemaining = result.estimatedTimeRemaining
                        self.updateAllRunningTaskTimers()
                    }
                    
//                    @Published var dayTimeRemaining: Double = 0
//                    @Published var dayTotalTaskTime: Double = 0
//                    @Published var dayTaskProgressPercent: Double = 0
//                    @Published var dayTaskTimeRemaining: Double = 0
                }
            }
        
        print("daily progress Update")
    }
    
    
    
    func updateCombinedTimers(date: Date? = nil, tasks: [Task]? = nil) {
        
        if date != nil {
            if let tasks = tasks {
                
                
                var totalElapsed: TimeInterval = 0
                var totalCountdown: TimeInterval = 0
                
                for task in tasks {
                    guard let timer = task.timer,
                          timer.isRunning,
                          let elapsed = countDownViewElapsed[task.objectID],
                          let countdown = countdownNums[task.objectID] else {
                        continue
                    }

                    totalElapsed += elapsed
                    totalCountdown += countdown
                }

                dailyTasksTimeRemaining = max(0, totalCountdown - totalElapsed)
                dailyTasksPercentComplete = totalCountdown > 0 ? (totalElapsed / totalCountdown) * 100 : 0
            }
            
        } else {
            
            var totalElapsed: TimeInterval = 0
            var totalCountdown: TimeInterval = 0
            
            for task in taskViewModel.savedTasks {
                guard let timer = task.timer,
                      timer.isRunning,
                      let elapsed = countDownViewElapsed[task.objectID],
                      let countdown = countdownNums[task.objectID] else {
                    continue
                }
                
                totalElapsed += elapsed
                totalCountdown += countdown
            }
            
            dailyTasksTimeRemaining = max(0, totalCountdown - totalElapsed)
            dailyTasksPercentComplete = totalCountdown > 0 ? (totalElapsed / totalCountdown) * 100 : 0
            
        }
    }
    
    func estimatedTimeRemaining(for date: Date) -> Double {
        let calendar = Calendar.current
        
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "dueDate >= %@ AND dueDate < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let tasksForDate = try CoreDataManager.shared.context.fetch(request)
            let result = ElapsedTimeForTasks(allTasks: tasksForDate)
            dayTaskTimeRemaining = result.estimatedTimeRemaining
            return dayTimeRemaining
        } catch {
            print("Fetch error: \(error)")
            return 0
        }
    }




    
    func resumeTimer (task: Task) {
        guard let timerData = task.timer else { return }
        
        if timerData.isRunning == true {
            startTimer(task)
            print("STARTDATE \(timerData.startDate ?? Date())")
            print("ELAPSED TIME \(timerData.elapsedTime)")
            if self.countdownNums[task.objectID] == nil {
                self.countdownNums[task.objectID] = timerData.countdownNum
            }
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                self.countdownNums[task.objectID] = timerData.countdownNum
                let currentTime = Date()
                
                let newElapsedTime = currentTime.timeIntervalSince(timerData.startDate ?? currentTime)
                let newCDTime = max(0, timerData.cdTimerEndDate?.timeIntervalSince(currentTime) ?? 0)

                let countdownNum = countdownNums[task.objectID, default: 1] // avoid divide by zero
                let safeCountdown = max(countdownNum, 1)
                let uiPvals = max(0, min((newElapsedTime / safeCountdown) * 100, 100))
                

                DispatchQueue.main.async {
                   
                    timerData.elapsedTime = newElapsedTime
                    self.countDownViewElapsed[task.objectID] = newElapsedTime
                    self.countDownView[task.objectID] = newCDTime
                    self.percentageValues[task.objectID] = uiPvals

                    if newCDTime <= 0 {
                        self.stopTimer(task)
                        timerData.timerComplete = true
                        print("Timer complete for \(task.title ?? "task")")
                        timer.invalidate()
                        if let task = timerData.task {
                            self.checkGoalComplete(task: task)
                        }
                    }

                    if timerData.isRunning == false {
                        self.stopTimer(task)
                        timer.invalidate()
                    }
                }
            }
        } else {
            if timerData.timerComplete == true {
                print("Timer Complete")
                stopTimer(task)
                return
            } else {
                print("Continuing timer")
                stopTimer(task)
            }
        }
    }
        
    
    
    func startUITimer(task: Task) {
        
        guard let timerData = task.timer else {
            print("no timer data")
            return
        }

        let shouldStart = (!timerData.isRunning && !timerData.timerComplete && timerData.timerManualToggled) ||
                          (timerData.isRunning && timerData.continueFromRefresh)

        guard shouldStart else {
            if timerData.timerComplete {
                print("Timer Complete")
                task.isComplete = true
            } else {
                print("Stopping timer")
            }
            stopTimer(task)
            return
        }

        startTimer(task)

        // Initialize countdownNum if not already set
        if self.countdownNums[task.objectID] == nil {
            self.countdownNums[task.objectID] = timerData.countdownNum
        }

        // No need to set up a timer here anymore
    }

    func startTimer(_ task: Task) {
        task.lastActive = Date()
        if let goal = task.goal {
            goal.lastActive = Date()
            print("goal last active \(goal.lastActive ?? Date())")
            CoreDataManager.shared.saveContext()
        }
        print("last active \(task.lastActive ?? Date())")
        

        if let elapsedT = task.timer?.elapsedTime, elapsedT > 0 {
            
            
            if task.timer?.timerManualToggled == true && task.timer?.continueFromRefresh == true {
                print("continuing timer from another page ")
                let currentTime = Date()
                task.timer?.isRunning = true
                
                task.timer?.elapsedTime = currentTime.timeIntervalSince(task.timer?.startDate ?? Date())
                task.timer?.countdownTimer = -(currentTime.timeIntervalSince(task.timer?.cdTimerEndDate ?? Date()))
                if let goal = task.goal {
                    goalViewModel.GoalElapsedTime(goal: goal)
                }
                
                CoreDataManager.shared.saveContext()
            }
            
            if task.timer?.timerManualToggled == true && task.timer?.continueFromRefresh == false {
                print("continuing timer from button click")
                let currentTime = Date()
                
                task.timer?.startDate = currentTime.addingTimeInterval(-(task.timer?.elapsedTime ?? 0))
                task.timer?.cdTimerStartDate = Date()
                task.timer?.cdTimerEndDate = task.timer?.startDate?.addingTimeInterval(task.timer?.countdownTimer ?? 0)
                
                
                task.timer?.isRunning = true
                
                if task.timer?.countdownTimer ?? 0 > 0 {
                    task.timer?.cdTimerStartDate = currentTime
                    task.timer?.cdTimerEndDate = task.timer?.cdTimerStartDate?.addingTimeInterval(task.timer?.countdownTimer ?? 0)
                    
                    
                    print("starting countdown timer for \(task.title ?? "task")")
                } else {
                    print("timer cycle completed")
                }
                
                print("starting timer for \(task.title ?? "task")")
                if let goal = task.goal {
                    goalViewModel.GoalElapsedTime(goal: goal)
                }
                CoreDataManager.shared.saveContext()
                
            }
        } else {
            task.timer?.elapsedTime = 0 + 0.01
                task.timer?.cdTimerStartDate = Date()
                task.timer?.cdTimerEndDate = task.timer?.cdTimerStartDate?.addingTimeInterval(task.timer?.countdownTimer ?? 0)
                task.timer?.isRunning = true
                task.timer?.startDate = Date()
            if let goal = task.goal {
                goalViewModel.GoalElapsedTime(goal: goal)
            }
            CoreDataManager.shared.saveContext()
                print("Starting timer timer from scratch for \(task.title ?? "task")")
            }
        if task.timer?.isRunning == true, let endDate = task.timer?.cdTimerEndDate {
            let timeRemaining = endDate.timeIntervalSinceNow
            if timeRemaining > 0 {
                scheduleTaskCompletionNotification(for: task)
            }
        }
    }
    
    func stopTimer(_ task: Task) {
        
        print(task.timer?.elapsedTime ?? "no time")
        
        task.timer?.isRunning = false
        let currentTime = Date()
        
        
        task.timer?.elapsedTime = currentTime.timeIntervalSince(task.timer?.startDate ?? Date())
        task.timer?.countdownTimer = -(currentTime.timeIntervalSince(task.timer?.cdTimerEndDate ?? Date()))
        
        if let elapsedT = task.timer?.elapsedTime, let cdNum = task.timer?.countdownNum {
            if elapsedT > cdNum {
                task.isComplete = true
                print("Task complete!")
                task.timer?.elapsedTime = cdNum
                
            }
        }


        if let elapsedTime = task.timer?.elapsedTime, let countdownNum = task.timer?.countdownNum, countdownNum > 0 {
            task.timer?.percentCompletion = min((elapsedTime / countdownNum) * 100, 100)
            print("Percent Completion: \(task.timer?.percentCompletion ?? 0)%")
        } else {
            task.timer?.percentCompletion = 0
            print("Invalid countdown or elapsed time. Setting completion to 0%.")
        }
        print("cdNum \(task.timer?.countdownNum ?? 0)")
        print(" %\(task.timer?.percentCompletion ?? 0)")
        print("elapsed \(task.timer?.elapsedTime ?? 0)")
        //min((newElapsedTime / countdownNums[task.objectID, default: 0]) * 100, 100)
        //put countdown num here.
        

        if let goal = task.goal {
            goalViewModel.GoalElapsedTime(goal: goal)
        }
        let identifier = task.objectID.uriRepresentation().absoluteString
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

        CoreDataManager.shared.saveContext()
    }
    
    
    func updateElapsedTime(task: Task, seconds: Double, minutes: Double, hours: Double) {
        let currentTime = Date()
        
        let newElapsedTime = (hours * 60 * 60) + (minutes * 60) + seconds
        
        let adjustedStartDate = currentTime.addingTimeInterval(-newElapsedTime)
        
        task.timer?.startDate = adjustedStartDate
        task.timer?.cdTimerStartDate = adjustedStartDate
        
        // Use countdownNum, not countdownTimer
        let countdownDuration = task.timer?.countdownNum ?? 0
        task.timer?.cdTimerEndDate = adjustedStartDate.addingTimeInterval(countdownDuration)
        task.timer?.elapsedTime = currentTime.timeIntervalSince(task.timer?.startDate ?? Date())
        task.timer?.countdownTimer = -(currentTime.timeIntervalSince(task.timer?.cdTimerEndDate ?? Date()))
        
        if let elapsedT = task.timer?.elapsedTime, let cdNum = task.timer?.countdownNum {
            if elapsedT >= cdNum {
                print("Task complete!")
                task.timer?.elapsedTime = cdNum
                
            }
        }
        if let elapsedTime = task.timer?.elapsedTime, let countdownNum = task.timer?.countdownNum, countdownNum > 0 {
            task.timer?.percentCompletion = min((elapsedTime / countdownNum) * 100, 100)
            print("Percent Completion: \(task.timer?.percentCompletion ?? 0)%")
        } else {
            task.timer?.percentCompletion = 0
            print("Invalid countdown or elapsed time. Setting completion to 0%.")
        }
        print("cdNum \(task.timer?.countdownNum ?? 0)")
        print(" %\(task.timer?.percentCompletion ?? 0)")
        print("elapsed \(task.timer?.elapsedTime ?? 0)")
      
        if Int(newElapsedTime) < Int(task.timer?.countdownNum ?? 0) {
            task.timer?.timerComplete = false
            task.isComplete = false
        } else {
            let roundedE = newElapsedTime.rounded(.down)
            let roundedT = task.timer?.countdownNum.rounded(.down)
            
            task.timer?.elapsedTime = roundedE
            task.timer?.countdownNum = roundedT ?? 0
            task.timer?.timerComplete = true
            task.isComplete = true
            task.timer?.percentCompletion = 100
            print(task.timer?.elapsedTime ?? 0)
            print("countdown number \(task.timer?.countdownNum ?? 0)")
        }
        

        if let goal = task.goal {
            goalViewModel.GoalElapsedTime(goal: goal)
        }
        
        CoreDataManager.shared.saveContext()
        print(Date())
        print("SD\(task.timer?.startDate ?? Date())")
    }

    func updateCountDownTimer (task: Task, seconds: Double, minutes: Double, hours: Double) {
        
        task.timer?.countdownNum = (hours * 60 * 60) + (minutes * 60) + seconds
        
        task.timer?.cdTimerEndDate = task.timer?.startDate?.addingTimeInterval(task.timer?.countdownNum ?? 0)
        task.timer?.countdownTimer = (task.timer?.countdownNum ?? 0) - (task.timer?.elapsedTime ?? 0)
       
        if let elapsedTime = task.timer?.elapsedTime, let countdownNum = task.timer?.countdownNum, countdownNum > 0 {
            task.timer?.percentCompletion = min((elapsedTime / countdownNum) * 100, 100)
            print("Percent Completion: \(task.timer?.percentCompletion ?? 0)%")
        } else {
            task.timer?.percentCompletion = 0
            print("Invalid countdown or elapsed time. Setting completion to 0%.")
        }
        if Double(task.timer?.percentCompletion ?? 0) < 100 {
            task.timer?.timerComplete = false
            task.isComplete = false
        }
        print("is task complete? \(task.isComplete)")
       
        CoreDataManager.shared.saveContext()
 
    }
    
    func countDownTimer( task: Task, seconds: Double, minutes: Double, hours: Double) {

        task.timer?.countdownTimer += (hours * 60 * 60) + (minutes * 60) + seconds
        task.timer?.countdownNum += (hours * 60 * 60) + (minutes * 60) + seconds
        task.timer?.totalTimeEstimate += (hours * 60 * 60) + (minutes * 60) + seconds
        CoreDataManager.shared.saveContext()
        print(task.timer?.countdownTimer ?? "no countdown value")
        print(task.timer?.cdTimerStartDate ?? "no date")
        print(task.timer?.cdTimerEndDate ?? "no date")
    }
    
    func toggleTimerOn (task: Task) {
        task.timer?.timerManualToggled = true
        CoreDataManager.shared.saveContext()
    }
    
    
    func toggleTimerOff (task: Task) {
        task.timer?.timerManualToggled = false
        CoreDataManager.shared.saveContext()
    }
    
    func scheduleTaskCompletionNotification(for task: Task) {
        guard let timerData = task.timer else { return }

        let timeRemaining = timerData.cdTimerEndDate?.timeIntervalSinceNow ?? 0
        guard timeRemaining > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Complete"
        content.body = "\(task.title ?? "A task") is now complete!"
        content.sound = .defaultCritical

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining, repeats: false)

        let request = UNNotificationRequest(
            identifier: task.objectID.uriRepresentation().absoluteString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    func notifyGoalCompleted(_ goal: Goal) {
            let content = UNMutableNotificationContent()
            content.title = "Goal Complete 🎯"
            content.body = "\(goal.title ?? "A goal") has been completed! Great work!"
            content.sound = .default
            
            let request = UNNotificationRequest(
                identifier: goal.objectID.uriRepresentation().absoluteString,
                content: content,
                trigger: nil
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule goal notification: \(error.localizedDescription)")
                }
            }
        }
    
    func checkGoalComplete(task: Task) {
        
        if let goal = task.goal {
              let tasks = goal.task as? Set<Task> ?? []
              let allComplete = tasks.allSatisfy { $0.isComplete }
              
              if allComplete && !goal.isComplete {
                  goal.isComplete = true
                  goal.dateCompleted = Date()
                  CoreDataManager.shared.saveContext()
                  notifyGoalCompleted(goal)
              }
          }
        
    }
    
}
