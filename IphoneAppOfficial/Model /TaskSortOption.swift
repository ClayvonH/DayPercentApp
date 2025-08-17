//
//  TaskSortOption.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 7/31/25.
//

enum TaskSortOption: String, CaseIterable, Identifiable {
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
