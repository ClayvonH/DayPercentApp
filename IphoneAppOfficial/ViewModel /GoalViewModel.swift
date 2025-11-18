//
//  GoalViewModel.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 7/31/25.
//
import CoreData
import Combine
import UserNotifications


class GoalViewModel: ObservableObject {
    let container = CoreDataManager.shared.container
    
    @Published var savedGoals: [Goal] = []
    @Published var dateGoals: [Goal] = []
    
    
    
    func fetchGoals() {
        let request = NSFetchRequest<Goal>(entityName: "Goal")
        print("fetched goals")
        do {
        savedGoals =  try container.viewContext.fetch(request)
        } catch let error{
            print("error fetching \(error)")
        }
        
        
    }
    
    func fetchGoalsForDate(for date: Date) {
        
        let request = NSFetchRequest<Goal>(entityName: "Goal")
        
        // Calculate the start and end of the day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) else { return }
        
        // Predicate to fetch tasks within that day
        request.predicate = NSPredicate(format: "dateDue >= %@ AND dateDue <= %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let goalsForDate = try container.viewContext.fetch(request)
            dateGoals = goalsForDate
            print("Fetched \(goalsForDate.count) tasks for \(date)")
        } catch {
            print("Error fetching tasks: \(error)")
        }
        
//        dateTasks = getTasks(for: date)
    }

    
    func addGoal(text: String, date: Date? = nil) {
        let newGoal = Goal(context: container.viewContext)
        newGoal.title = text
        
        newGoal.dateDue = date
        
        newGoal.dateCreated = Date()
        
        newGoal.lastActive = Date()
        
        CoreDataManager.shared.saveContext()
        
        print("\(newGoal.dateDue ?? Date())")
        
    }
    
    func returnGoal(text: String, date: Date? = nil) -> Goal {
        let newGoal = Goal(context: container.viewContext)
        newGoal.title = text
        
        newGoal.dateDue = date
        
        CoreDataManager.shared.saveContext()
        
        print("\(newGoal.dateDue ?? Date())")
        
        return newGoal
    }
    
    func addCompletedGoals() {
        
        let new = returnGoal(text: "test")
        let new2 = returnGoal(text: "test2")
        
        new.isComplete = true
        new2.isComplete = true
        
        CoreDataManager.shared.saveContext()
        
    }
    
    func changeTitle(goal: Goal, text: String) {
        goal.title = text
        CoreDataManager.shared.saveContext()
        
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
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
    
    func goalElapsedTimeForMonth(goal: Goal, month: Date) {
        var totalElapsed: Double = 0.0
        var overallTime: Double = 0.0

        let calendar = Calendar.current

        // Get start and end of the month
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return
        }

        // Safely cast to NSSet and convert to [Task]
        guard let taskSet = goal.task else { return }
        let tasks = taskSet.compactMap { $0 as? AppTask }

        // Only include tasks that fall inside this month
        let monthTasks = tasks.filter { task in
            if let dueDate = task.dateDue {
                return dueDate >= startOfMonth && dueDate < startOfNextMonth
            }
            return false
        }

        // Now sum elapsed/overall time
        for task in monthTasks {
            if let timer = task.timer {
                totalElapsed += timer.elapsedTime
                overallTime += timer.countdownNum
            }

            if let quantity = task.quantityval {
                totalElapsed += quantity.timeElapsed
                overallTime += quantity.totalTimeEstimate
            }
        }

        // Save results to goal (optional, since this is month-specific)
        goal.combinedElapsed = totalElapsed
        goal.overAllTimeCombined = overallTime

        let percentage = overallTime > 0 ? (totalElapsed / overallTime) * 100 : 0
        goal.percentComplete = percentage
        goal.estimatedTimeRemaining = max(0, overallTime - totalElapsed)

        CoreDataManager.shared.saveContext()
    }


