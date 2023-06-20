//
//  ScheduleModel.swift
//  Tracker
//
//  Created by Павел Афанасьев on 20.06.2023.
//

import Foundation

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
        DaysOfWeek(name: "Суббота", isSelected: false),
        DaysOfWeek(name: "Воскресенье", isSelected: false),
    ]
}
