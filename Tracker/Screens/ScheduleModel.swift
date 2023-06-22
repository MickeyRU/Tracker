//
//  ScheduleModel.swift
//  Tracker
//
//  Created by Павел Афанасьев on 20.06.2023.
//

import Foundation

struct DaysOfWeek {
    let name: String
    var isCompleted: Bool
}

struct WeekSchedule {
    var daysOfWeek = [
        DaysOfWeek(name: "Понедельник", isCompleted: false),
        DaysOfWeek(name: "Вторник", isCompleted: false),
        DaysOfWeek(name: "Среда", isCompleted: false),
        DaysOfWeek(name: "Четверг", isCompleted: false),
        DaysOfWeek(name: "Пятница", isCompleted: false),
        DaysOfWeek(name: "Суббота", isCompleted: false),
        DaysOfWeek(name: "Воскресенье", isCompleted: false),
    ]
}
