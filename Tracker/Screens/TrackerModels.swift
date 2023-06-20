//
//  TrackerModels.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

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