    func GoalElapsedTimeUIUpdateOnly(goal: Goal ) {
        var totalElapsed: Double = 0.0
        var overAllTime: Double = 0.0
        

        if let tasks = goal.task as? Set<AppTask> {
            for task in tasks {
                if let timer = task.timer {
                    totalElapsed += timer.elapsedTime
                    overAllTime += timer.countdownNum
                    
                }
                if let quantity = task.quantityval {
                    totalElapsed += quantity.timeElapsed
                    overAllTime += quantity.totalTimeEstimate
                }
            }
        }

        goal.combinedElapsed = totalElapsed
        goal.overAllTimeCombined = overAllTime
        
        let percentage = overAllTime > 0 ? (totalElapsed / overAllTime) * 100 : 0
        goal.percentComplete = percentage
        goal.estimatedTimeRemaining = max(0, overAllTime - totalElapsed)
        

       
    }
    
    func goalElapsedTimeToggle(goal: Goal, period: String, date: Date) -> Double {
        var totalElapsed: Double = 0.0
        var overallTime: Double = 0.0

        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)

        var startDate: Date?
        var endDate: Date?

        switch period.lowercased() {
        case "week":
            var mondayCalendar = calendar
            mondayCalendar.firstWeekday = 2 // Monday start

            // Start of the week containing 'date'
            startDate = mondayCalendar.date(from: mondayCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: targetDate))
            // End of that week (7 days later)
            endDate = mondayCalendar.date(byAdding: .day, value: 7, to: startDate!)

