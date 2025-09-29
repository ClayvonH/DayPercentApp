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
        let tasks = taskSet.compactMap { $0 as? Task }

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
        let tasks = taskSet.compactMap { $0 as? Task }

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
        

        if let tasks = goal.task as? Set<Task> {
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
    
    func goalElapsedTimeAll (goals: [Goal]) {
        for goal in goals {
            GoalElapsedTime(goal: goal)
        }
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
    
    func addTaskToGoal (goalr: Goal, title: String) {
        let newTask = Task(context: container.viewContext)
        let newTimer = TimerEntity(context: container.viewContext)
        newTask.title = title
        newTask.goal = goalr
        newTask.timer = newTimer
        newTask.lastActive = Date()
        goalr.isComplete = false
        CoreDataManager.shared.saveContext()
        goalCount(goal: goalr)
        fetchGoals()
        
    }
    
    func addTaskToGoalTwo(goalr: Goal, title: String, dueDate: Date?, dateOnly: Bool = false) -> Task {
        let newTask = Task(context: goalr.managedObjectContext!)
        newTask.dateCreated = Date()
        newTask.title = title
        newTask.goal = goalr
        newTask.dateDue = dueDate
        newTask.dateOnly = dateOnly
        goalr.addToTask(newTask)
        newTask.lastActive = Date()
        goalr.isComplete = false
        CoreDataManager.shared.saveContext()
        fetchGoals()
        return newTask
      
    }
    
    func editDate(for goal: Goal, newDueDate: Date?) {
        goal.dateDue = newDueDate
        CoreDataManager.shared.saveContext()
    }
    
    func completeGoal(goal: Goal) {
        goal.isComplete = true
        goal.dateCompleted = Date()
        CoreDataManager.shared.saveContext()
    }
    
    
    
    func deleteGoal(_ goal: Goal) {
        
        
        if let tasks = goal.task?.allObjects as? [Task] {
                for task in tasks {
                    self.deleteTask(task)
                    print("Deleted \(task.title ?? "no title")")
                }
            
            }
        
        let context = goal.managedObjectContext
        context?.delete(goal) // Mark the goal for deletion
        
        print("deleted \(goal.title ?? "no title")")
        CoreDataManager.shared.saveContext()
    }
    
    func deleteTask(_ task: Task) {
        let context = task.managedObjectContext
        context?.delete(task) // Mark the goal for deletion
        
        CoreDataManager.shared.saveContext()
    }
    
    func calculateGoalCompletionPercentage (goal: Goal ) {
        guard let tasks = goal.task?.allObjects as? [Task], !tasks.isEmpty else {
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
}
