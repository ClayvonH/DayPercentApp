//
//  GoalSortOption.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 9/22/25.
//

enum GoalSortOption: String, CaseIterable, Identifiable {
    case recent = "Recent"
    case title = "Alphabetical"
    case zaTitle = "Z-A Alphabetical"
    case dueDate = "Due Date"
    case progress = "Progress"
    case newest = "Newest"
    case oldest = "Oldest"
   

    var id: Self { self }

    var displayName: String {
        switch self {
        case .recent: return "Recent"
        case .title: return "Alphabetical"
        case .zaTitle: return "Z-A Alphabetical"
        case .dueDate: return "Due Date"
        case .progress: return "Progress"
        case .newest: return "Newest"
        case .oldest: return "Oldest"
       
        }
    }
}


enum CompletedGoalSortOption: String, CaseIterable, Identifiable {
    case title = "Alphabetical"
    case zaTitle = "Z-A Alphabetical"
    case dueDate = "Due Date"
    case recentCompleted = "Recent Completion"
    case oldestCompletion = "Oldest Completion"
   

    var id: Self { self }

    var displayName: String {
        switch self {
        case .title: return "Alphabetical"
        case .zaTitle: return "Z-A Alphabetical"
        case .dueDate: return "Due Date"
        case .recentCompleted: return "Recent Completion"
        case .oldestCompletion: return "Oldest Completion"
       
        }
    }
}