        case "month":
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: targetDate))
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate!)

        case "year":
            startDate = calendar.date(from: calendar.dateComponents([.year], from: targetDate))
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate!)

        default: // "all"
            startDate = nil
            endDate = nil
        }

        // Loop through the goal’s tasks
        if let tasks = goal.task as? Set<AppTask> {
            for task in tasks {
                guard let dateDue = task.dateDue else { continue }

                // Include only tasks within the period range
                if let start = startDate, let end = endDate {
                    if !(dateDue >= start && dateDue < end) { continue }
                }

                if let timer = task.timer {
                    totalElapsed += timer.elapsedTime
                    overallTime += timer.countdownNum
                }
                if let quantity = task.quantityval {
                    totalElapsed += quantity.timeElapsed
                    overallTime += quantity.totalTimeEstimate
                }
            }
        }

        goal.combinedElapsed = totalElapsed
        goal.overAllTimeCombined = overallTime

        return totalElapsed
    }


    func goalElapsedTimeAll (goals: [Goal]) {
        for goal in goals {
            GoalElapsedTime(goal: goal)
        }
    }
    
    func goalTimeRemaining(goal: Goal, period: String, date: Date) -> Double {
        var totalRemaining: Double = 0.0
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)

        var startDate: Date?
        var endDate: Date?

        // Define time range based on period
        switch period.lowercased() {
        case "week":
            var mondayCalendar = calendar
            mondayCalendar.firstWeekday = 2 // Monday
            startDate = mondayCalendar.date(from: mondayCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: targetDate))
            endDate = mondayCalendar.date(byAdding: .day, value: 7, to: startDate!)

        case "month":
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: targetDate))
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate!)

        case "year":
            startDate = calendar.date(from: calendar.dateComponents([.year], from: targetDate))
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate!)

        default: // "all"
            startDate = nil
            endDate = nil
        }

        // Loop through tasks in goal
        if let tasks = goal.task as? Set<AppTask> {
            for task in tasks {
                guard let dateDue = task.dateDue else { continue }

                // Skip tasks outside the selected period
                if let start = startDate, let end = endDate {
                    if !(dateDue >= start && dateDue < end) { continue }
                }

                var taskRemaining: Double = 0.0

                // Calculate remaining for timer-based tasks
                if let timer = task.timer {
                    let remaining = max(timer.countdownNum - timer.elapsedTime, 0)
                    taskRemaining += remaining
                }

                // Calculate remaining for quantity-based tasks
                if let quantity = task.quantityval {
                    let remaining = max(quantity.totalTimeEstimate - quantity.timeElapsed, 0)
                    taskRemaining += remaining
                }

                totalRemaining += taskRemaining
            }
        }

        // Optionally store in Core Data properties if you use them elsewhere
        goal.overAllTimeCombined = totalRemaining

        return totalRemaining
    }

    
    func getGoals(for date: Date) -> [Goal] {
        let filtered = savedGoals.filter {
            if let goalDate = $0.dateDue {
                return Calendar.current.isDate(goalDate, inSameDayAs: date)
            }
            return false
        }
        print("Filtered tasks for \(date): \(filtered.map { $0.title ?? "No Title" })")
//        dailyTasks = filtered
//        print("\(dailyTasks)")
        return filtered
    }
    
    func goalCount(goal: Goal) {
        goal.taskCount = Int32(goal.task?.count ?? 0)
        CoreDataManager.shared.saveContext()
    }
    
    func removeGoalCount(goals: [Goal]) {
        for goal in goals {
            goal.taskCount = 0
            CoreDataManager.shared.saveContext()
        }
        fetchGoals()
    }
    
    func addTaskToGoal (goalr: Goal, title: String, reminders: Bool = false) {
        let newTask = AppTask(context: container.viewContext)
        let newTimer = TimerEntity(context: container.viewContext)
        newTask.title = title
        newTask.goal = goalr
        newTask.timer = newTimer
        newTask.lastActive = Date()
        newTask.reminder = reminders
        goalr.isComplete = false
        CoreDataManager.shared.saveContext()
        
        if reminders == true {
            scheduleReminder(task: newTask)
        }
        goalCount(goal: goalr)
        fetchGoals()
        
    }
    
    func addTaskToGoalTwo(goalr: Goal, title: String, dueDate: Date?, dateOnly: Bool = false, reminders: Bool = false) -> AppTask {
        
        let fetchRequest: NSFetchRequest<AppTask> = AppTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        var existingSeriesID: UUID?
        
        if let match = try? container.viewContext.fetch(fetchRequest).first {
            existingSeriesID = match.seriesID   // <-- re-use seriesID
        }
        
        
        let newTask = AppTask(context: goalr.managedObjectContext!)
        newTask.dateCreated = Date()
        newTask.title = title
        newTask.goal = goalr
        newTask.dateDue = dueDate
        newTask.dateOnly = dateOnly
        goalr.addToTask(newTask)
        newTask.lastActive = Date()
        newTask.reminder = reminders
        goalr.isComplete = false
        if let reusedID = existingSeriesID {
            newTask.seriesID = reusedID
        } else {
            newTask.seriesID = UUID()          // <-- new seriesID for first task of that title
        }

        CoreDataManager.shared.saveContext()
        if reminders == true {
            scheduleReminder(task: newTask)
        }
        fetchGoals()
        return newTask
      
    }
    
    func editDate(for goal: Goal, newDueDate: Date?) {
        goal.dateDue = newDueDate
        CoreDataManager.shared.saveContext()
    }
    
    func incompleteGoal(goal: Goal) {
        goal.isComplete = false
        goal.dateCompleted = nil
        CoreDataManager.shared.saveContext()
    }
    
    func completeGoal(goal: Goal) {
        goal.isComplete = true
        goal.dateCompleted = Date()
        CoreDataManager.shared.saveContext()
    }
    
    func completeGoalEarly(goal: Goal) {
        
        
        if let tasks = goal.task?.allObjects as? [AppTask] {
            for task in tasks {
                if task.isComplete == false {
                    if task.reminder == true {
                        let id = task.objectID.uriRepresentation().absoluteString
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                    }
                    self.deleteTask(task)
                    print("Deleted \(task.title ?? "no title")")
                    
                }
            }
            }
        goal.isComplete = true
        goal.dateCompleted = Date()
        CoreDataManager.shared.saveContext()
        
    }
    
    func completeGoalAndFinishAllTasks(goal: Goal) {
        
        
        if let tasks = goal.task?.allObjects as? [AppTask] {
            for task in tasks {
                if task.isComplete == false {
                    if task.reminder == true {
                        let id = task.objectID.uriRepresentation().absoluteString
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                    }
                    
                    
                }
            }
            }
        goal.isComplete = true
        goal.dateCompleted = Date()
        CoreDataManager.shared.saveContext()
        
    }
    
    func deleteGoal(_ goal: Goal) {
        
        
        if let tasks = goal.task?.allObjects as? [AppTask] {
                for task in tasks {
                    if task.reminder == true {
                        let id = task.objectID.uriRepresentation().absoluteString
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                    }
                    self.deleteTask(task)
                    print("Deleted \(task.title ?? "no title")")
                  
                }
            
            }
        
        let context = goal.managedObjectContext
        context?.delete(goal) // Mark the goal for deletion
        
        print("deleted \(goal.title ?? "no title")")
        CoreDataManager.shared.saveContext()
    }
    
    func deleteGoalTasks(goal: Goal) {
        
        
        if let tasks = goal.task?.allObjects as? [AppTask] {
            for task in tasks {
                if task.reminder == true {
                    let id = task.objectID.uriRepresentation().absoluteString
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                }
                self.deleteTask(task)
        
            }
                
        }
        CoreDataManager.shared.saveContext()
        print("deleted goal tasks")
        fetchGoals()
    }
    
    func deleteAllGoalsTasks(goals: [Goal]) {
        let container = CoreDataManager.shared.container
        let viewContext = container.viewContext

        container.performBackgroundTask { backgroundContext in
            for goal in goals {
                // Bring goal into background context safely
                guard let goalInContext = try? backgroundContext.existingObject(with: goal.objectID) as? Goal else { continue }

                // Delete all related tasks
                if let tasks = goalInContext.task as? Set<AppTask> {
                    for task in tasks {
                        if task.reminder == true {
                            let id = task.objectID.uriRepresentation().absoluteString
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                        }
                        backgroundContext.delete(task)
                       
                    }
                }

                // Reset goal stats
                goalInContext.taskCount = 0
                goalInContext.combinedElapsed = 0
                goalInContext.overAllTimeCombined = 0
                goalInContext.estimatedTimeRemaining = 0
                goalInContext.percentComplete = 0
            }

            do {
                try backgroundContext.save()

                // Merge changes back to main context safely
                DispatchQueue.main.async {
                    do {
                        try viewContext.save()
                        self.fetchGoals()
                    } catch {
                        print("Failed to save view context: \(error)")
                    }
                }

            } catch {
                print("Error deleting tasks or saving goals: \(error.localizedDescription)")
            }
        }
    }



    func deleteTask(_ task: AppTask) {
        let context = task.managedObjectContext
        if task.reminder == true {
            let id = task.objectID.uriRepresentation().absoluteString
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        }
        context?.delete(task) // Mark the goal for deletion
       
        CoreDataManager.shared.saveContext()
    }
    
    func calculateGoalCompletionPercentage (goal: Goal ) {
        guard let tasks = goal.task?.allObjects as? [AppTask], !tasks.isEmpty else {
               print("no tasks")
            return
           }



        let currentQuantityTime = tasks.compactMap {
            $0.quantityval?.timeElapsed
        }
        let currentTimerTime = tasks.compactMap {
            $0.timer?.elapsedTime
        }

        let totalQuantityTime = tasks.compactMap {
            $0.quantityval?.totalTimeEstimate
        }
        let totalTimerTime = tasks.compactMap {
            $0.timer?.totalTimeEstimate
        }

        let combinedTimes = currentQuantityTime + currentTimerTime

        let combinedTotalTimes = totalQuantityTime + totalTimerTime

        let currentTimeTotal = combinedTimes.reduce(0,+)

        let totalTimeTotal = combinedTotalTimes.reduce(0, +)

        let newAverage = min((currentTimeTotal / totalTimeTotal) * 100, 100)

        goal.percentComplete = newAverage



        print("goal completion percentage is \(goal.percentComplete)")



    }
    
    func sortedGoals(goals: [Goal], option: GoalSortOption) -> [Goal] {
        let goals = goals
        
        switch option {
        case .title:
              return goals.sorted {
                  ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedAscending
              }
            
        case .zaTitle:
            return goals.sorted {
                ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedDescending
            }
            
        case .dueDate:
            return goals.sorted { ($0.dateDue ?? .distantFuture) < ($1.dateDue ?? .distantFuture) }
            
        case .progress:
            return goals.sorted {
                let progress1 = $0.percentComplete
                let progress2 = $1.percentComplete 
                return progress1 > progress2
            }

        case .newest:
            return goals.sorted { ($0.dateCreated ?? Date()) > ($1.dateCreated ?? Date())}
            
        case .oldest:
            return goals.sorted { ($0.dateCreated ?? Date()) < ($1.dateCreated ?? Date())}
            
        case .recent:
            return goals.sorted { ($0.lastActive ?? Date()) > ($1.lastActive ?? Date()) }
        }
    }
    
    func sortedCompletedGoals(goals: [Goal], option: CompletedGoalSortOption) -> [Goal] {
        let goals = goals
        
        switch option {
        case .title:
              return goals.sorted {
                  ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedAscending
              }
            
        case .zaTitle:
            return goals.sorted {
                ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedDescending
            }
            
        case .dueDate:
            return goals.sorted { ($0.dateDue ?? .distantFuture) < ($1.dateDue ?? .distantFuture) }

        case .recentCompleted:
            return goals.sorted { ($0.dateCompleted ?? Date()) > ($1.dateCompleted ?? Date())}
            
        case .oldestCompletion:
            return goals.sorted { ($0.dateCompleted ?? Date()) < ($1.dateCompleted ?? Date())}
            
 
        }
    }
    
    func statGoals(goals: [Goal]) -> [Goal] {
        let goals = goals
        return goals
   
    }
