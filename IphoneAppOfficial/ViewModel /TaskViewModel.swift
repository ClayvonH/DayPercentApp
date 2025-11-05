//
//  TaskViewModel.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 7/30/25.
//

import CoreData
import Combine
import UserNotifications

class TaskViewModel: ObservableObject {
    
//    @Published var newTask = Task(context: CoreDataManager.shared.container.viewContext)
    
    @Published var savedTasks: [AppTask] = []
    @Published var dailyTasks: [AppTask] = []
    @Published var dateTasks: [AppTask] = []
    @Published var goalTasks: [AppTask] = []
    
    
    
    
    
    
    let container = CoreDataManager.shared.container
    
    
    
    func fetchTasks() {
        
        let taskrequest = NSFetchRequest<AppTask>(entityName: "AppTask")
        do {
            savedTasks = try container.viewContext.fetch(taskrequest)
            dailyTasks = getTasks(for: Date()) // <- Refresh dailyTasks here
            print("fetched tasks")
        } catch let error {
            print("error fetching \(error)")
        }
        
    }
    
    func fetchTasksForDate(for date: Date) {

        let request = NSFetchRequest<AppTask>(entityName: "AppTask")
        
        // Calculate the start and end of the day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) else { return }
        
        // Predicate to fetch tasks within that day
        request.predicate = NSPredicate(format: "dateDue >= %@ AND dateDue <= %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let tasksForDate = try container.viewContext.fetch(request)
            dateTasks = tasksForDate
            print("Fetched \(tasksForDate.count) tasks for \(date)")
        } catch {
            print("Error fetching tasks: \(error)")
        }
        
//        dateTasks = getTasks(for: date)
    }

    func fetchTasks(for goal: Goal) {
        let request = NSFetchRequest<AppTask>(entityName: "AppTask")
        
        // Predicate: fetch tasks where the goal relationship matches
        request.predicate = NSPredicate(format: "goal == %@", goal)
        
        do {
            let tasksForGoal = try container.viewContext.fetch(request)
            goalTasks = tasksForGoal // or whatever array you’re using
            print("Fetched \(tasksForGoal.count) tasks for goal: \(goal.title ?? "Unnamed Goal")")
        } catch {
            print("Error fetching tasks for goal: \(error)")
        }
    }

    func fetchTasks(goal: Goal, month: Date) {
        let request = NSFetchRequest<AppTask>(entityName: "AppTask")
        
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return
        }
        
        request.predicate = NSPredicate(format: "goal == %@ AND dateDue >= %@ AND dateDue < %@", goal, startOfMonth as NSDate, startOfNextMonth as NSDate)
        
