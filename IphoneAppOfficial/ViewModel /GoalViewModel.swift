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
    
    
    func fetchGoals() {
        let request = NSFetchRequest<Goal>(entityName: "Goal")
        print("fetched goals")
        do {
        savedGoals =  try container.viewContext.fetch(request)
        } catch let error{
            print("error fetching \(error)")
        }
        
        
    }
    
    func addGoal(text: String, date: Date? = nil) {
        let newGoal = Goal(context: container.viewContext)
        newGoal.title = text
        
        newGoal.dateDue = date
        
        CoreDataManager.shared.saveContext()
        
        print("\(newGoal.dateDue ?? Date())")
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
    
    func addTaskToGoal (goalr: Goal, title: String) {
        let newTask = Task(context: container.viewContext)
        let newTimer = TimerEntity(context: container.viewContext)
        newTask.title = title
        newTask.goal = goalr
        newTask.timer = newTimer
        newTask.lastActive = Date()
        CoreDataManager.shared.saveContext()
        
    }
    
    func addTaskToGoalTwo(goalr: Goal, title: String, dueDate: Date?) -> Task {
        let newTask = Task(context: goalr.managedObjectContext!)
        newTask.dateCreated = Date()
        newTask.title = title
        newTask.goal = goalr
        newTask.dateDue = dueDate
        goalr.addToTask(newTask)
        newTask.lastActive = Date()
        CoreDataManager.shared.saveContext()
        return newTask
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
}
