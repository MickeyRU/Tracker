//
//  TrackerModels.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

struct DaysOfWeek {
    let name: String
    var isSelected: Bool
}

struct WeekSchedule {
    var daysOfWeek = [
        DaysOfWeek(name: "Понедельник", isSelected: false),
        DaysOfWeek(name: "Вторник", isSelected: false),
        DaysOfWeek(name: "Среда", isSelected: false),
        DaysOfWeek(name: "Четверг", isSelected: false),
        DaysOfWeek(name: "Пятница", isSelected: false),
        DaysOfWeek(name: "Суббота", isSelected: false)
    ]
}

struct Tracker {
    let id: UUID = UUID()
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: WeekSchedule
}

struct TrackerCategory {
    let name: String
    let trackers: [Tracker]
}

struct TrackerRecord: Hashable {
    let id: UUID
    let date: Date
}


