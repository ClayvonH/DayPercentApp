//
//  Weekday.swift
//  IphoneAppOfficial
//
//  Created by Clayvon Hatton on 8/2/25.
//

enum Weekday: Int, CaseIterable, Identifiable, Codable, Hashable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tues"
        case .wednesday: return "Wed"
        case .thursday: return "Thur"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
}
