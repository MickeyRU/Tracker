//
//  DataManager.swift
//  Tracker
//
//  Created by Павел Афанасьев on 26.06.2023.
//

import UIKit

final class DataManager {
    static let shared = DataManager()
    
    var categories: [TrackerCategory] = [
        TrackerCategory(
            name: "Уборка",
            trackers: [
                Tracker(
                    name: "Помыть посуду",
                    color: UIColor.green,
                    emoji: "🥶",
                    schedule: [WeekDay.tuesday, WeekDay.sunday]
                ),
                Tracker(
                    name: "Погладить одежду",
                    color: UIColor.blue,
                    emoji: "🤪",
                    schedule:[WeekDay.tuesday, WeekDay.friday]
                ),
            ]
        ),
        TrackerCategory(
            name: "Сделать уроки",
            trackers: [
                Tracker(
                    name: "География",
                    color: UIColor.green,
                    emoji: "😂",
                    schedule: [WeekDay.tuesday, WeekDay.sunday]
                ),
                Tracker(
                    name: "Математика",
                    color: UIColor.blue,
                    emoji: "🥳",
                    schedule: [WeekDay.tuesday, WeekDay.friday]
                ),
            ]
        ),
    ]
}