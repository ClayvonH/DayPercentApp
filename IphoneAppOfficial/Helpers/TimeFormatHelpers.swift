//
//  TimeFormatHelpers.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/2/25.
//

import Foundation
//
//extension Double {
//    func asHoursMinutesSeconds() -> String {
//        let totalSeconds = Int(self)
//        let hours = totalSeconds / 3600
//        let minutes = (totalSeconds % 3600) / 60
//        let seconds = totalSeconds % 60
//
//        if hours > 0 {
//            return String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
//        } else {
//            return String(format: "%02dm %02ds", minutes, seconds)
//        }
//    }
//}
//

    extension Double {
        func asHoursMinutesSeconds() -> String {
            
            
            let totalSeconds = Int(self)
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            
           
            
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else if minutes > 0 {
                return String(format: "%d:%02d", minutes, seconds)
            } else {
                return String(format: "0:%02d", seconds)
            }
        }
    }


extension Double {
    func asHoursMinutesSecondsWithLabels() -> String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        var components: [String] = []

        if hours > 0 {
            components.append("\(hours)h")
        }
        if minutes > 0 || hours > 0 {
            components.append("\(minutes)m")
        }
        components.append("\(seconds)s")

        return components.joined(separator: " ")
    }
}


extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}

extension  Date {
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
}