        do {
            let tasksForGoal = try container.viewContext.fetch(request)
            goalTasks = tasksForGoal
            print("Fetched \(tasksForGoal.count) tasks for goal: \(goal.title ?? "Unnamed Goal") in month: \(month)")
        } catch {
            print("Error fetching tasks for goal: \(error)")
        }
    }
    
    func fetchTasks(month: Date) {
        let request = NSFetchRequest<AppTask>(entityName: "AppTask")
        
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return
        }
        
        // Filter only by month range, not by goal
        request.predicate = NSPredicate(
            format: "dateDue >= %@ AND dateDue < %@",
            startOfMonth as NSDate,
            startOfNextMonth as NSDate
        )
        
        do {
            let tasksInMonth = try container.viewContext.fetch(request)
            savedTasks = tasksInMonth
            print("Fetched \(tasksInMonth.count) tasks in month: \(month)")
        } catch {
            print("Error fetching tasks: \(error)")
        }
        
    }
    
    func fetchTasks(week: Date) {
        let request = NSFetchRequest<AppTask>(entityName: "AppTask")
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 1 = Sunday, 2 = Monday
        
        // Find the Monday of the current week
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: week)?.start else {
            return
        }
        
        // Adjust startOfWeek if it’s not already Monday
        let weekday = calendar.component(.weekday, from: startOfWeek)
        let daysToSubtract = (weekday == 1) ? 6 : weekday - 2 // shift Sunday->Monday logic
        guard let monday = calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfWeek),
              let nextMonday = calendar.date(byAdding: .weekOfYear, value: 1, to: monday) else {
            return
        }

        // Filter tasks within that Monday–Sunday range
        request.predicate = NSPredicate(
            format: "dateDue >= %@ AND dateDue < %@",
            monday as NSDate,
            nextMonday as NSDate
        )

        do {
            let tasksInWeek = try container.viewContext.fetch(request)
            savedTasks = tasksInWeek
            print("📅 Fetched \(tasksInWeek.count) tasks for week starting \(monday)")
        } catch {
            print("❌ Error fetching weekly tasks: \(error)")
        }
    }




    
    func getTasks(for date: Date) -> [AppTask] {
        let filtered = dateTasks.filter {
            if let taskDate = $0.dateDue {
                return Calendar.current.isDate(taskDate, inSameDayAs: date)
            }
            return false
        }
        print("Filtered tasks for \(date): \(filtered.map { $0.title ?? "No Title" })")
//        dailyTasks = filtered
//        print("\(dailyTasks)")
        return filtered
    }
    
    func deleteAllTasks() {
        let context = container.viewContext // Ensure you use the same context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AppTask.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            fetchTasks() // This now uses the same context
        } catch {
            print("Error deleting tasks: \(error.localizedDescription)")
        }
    }
    
    func deleteAllTasksInApp() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AppTask.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs // ensures NSManagedObjectContext merges properly

        do {
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                let changes: [AnyHashable: Any] = [
                    NSDeletedObjectsKey: objectIDs
                ]
                // ✅ merge the deletions into the current context so SwiftUI updates
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            }
            fetchTasks() // refresh your local list
        } catch {
            print("Error deleting tasks: \(error.localizedDescription)")
        }
    }

    
    func deleteAllTasksWithoutGoals() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<AppTask> = AppTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "goal == nil")
        
        do {
            let tasks = try context.fetch(fetchRequest)
            
            // 1️⃣ Remove all pending notifications
            for task in tasks {
                if task.reminder == true {
                    let id = task.objectID.uriRepresentation().absoluteString
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                    print("Removed reminder for task: \(task.title ?? "no title")")
                }
            }
            
            // 2️⃣ Delete tasks from Core Data
            for task in tasks {
                context.delete(task)
            }

            // 3️⃣ Save once for efficiency
            try context.save()
            print("Deleted \(tasks.count) tasks without goals.")
            
            // 4️⃣ Refresh your data
            fetchTasks()
            
        } catch {
            print("Error deleting tasks without goals: \(error.localizedDescription)")
        }
    }

    
    func deleteMonthTasks(tasks: [AppTask], month: Date) {
        
        let context = container.viewContext
        
        for task in tasks {
            turnOffRemindersNoSave(task: task)
            context.delete(task)
        }
        
        do {
            try context.save()
            fetchTasks() // refresh your view model’s list
        } catch {
            print("Error deleting tasks: \(error.localizedDescription)")
        }
        
        fetchTasks(month: month) 
    }


    
    func completeTask(task: AppTask) {
        if let goal = task.goal {
            goal.lastActive = Date()
            CoreDataManager.shared.saveContext()
        }
        if let timer = task.timer {
          
            timer.elapsedTime = timer.countdownNum
            timer.percentCompletion = 100
            timer.countdownTimer = 0
            task.timer?.timerComplete = true
            task.isComplete = true
 
            
            CoreDataManager.shared.saveContext()
            checkGoalComplete(task: task)
        }
        
        else if let quantity = task.quantityval {
            incrementQuantityVal(task: task, incVal: quantity.totalQuantity)
            task.isComplete = true
            
            CoreDataManager.shared.saveContext()
            checkGoalComplete(task: task)
        } else {
            task.isComplete = true
          
            CoreDataManager.shared.saveContext()
            checkGoalComplete(task: task)
        }
        if task.reminder == true {
            turnOffReminders(task: task)
        }
    }
    
    func completeTaskEarly(task: AppTask) {
        if let timer = task.timer {
            timer.countdownNum = timer.elapsedTime
            timer.countdownTimer = 0
            timer.percentCompletion = 100
            task.isComplete = true
            task.timer?.timerComplete = true 
           
            CoreDataManager.shared.saveContext()
            checkGoalComplete(task: task)
        }
        
        if let quantity = task.quantityval {
            quantity.totalQuantity = quantity.currentQuantity
            incrementQuantityVal(task: task, incVal: quantity.currentQuantity)
            quantity.totalTimeEstimate = quantity.timeElapsed
            
          
            task.isComplete = true
           CoreDataManager.shared.saveContext()
            checkGoalComplete(task: task)
        }
        if task.reminder == true {
            turnOffReminders(task: task)
        }
    }
    
    func createTaskAndReturn (title: String, dueDate: Date?, dateOnly: Bool = false, reminders: Bool = false) -> AppTask {
        let newTask = AppTask(context: container.viewContext)
        newTask.dateCreated = Date()
        newTask.title = title
        newTask.dateDue = dueDate
        newTask.dateOnly = dateOnly
        newTask.lastActive = Date()
        newTask.reminder = reminders
        
        CoreDataManager.shared.saveContext()
        
        if reminders == true {
            scheduleReminder(task: newTask)
        }
        return newTask
        
//        func addTaskToGoalTwo(goalr: Goal, title: String, dueDate: Date?, dateOnly: Bool = false) -> AppTask {
//            let newTask = AppTask(context: goalr.managedObjectContext!)
//            newTask.dateCreated = Date()
//            newTask.title = title
//            newTask.goal = goalr
//            newTask.dateDue = dueDate
//            newTask.dateOnly = dateOnly
//            goalr.addToTask(newTask)
//            newTask.lastActive = Date()
//            goalr.isComplete = false
//            CoreDataManager.shared.saveContext()
//            fetchGoals()
//            return newTask
//          
//        }
    }
    
    func createTask(title: String, date: Date?, dateOnly: Bool = false, reminders: Bool = false) {
        let newTask = AppTask(context: container.viewContext)
        newTask.dateCreated = Date()
        newTask.dateDue = date
        newTask.title = title
        newTask.dateOnly = dateOnly
        newTask.reminder = reminders
    
        CoreDataManager.shared.saveContext()
        if reminders == true {
            scheduleReminder(task: newTask)
        }
    }
    
    func addTimerToTask (task: AppTask) {
        let newTimer = TimerEntity(context: container.viewContext)
        task.timer = newTimer
        CoreDataManager.shared.saveContext()
    }
    
    func addMultipleTimers(task: AppTask) {
        guard let taskTitle = task.title else { return }

        let fetchRequest: NSFetchRequest<AppTask> = AppTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", taskTitle)

        do {
            let matchingTasks = try container.viewContext.fetch(fetchRequest)

            for t in matchingTasks {
                let newTimer = TimerEntity(context: container.viewContext)
                t.timer = newTimer
            }

            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to fetch tasks with matching title: \(error)")
        }
    }
    
    func addMultipleCountdownTimers(task: AppTask, seconds: Double, minutes: Double, hours: Double) {
        guard let taskTitle = task.title else { return }

        let totalSeconds = (hours * 60 * 60) + (minutes * 60) + seconds

        let fetchRequest: NSFetchRequest<AppTask> = AppTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", taskTitle)

        do {
            let matchingTasks = try container.viewContext.fetch(fetchRequest)

            for t in matchingTasks {
                if let timer = t.timer {
                    timer.countdownTimer += totalSeconds
                    timer.countdownNum += totalSeconds
                    timer.totalTimeEstimate += totalSeconds
                }
            }

            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to fetch tasks with matching title: \(error)")
        }
    }
    
