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
    
    @Published var savedTasks: [Task] = []
    @Published var dailyTasks: [Task] = []
    
    
    
    let container = CoreDataManager.shared.container
    
    
    
    func fetchTasks() {
        let taskrequest = NSFetchRequest<Task>(entityName: "Task")
        

        do {
            
            savedTasks = try container.viewContext.fetch(taskrequest)
            dailyTasks = getTasks(for: Date()) // <- Refresh dailyTasks here
            print("fetched tasks")
        } catch let error {
            print("error fetching \(error)")
        }
        
        
        
    }
    
    
    
    func getTasks(for date: Date) -> [Task] {
        let filtered = savedTasks.filter {
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
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            fetchTasks() // This now uses the same context
        } catch {
            print("Error deleting tasks: \(error.localizedDescription)")
        }
    }
    
    func completeTask(task: Task) {
        if let timer = task.timer {
          
            timer.elapsedTime = timer.countdownNum
            timer.percentCompletion = 100
            timer.countdownTimer = 0
            task.isComplete = true
          
            
            CoreDataManager.shared.saveContext()
        }
        
        else if let quantity = task.quantityval {
            incrementQuantityVal(task: task, incVal: quantity.totalQuantity)
            task.isComplete = true
            CoreDataManager.shared.saveContext()
        } else {
            task.isComplete = true
            CoreDataManager.shared.saveContext()
        }
    }
    
    func completeTaskEarly(task: Task) {
        if let timer = task.timer {
            timer.countdownNum = timer.elapsedTime
            timer.countdownTimer = 0
            timer.percentCompletion = 100
            task.isComplete = true
            CoreDataManager.shared.saveContext()
        }
        
        if let quantity = task.quantityval {
            quantity.totalQuantity = quantity.currentQuantity
            incrementQuantityVal(task: task, incVal: quantity.currentQuantity)
            quantity.totalTimeEstimate = quantity.timeElapsed
            
          
            task.isComplete = true
           CoreDataManager.shared.saveContext()
        }
    }
    
    func createTaskAndReturn (title: String, dueDate: Date?) -> Task {
        let newTask = Task(context: container.viewContext)
        newTask.dateCreated = Date()
        newTask.title = title
        newTask.dateDue = dueDate
        newTask.lastActive = Date()
        CoreDataManager.shared.saveContext()
        return newTask
    }
    
    func createTask(title: String, date: Date?) {
        let newTask = Task(context: container.viewContext)
        newTask.dateCreated = Date()
        newTask.dateDue = date
        newTask.title = title
        CoreDataManager.shared.saveContext()
        
    }
    
    func addTimerToTask (task: Task) {
        let newTimer = TimerEntity(context: container.viewContext)
        task.timer = newTimer
        CoreDataManager.shared.saveContext()
    }
    
    func addMultipleTimers(task: Task) {
        guard let taskTitle = task.title else { return }

        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
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
    
    func addMultipleCountdownTimers(task: Task, seconds: Double, minutes: Double, hours: Double) {
        guard let taskTitle = task.title else { return }

        let totalSeconds = (hours * 60 * 60) + (minutes * 60) + seconds

        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
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
    
    func repeatTask(task: Task, dates: [Date]) {
        for date in dates {
            let newTask = Task(context: container.viewContext)
            newTask.repeating = true
            newTask.title = task.title
            newTask.goal = task.goal
            newTask.dateCreated = Date()
            newTask.dateDue = date
            newTask.lastActive = Date()
        }
        CoreDataManager.shared.saveContext()
        fetchTasks()
    }


    func repeatingTrue (task: Task) {
        task.repeating = true
        CoreDataManager.shared.saveContext()
    }
    
    func deleteTask(_ task: Task) {
        let context = task.managedObjectContext
        context?.delete(task) // Mark the goal for deletion
        CoreDataManager.shared.saveContext()
        fetchTasks()
    }
    
    func deleteMultipleTasks(task: Task) {
        guard let context = task.managedObjectContext,
              let title = task.title else {
            return
        }

        // Fetch all tasks with the same title
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)

        do {
            let matchingTasks = try context.fetch(fetchRequest)
            for task in matchingTasks {
                if task.isComplete == false {
                    context.delete(task)
                }
            }
            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to fetch tasks for deletion: \(error)")
        }
        fetchTasks()
    }
    
    func addQuantityVal( task: Task, qVal: Double ) {

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
    
    func addMultipleQuantityVals(task: Task, qVal: Double) {
        guard let taskTitle = task.title else { return }

        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
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
    
    func getQuantityPercentage(task: Task) {
        let total = task.quantityval?.totalQuantity ?? 0
        let current = task.quantityval?.currentQuantity ?? 0
       // let timePer = task.quantityval?.timePerQuantityVal ?? 0

        task.quantityval?.percentCompletion = min((current / total) * 100, 100)
    }
    
    func incrementQuantityVal( task: Task, incVal: Double) {
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
        print("estimated time elapsed is \(task.quantityval?.timeElapsed ?? 0)")
        print("total time combined for quantity is \(task.quantityval?.totalTimeEstimate ?? 0)")
        print("estimated time remaining for quantity is \(task.quantityval?.estimatedTimeRemaining ?? 0)")
        
        task.lastActive = Date()
        getQuantityPercentage(task: task)
        CoreDataManager.shared.saveContext()
    }
    
    func timeEstimatePerQuantity ( task: Task, hours: Double, minutes: Double, seconds: Double) {
        task.quantityval?.timePerQuantityVal = (hours * 60 * 60) + (minutes * 60) + seconds
        task.quantityval?.totalTimeEstimate = (task.quantityval?.totalQuantity ?? 0) * (task.quantityval?.timePerQuantityVal ?? 0)
        task.quantityval?.timeElapsed = (task.quantityval?.currentQuantity ?? 0) * (task.quantityval?.timePerQuantityVal ?? 0)
        showQuantityValData(task: task)
        print(" time per val \(task.quantityval?.timePerQuantityVal ?? 0)")
        showQuantityValData(task: task)
        CoreDataManager.shared.saveContext()


    }
    
    func timeEstimatePerQuantityMultiple(task: Task, hours: Double, minutes: Double, seconds: Double) {
        guard let taskTitle = task.title else { return }

        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
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
    
    func showQuantityValData ( task: Task ) {

        let total = task.quantityval?.totalQuantity ?? 0
        let current = task.quantityval?.currentQuantity ?? 0
        let timePer = task.quantityval?.timePerQuantityVal ?? 0

        task.quantityval?.estimatedTimeRemaining = (total - current) * timePer

        print("Estimated time remaining is \(task.quantityval?.estimatedTimeRemaining ?? 0)")

        task.quantityval?.percentCompletion = min((current / total) * 100, 100)


        CoreDataManager.shared.saveContext()
    }
    
    func sortedTasks(goal: Goal, option: TaskSortOption) -> [Task] {
        let tasks = (goal.task as? Set<Task>) ?? []
        
        switch option {
        case .title:
            return tasks.sorted { ($0.title ?? "") < ($1.title ?? "") }
            
        case .zaTitle:
            return tasks.sorted { ($0.title ?? "") > ($1.title ?? "") }
            
        case .dueDate:
            return tasks.sorted { ($0.dateDue ?? .distantFuture) < ($1.dateDue ?? .distantFuture) }
        case .progress:
            return tasks.sorted { ($0.timer?.percentCompletion ?? 0) > ($1.timer?.percentCompletion ?? 0) }
        case .newest:
            return tasks.sorted { ($0.dateCreated ?? Date()) > ($1.dateCreated ?? Date())}
            
        case .oldest:
            return tasks.sorted { ($0.dateCreated ?? Date()) < ($1.dateCreated ?? Date())}
        case .recent:
            return tasks.sorted { ($0.lastActive ?? Date()) > ($1.lastActive ?? Date())}
        }
    }

    func sortedTasksAll(allTasks: [Task], option: TaskSortOption) -> [Task] {
        let tasks = allTasks
        
        switch option {
        case .title:
            return tasks.sorted { ($0.title ?? "") < ($1.title ?? "") }
            
        case .zaTitle:
            return tasks.sorted { ($0.title ?? "") > ($1.title ?? "") }
            
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
    
    func lastActive(task: Task) {
        task.lastActive = Date()
        CoreDataManager.shared.saveContext()
    }
    
    func updateTaskTitle (task: Task, newTitle: String) {
        task.title = newTitle
        CoreDataManager.shared.saveContext()
    }
    
    func addDateDueToTask( task: Task, date: Date) {
        task.dateDue = date

        CoreDataManager.shared.saveContext()
        print("\(task.dateDue ?? Date())")
    }
}