//    enum CompletedGoalSortOption: String, CaseIterable, Identifiable {
//        case title = "Alphabetical"
//        case zaTitle = "Z-A Alphabetical"
//        case dueDate = "Due Date"
//        case recentCompleted = "Recent Completion"
//        case oldestCompletion = "Oldest Completion"
//       
//
//        var id: Self { self }
//
//        var displayName: String {
//            switch self {
//            case .title: return "Alphabetical"
//            case .zaTitle: return "Z-A Alphabetical"
//            case .dueDate: return "Due Date"
//            case .recentCompleted: return "Newest"
//            case .oldestCompletion: return "Oldest"
//           
//            }
//        }
//    }
    
    func lastActive(goals: [Goal]) {
       for goal in goals {
           print("\(goal.title ?? "No title") - \(goal.lastActive ?? Date())")
        }
    }
    func resetGoalInfo(goals: [Goal]) {
        for goal in goals {
            goal.taskCount = 0
            goal.combinedElapsed = 0
            goal.overAllTimeCombined = 0
            goal.estimatedTimeRemaining = 0
            goal.percentComplete = 0
        }
        CoreDataManager.shared.saveContext()
        fetchGoals()
    }
    
    func resetAllGoalsInfo() {
        let request = NSFetchRequest<Goal>(entityName: "Goal")
        do {
            let allGoals = try container.viewContext.fetch(request)
            for goal in allGoals {
                goal.taskCount = 0
                goal.combinedElapsed = 0
                goal.overAllTimeCombined = 0
                goal.estimatedTimeRemaining = 0
                goal.percentComplete = 0
            }
            CoreDataManager.shared.saveContext()
            fetchGoals()
        } catch {
            print("Error fetching goals for reset: \(error)")
        }
    }
    
    func turnOffReminders(task: AppTask) {
        task.reminder = false
        let id = task.objectID.uriRepresentation().absoluteString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        CoreDataManager.shared.saveContext()
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
    
    
    func pastDueGoalTasks(goal: Goal) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        var count = 0

        
        
        if let tasks = goal.task?.allObjects as? [AppTask] {
            for task in tasks {
                if let due = task.dateDue {
                    let dueDay = Calendar.current.startOfDay(for: due)
                    // Only count tasks that are before today (not today) and incomplete
                    if dueDay < today && !task.isComplete {
                        count += 1
                    }
                }
            }
        }
        return count 
    }
    