//    func repeatTask(task: Task, dates: [Date]){
//        
//        for date in dates {
//            let newTask = Task(context: container.viewContext)
//            newTask.repeating = true
//            newTask.title = task.title
//            newTask.goal = task.goal
//            newTask.dateCreated = Date()
//            newTask.dateDue = date
//            newTask.lastActive = Date()
//            CoreDataManager.shared.saveContext()
//            fetchTasks()
//        }
//    }
    
    func repeatTask(task: AppTask, dates: [Date], reminders: Bool = false) {
        var createdTasks: [AppTask] = []
        for date in dates {
            let newTask = AppTask(context: container.viewContext)
            newTask.repeating = true
            newTask.title = task.title
            newTask.goal = task.goal
            newTask.dateCreated = Date()
            newTask.dateDue = date
            newTask.dateOnly = task.dateOnly
            newTask.lastActive = Date()
            newTask.reminder = reminders
            newTask.seriesID = task.seriesID
            createdTasks.append(newTask)
        }
        CoreDataManager.shared.saveContext()
        
        for newTask in createdTasks where newTask.reminder {
               scheduleReminderNoSave(task: newTask)
           }
        CoreDataManager.shared.saveContext()
        fetchTasks()
    }


    func repeatingTrue (task: AppTask) {
        task.repeating = true
        task.seriesID = UUID()
        CoreDataManager.shared.saveContext()
    }
    
    func deleteTask(_ task: AppTask) {
        if task.reminder == true {
            turnOffReminders(task: task)
        }
        let context = task.managedObjectContext
        context?.delete(task) // Mark the goal for deletion
       
        CoreDataManager.shared.saveContext()
        fetchTasks()
    }
    
    func deleteTaskForDate(date: Date, task: AppTask) {
        if task.reminder == true {
            turnOffReminders(task: task)
        }
        let context = task.managedObjectContext
        context?.delete(task) // Mark the goal for deletion
        
        CoreDataManager.shared.saveContext()
        fetchTasksForDate(for: date)
    }
    
    func deleteTaskForGoal(goal: Goal, task: AppTask) {
        if task.reminder == true {
            turnOffReminders(task: task)
        }
        let context = task.managedObjectContext
        context?.delete(task) // Mark the goal for deletion
     
        CoreDataManager.shared.saveContext()
        fetchTasks(for: goal)
    }
    
    
    func deleteRepeatingTasks(date: Date? = nil, goal: Goal? = nil, task: AppTask) {
        guard let context = task.managedObjectContext,
              let seriesID = task.seriesID else {
            return
        }

        // Fetch all tasks that share the same seriesID
        let fetchRequest: NSFetchRequest<AppTask> = AppTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "seriesID == %@", seriesID as CVarArg)

        do {
            let matchingTasks = try context.fetch(fetchRequest)
            for t in matchingTasks {
                if !t.isComplete {
                    if t.reminder == true {
                        let id = t.objectID.uriRepresentation().absoluteString
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                    }
                    context.delete(t)
                }
              
            }
            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to fetch tasks for deletion: \(error)")
        }
        if let date = date {
            fetchTasksForDate(for: date)
            print("fetching tasks for date")
        } else if let goal = goal {
            fetchTasks(for: goal)
            print("fetching tasks for goal")
        }
        else {
            fetchTasks()
            print("fetching all tasks ")
        }
    }

    func deleteIncompleteRepeatingTasks(date: Date? = nil, goal: Goal? = nil, task: AppTask) {
        guard let context = task.managedObjectContext,
              let seriesID = task.seriesID else {
            return
        }

        // Fetch all tasks that share the same seriesID
        let fetchRequest: NSFetchRequest<AppTask> = AppTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "seriesID == %@", seriesID as CVarArg)

        do {
            let matchingTasks = try context.fetch(fetchRequest)
            for t in matchingTasks {
                if !t.isComplete {
                    context.delete(t)
                }
            }
            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to fetch tasks for deletion: \(error)")
        }
        if let date = date {
            fetchTasksForDate(for: date)
            print("fetching tasks for date")
        } else if let goal = goal {
            fetchTasks(for: goal)
            print("fetching tasks for goal")
        }
        else {
            fetchTasks()
            print("fetching all tasks ")
        }
    }
    

    func deleteMultipleTasksInView(tasks: [AppTask], date: Date? = nil, goal: Goal? = nil) {
        guard let context = tasks.first?.managedObjectContext else { return }

        for task in tasks {
            if task.reminder == true {
                let id = task.objectID.uriRepresentation().absoluteString
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            }
            context.delete(task)
           
        }

        CoreDataManager.shared.saveContext()
        if let date = date {
            fetchTasksForDate(for: date)
        }
        
        if let goal = goal {
            fetchTasks(for: goal)
        }
    }
    
    func addQuantityVal( task: AppTask, qVal: Double ) {

        if task.quantityval == nil {
               let newQuantity = QuantityValue(context: container.viewContext)
               newQuantity.totalQuantity = qVal
               task.quantityval = newQuantity

            task.quantityval?.percentCompletion = min((task.quantityval?.currentQuantity ?? 0 / (task.quantityval?.totalQuantity ?? 0)) * 100, 100)
           } else {
               task.quantityval?.totalQuantity = qVal
               getQuantityPercentage(task: task)
           }

        CoreDataManager.shared.saveContext()
        print("Quantity for \(task.title ?? "task" ) is \(task.quantityval?.totalQuantity ?? 0)")
    }
    
    func addMultipleQuantityVals(task: AppTask, qVal: Double) {
        guard let taskTitle = task.title else { return }

        let fetchRequest: NSFetchRequest<AppTask> = AppTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", taskTitle)

        do {
            let matchingTasks = try container.viewContext.fetch(fetchRequest)

            for t in matchingTasks {
                if t.quantityval == nil {
                    let newQuantity = QuantityValue(context: container.viewContext)
                    newQuantity.totalQuantity = qVal
                    t.quantityval = newQuantity

                    t.quantityval?.percentCompletion = min(
                        ((t.quantityval?.currentQuantity ?? 0) / (t.quantityval?.totalQuantity ?? 1)) * 100,
                        100
                    )
                } else {
                    t.quantityval?.totalQuantity = qVal
                    getQuantityPercentage(task: t)
                }

                print("Quantity for \(t.title ?? "task") is \(t.quantityval?.totalQuantity ?? 0)")
            }

            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to fetch tasks with title \(taskTitle): \(error)")
        }
    }
    
    func updateTotalQuantityValue(task: AppTask, totalQuantity: Double) {
        task.quantityval?.totalQuantity = totalQuantity
        let current = task.quantityval?.currentQuantity ?? 0
        task.quantityval?.totalTimeEstimate = (task.quantityval?.totalQuantity ?? 0) * (task.quantityval?.timePerQuantityVal ?? 0)
        task.quantityval?.timeElapsed = (task.quantityval?.currentQuantity ?? 0) * (task.quantityval?.timePerQuantityVal ?? 0)
        CoreDataManager.shared.saveContext()
        incrementQuantityVal(task: task, incVal: current)
        print("total time estimate \(task.quantityval?.totalTimeEstimate ?? 0)")
    }
    
    func getQuantityPercentage(task: AppTask) {
        let total = task.quantityval?.totalQuantity ?? 0
        let current = task.quantityval?.currentQuantity ?? 0
       // let timePer = task.quantityval?.timePerQuantityVal ?? 0

        task.quantityval?.percentCompletion = min((current / total) * 100, 100)
    }
    
    func incrementQuantityVal( task: AppTask, incVal: Double) {
        if task.isComplete && incVal < task.quantityval?.totalQuantity ?? 0 {
            task.isComplete = false
        }
        
        if let goal = task.goal {
            goal.lastActive = Date()
            CoreDataManager.shared.saveContext()
            print("Saved goal last update on inc")
            if let active = goal.lastActive {
                print("\(active)")
            } else {
                print("didn't save last active")
            }
        }
        
        task.quantityval?.currentQuantity = incVal
        task.quantityval?.percentCompletion = min((task.quantityval?.currentQuantity ?? 0 / (task.quantityval?.totalQuantity ?? 0)) * 100, 100)
        task.quantityval?.timeElapsed = (task.quantityval?.currentQuantity ?? 0) * (task.quantityval?.timePerQuantityVal ?? 0)
        if incVal == task.quantityval?.totalQuantity ?? 0 {
            task.isComplete = true
            let content = UNMutableNotificationContent()
            content.title = "Task Complete"
            content.body = "\(task.title ?? "A task") is now complete!"
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: task.objectID.uriRepresentation().absoluteString,
                content: content,
                trigger: nil // Deliver immediately
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error.localizedDescription)")
                }
            }
        }
        showQuantityValData(task: task)
        
        if let goal = task.goal {
              let tasks = goal.task as? Set<AppTask> ?? []
              let allComplete = tasks.allSatisfy { $0.isComplete }
              
              if allComplete && !goal.isComplete {
                  goal.isComplete = true
                  goal.dateCompleted = Date()
                  CoreDataManager.shared.saveContext()
                  notifyGoalCompleted(goal)
              }
          }
        
        print("estimated time elapsed is \(task.quantityval?.timeElapsed ?? 0)")
        print("total time combined for quantity is \(task.quantityval?.totalTimeEstimate ?? 0)")
        print("estimated time remaining for quantity is \(task.quantityval?.estimatedTimeRemaining ?? 0)")
        
        task.lastActive = Date()
        getQuantityPercentage(task: task)
        CoreDataManager.shared.saveContext()
    }
    
    func timeEstimatePerQuantity ( task: AppTask, hours: Double, minutes: Double, seconds: Double) {
        task.quantityval?.timePerQuantityVal = (hours * 60 * 60) + (minutes * 60) + seconds
        task.quantityval?.totalTimeEstimate = (task.quantityval?.totalQuantity ?? 0) * (task.quantityval?.timePerQuantityVal ?? 0)
        task.quantityval?.timeElapsed = (task.quantityval?.currentQuantity ?? 0) * (task.quantityval?.timePerQuantityVal ?? 0)
        showQuantityValData(task: task)
        print(" time per val \(task.quantityval?.timePerQuantityVal ?? 0)")
        showQuantityValData(task: task)
        CoreDataManager.shared.saveContext()

    }
    
    func timeEstimatePerQuantityMultiple(task: AppTask, hours: Double, minutes: Double, seconds: Double) {
        guard let taskTitle = task.title else { return }

        let fetchRequest: NSFetchRequest<AppTask> = AppTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", taskTitle)

        do {
            let matchingTasks = try container.viewContext.fetch(fetchRequest)

            let addedTime = (hours * 60 * 60) + (minutes * 60) + seconds

            for t in matchingTasks {
                if let quantity = t.quantityval {
                    quantity.timePerQuantityVal += addedTime
                    quantity.totalTimeEstimate = quantity.totalQuantity * quantity.timePerQuantityVal

                    print("Time per quantity for \(t.title ?? "task"): \(quantity.timePerQuantityVal)")
                    showQuantityValData(task: t)
                }
            }

            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to fetch tasks with title \(taskTitle): \(error)")
        }
    }
    
    func showQuantityValData ( task: AppTask ) {

        let total = task.quantityval?.totalQuantity ?? 0
        let current = task.quantityval?.currentQuantity ?? 0
        let timePer = task.quantityval?.timePerQuantityVal ?? 0

        task.quantityval?.estimatedTimeRemaining = (total - current) * timePer

        print("Estimated time remaining is \(task.quantityval?.estimatedTimeRemaining ?? 0)")

        task.quantityval?.percentCompletion = min((current / total) * 100, 100)


        CoreDataManager.shared.saveContext()
    }
    
    func sortedTasks(goal: Goal, option: TaskSortOption) -> [AppTask] {
        let tasks = goalTasks
        
        switch option {
        case .title:
              return tasks.sorted {
                  ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedAscending
              }
            
        case .zaTitle:
            return tasks.sorted {
                ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedDescending
            }
            
        case .dueDate:
            return tasks.sorted { ($0.dateDue ?? .distantFuture) < ($1.dateDue ?? .distantFuture) }
            
        case .progress:
            return tasks.sorted {
                let progress1 = $0.timer?.percentCompletion ?? $0.quantityval?.percentCompletion ?? 0
                let progress2 = $1.timer?.percentCompletion ?? $1.quantityval?.percentCompletion ?? 0
                return progress1 > progress2
            }
            
        case .newest:
            return tasks.sorted { ($0.dateCreated ?? Date()) > ($1.dateCreated ?? Date())}
            
        case .oldest:
            return tasks.sorted { ($0.dateCreated ?? Date()) < ($1.dateCreated ?? Date())}
        case .recent:
            return tasks.sorted { ($0.lastActive ?? Date()) > ($1.lastActive ?? Date())}
        }
    }

    func sortedTasksAll(allTasks: [AppTask], option: TaskSortOption) -> [AppTask] {
        let tasks = allTasks
        
        switch option {
        case .title:
              return tasks.sorted {
                  ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedAscending
              }
            
        case .zaTitle:
            return tasks.sorted {
                ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedDescending
            }
            
        case .dueDate:
            return tasks.sorted { ($0.dateDue ?? .distantFuture) < ($1.dateDue ?? .distantFuture) }
        case .progress:
            return tasks.sorted {
                let progress1 = $0.timer?.percentCompletion ?? $0.quantityval?.percentCompletion ?? 0
                let progress2 = $1.timer?.percentCompletion ?? $1.quantityval?.percentCompletion ?? 0
                return progress1 > progress2
            }

        case .newest:
            return tasks.sorted { ($0.dateCreated ?? Date()) > ($1.dateCreated ?? Date())}
            
        case .oldest:
            return tasks.sorted { ($0.dateCreated ?? Date()) < ($1.dateCreated ?? Date())}
        case .recent:
            return tasks.sorted { ($0.lastActive ?? Date()) > ($1.lastActive ?? Date())}
        }
    }
    
    func sortedTasksDate(date: Date, option: TaskSortOption) -> [AppTask] {
        let tasks = dateTasks
        
        switch option {
        case .title:
              return tasks.sorted {
                  ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedAscending
              }
            
        case .zaTitle:
            return tasks.sorted {
                ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedDescending
            }
            
        case .dueDate:
            return tasks.sorted { ($0.dateDue ?? .distantFuture) < ($1.dateDue ?? .distantFuture) }
            
        case .progress:
            return tasks.sorted {
                let progress1 = $0.timer?.percentCompletion ?? $0.quantityval?.percentCompletion ?? 0
                let progress2 = $1.timer?.percentCompletion ?? $1.quantityval?.percentCompletion ?? 0
                return progress1 > progress2
            }
            
        case .newest:
            return tasks.sorted { ($0.dateCreated ?? Date()) > ($1.dateCreated ?? Date())}
            
        case .oldest:
            return tasks.sorted { ($0.dateCreated ?? Date()) < ($1.dateCreated ?? Date())}
            
        case .recent:
            return tasks.sorted { ($0.lastActive ?? Date()) > ($1.lastActive ?? Date())}
        }
    }
    
    func generateDates(for selectedWeekdays: Set<Weekday>, until endDate: Date, usingTimeFrom baseTime: Date) -> [Date] {
        var result: [Date] = []
        var current = Date()
        let calendar = Calendar.current

        // Extract time components from baseTime (the selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: baseTime)

        while current <= endDate {
            let weekday = calendar.component(.weekday, from: current)
            if selectedWeekdays.contains(where: { $0.rawValue == weekday }) {
                let dateWithTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                                 minute: timeComponents.minute ?? 0,
                                                 second: timeComponents.second ?? 0,
                                                 of: current)
                if let finalDate = dateWithTime {
                    result.append(finalDate)
                }
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        return result
    }
    
    func lastActive(task: AppTask) {
        task.lastActive = Date()
        CoreDataManager.shared.saveContext()
    }
    
    func updateTaskTitle (task: AppTask, newTitle: String) {
        task.title = newTitle
        CoreDataManager.shared.saveContext()
    }
    
    func addDateDueToTask( task: AppTask, date: Date) {
        task.dateDue = date

        CoreDataManager.shared.saveContext()
        turnOffReminders(task: task)
        scheduleReminder(task: task)
        print("\(task.dateDue ?? Date())")
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
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
    
    func checkGoalComplete(task: AppTask) {
        
        if let goal = task.goal {
              let tasks = goal.task as? Set<AppTask> ?? []
              let allComplete = tasks.allSatisfy { $0.isComplete }
              
              if allComplete && !goal.isComplete {
                  goal.isComplete = true
                  goal.dateCompleted = Date()
                  CoreDataManager.shared.saveContext()
                  notifyGoalCompleted(goal)
              }
          }
        
    }
    
    func GoalElapsedTime(goal: Goal) {
        var totalElapsed: Double = 0.0
        var overallTime: Double = 0.0

        // Safely cast to NSSet and convert to [Task]
        guard let taskSet = goal.task else { return }
        let tasks = taskSet.compactMap { $0 as? AppTask }

        for task in tasks {
            if let timer = task.timer {
                totalElapsed += timer.elapsedTime
                overallTime += timer.countdownNum
            }

            if let quantity = task.quantityval {
                totalElapsed += quantity.timeElapsed
                overallTime += quantity.totalTimeEstimate
            }
        }

        goal.combinedElapsed = totalElapsed
        goal.overAllTimeCombined = overallTime

        let percentage = overallTime > 0 ? (totalElapsed / overallTime) * 100 : 0
        goal.percentComplete = percentage
        goal.estimatedTimeRemaining = max(0, overallTime - totalElapsed)

        CoreDataManager.shared.saveContext()
    }
    
    func goalCount(goal: Goal) {
        goal.taskCount = Int32(goal.task?.count ?? 0)
        CoreDataManager.shared.saveContext()
    }
    
    func countTasks() -> Int {
        let request = NSFetchRequest<AppTask>(entityName: "AppTask")
        
        do {
            let count = try container.viewContext.count(for: request)
            return count
        } catch {
            print("Error counting tasks: \(error)")
            return 0
        }
    }
   
    func normalizedDate(from inputDate: Date?) -> Date {
        let date = inputDate ?? Date()
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components) ?? date
    }
    
    func normalizedDateOnlyDate(from inputDate: Date?) -> Date {
        let date = inputDate ?? Date()
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 23
        components.minute = 59
        return Calendar.current.date(from: components) ?? date
    }

    func returnPercentage(number: Int, total: Int) -> String {
        guard total != 0 else { return "0%" } // avoid division by zero
        
        let percent = (Double(number) / Double(total)) * 100
        let rounded = Int(round(percent))
        
        return "\(rounded)%"
    }

    func getWeekRange(for date: Date) -> String {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        
        // Find week start (Monday) and end (Sunday)
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return ""
        }
        
        let weekday = calendar.component(.weekday, from: weekInterval.start)
        let daysToSubtract = (weekday == 1) ? 6 : weekday - 2 // Shift to Monday
        guard let monday = calendar.date(byAdding: .day, value: -daysToSubtract, to: weekInterval.start),
              let sunday = calendar.date(byAdding: .day, value: 6, to: monday) else {
            return ""
        }
        
        // Format: "MM/dd"
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        
        return "\(formatter.string(from: monday))  -  \(formatter.string(from: sunday))"
    }
    

    func turnOffReminders(task: AppTask) {
        task.reminder = false
        let id = task.objectID.uriRepresentation().absoluteString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        CoreDataManager.shared.saveContext()
    }
    
    func turnOffRemindersNoSave(task: AppTask) {
        task.reminder = false
        let id = task.objectID.uriRepresentation().absoluteString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
//        CoreDataManager.shared.saveContext()
    }
    
    func scheduleReminder(task: AppTask) {
        task.reminder = true
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = task.title ?? "\(task.title ?? "Task") due."
        content.sound = .default

        // Use the task’s dateDue as the trigger
        guard let dueDate = task.dateDue else { return }
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        // Use a unique ID, like the task’s objectID
        let request = UNNotificationRequest(identifier: task.objectID.uriRepresentation().absoluteString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
        CoreDataManager.shared.saveContext()
    }

    func scheduleReminderNoSave(task: AppTask) {
        task.reminder = true
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = task.title ?? "\(task.title ?? "Task") due."
        content.sound = .default

        // Use the task’s dateDue as the trigger
        guard let dueDate = task.dateDue else { return }
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        // Use a unique ID, like the task’s objectID
        let request = UNNotificationRequest(identifier: task.objectID.uriRepresentation().absoluteString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }

    }

    func scheduleRemindersForRepeatingTasks(task: AppTask) {
        guard let context = task.managedObjectContext,
              let seriesID = task.seriesID else {
            return
        }

        // Fetch all tasks that share the same seriesID
        let fetchRequest: NSFetchRequest<AppTask> = AppTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "seriesID == %@", seriesID as CVarArg)

        do {
            let matchingTasks = try context.fetch(fetchRequest)
            for t in matchingTasks {
                if t.reminder == false {
                  scheduleReminderNoSave(task: t)
                    print("\(t.title ?? "no title") \(t.reminder)")
                }
            }
            CoreDataManager.shared.saveContext()
            print("Reminders: \(task.reminder)")
        } catch {
            print("Failed to fetch tasks for Reminders")
        }
       
    }
    
    func cancelRemindersForRepeatingTasks(task: AppTask) {
        guard let context = task.managedObjectContext,
              let seriesID = task.seriesID else {
            return
        }

        // Fetch all tasks that share the same seriesID
        let fetchRequest: NSFetchRequest<AppTask> = AppTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "seriesID == %@", seriesID as CVarArg)

        do {
            let matchingTasks = try context.fetch(fetchRequest)
            for t in matchingTasks {
                if t.reminder == true {
                    let id = t.objectID.uriRepresentation().absoluteString
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                    t.reminder = false
                }
                print("\(t.title ?? "no title") \(t.reminder)")
            }
            CoreDataManager.shared.saveContext()
            print("Reminders: \(task.reminder)")
        } catch {
            print("Failed to fetch tasks for Reminders")
        }
       
    }
}