//    func getCompletedTasks(goal: Goal) -> Int {
//    
//        var count = 0
//
//        
//        
//        if let tasks = goal.task?.allObjects as? [AppTask] {
//            for task in tasks {
//                if task.isComplete {
//                    count += 1
//                }
//            
//            }
//        }
//        return count
//    }

    func goalCompletedTasks(goal: Goal, period: String, date: Date) -> Int {
        var completedTasks: Int = 0
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)

        var startDate: Date?
        var endDate: Date?

        // Define time range based on period
        switch period.lowercased() {
        case "week":
            var mondayCalendar = calendar
            mondayCalendar.firstWeekday = 2 // Monday
            startDate = mondayCalendar.date(from: mondayCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: targetDate))
            endDate = mondayCalendar.date(byAdding: .day, value: 7, to: startDate!)

        case "month":
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: targetDate))
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate!)

        case "year":
            startDate = calendar.date(from: calendar.dateComponents([.year], from: targetDate))
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate!)

        default: // "all"
            startDate = nil
            endDate = nil
        }

        // Loop through tasks in goal
        if let tasks = goal.task as? Set<AppTask> {
            for task in tasks {
                guard let dateDue = task.dateDue else { continue }

                // Skip tasks outside the selected period
                if let start = startDate, let end = endDate {
                    if !(dateDue >= start && dateDue < end) { continue }
                }
                
                
                if task.isComplete {
                    completedTasks += 1
                }


//                var taskRemaining: Double = 0.0
//
//                // Calculate remaining for timer-based tasks
//                if let timer = task.timer {
//                    let remaining = max(timer.countdownNum - timer.elapsedTime, 0)
//                    taskRemaining += remaining
//                }
//
//                // Calculate remaining for quantity-based tasks
//                if let quantity = task.quantityval {
//                    let remaining = max(quantity.totalTimeEstimate - quantity.timeElapsed, 0)
//                    taskRemaining += remaining
//                }
//
//                totalRemaining += taskRemaining
            }
        }

        // Optionally store in Core Data properties if you use them elsewhere

        return completedTasks
    }
    
    
    func goalTotalTasks(goal: Goal, period: String, date: Date) -> Int {
        
        var totalTasks: Int = 0
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        var startDate: Date?
        var endDate: Date?
        
        // Define time range based on period
        switch period.lowercased() {
        case "week":
            var mondayCalendar = calendar
            mondayCalendar.firstWeekday = 2 // Monday
            startDate = mondayCalendar.date(from: mondayCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: targetDate))
            endDate = mondayCalendar.date(byAdding: .day, value: 7, to: startDate!)
            
        case "month":
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: targetDate))
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate!)
            
        case "year":
            startDate = calendar.date(from: calendar.dateComponents([.year], from: targetDate))
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate!)
            
        default: // "all"
            startDate = nil
            endDate = nil
        }
        
        // Loop through tasks in goal
        if let tasks = goal.task as? Set<AppTask> {
            for task in tasks {
                guard let dateDue = task.dateDue else { continue }
                
                // Skip tasks outside the selected period
                if let start = startDate, let end = endDate {
                    if !(dateDue >= start && dateDue < end) { continue }
                }
                
                totalTasks += 1
                
                //                var taskRemaining: Double = 0.0
                //
                //                // Calculate remaining for timer-based tasks
                //                if let timer = task.timer {
                //                    let remaining = max(timer.countdownNum - timer.elapsedTime, 0)
                //                    taskRemaining += remaining
                //                }
                //
                //                // Calculate remaining for quantity-based tasks
                //                if let quantity = task.quantityval {
                //                    let remaining = max(quantity.totalTimeEstimate - quantity.timeElapsed, 0)
                //                    taskRemaining += remaining
                //                }
                //
                //                totalRemaining += taskRemaining
            }
        }
        
        // Optionally store in Core Data properties if you use them elsewhere
        
        return totalTasks
    }
}

