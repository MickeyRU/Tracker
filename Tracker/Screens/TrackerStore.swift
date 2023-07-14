//
//  TrackerStore.swift
//  Tracker
//
//  Created by Павел Афанасьев on 13.07.2023.
//

import UIKit
import CoreData

protocol TrackerStoreProtocol: AnyObject {
    func saveTracker(tracker: Tracker, in category: TrackerCategoryCoreData) throws
    func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    
    private enum TrackerStoreError: Error {
        case decodingErrorInvalidEmoji
        case decodingErrorInvalidColor
        case decodingErrorInvalidID
        case decodingErrorInvalidName
        case decodingErrorInvalidSchedule
    }
    
    override init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}

extension TrackerStore: TrackerStoreProtocol {
    func saveTracker(tracker: Tracker, in category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerID = tracker.id.uuidString
        trackerCoreData.category = category
        trackerCoreData.color = tracker.color.toHexString
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        let scheduleString = tracker.schedule.map { $0.dayName }.joined(separator: ",")
        trackerCoreData.schedule = scheduleString
        try context.save()
    }
    
    func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.trackerID else {
            throw TrackerStoreError.decodingErrorInvalidID
        }
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidName
        }
        guard let color = trackerCoreData.color else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        guard let schedule = trackerCoreData.schedule else {
            throw TrackerStoreError.decodingErrorInvalidSchedule
        }
        
        let scheduleArray = schedule.components(separatedBy: ",").compactMap { dayName -> WeekDay? in
            return WeekDay.allCases.first { $0.dayName == dayName }
        }
        
        return Tracker(id: UUID(uuidString: id)!,
                       name: name,
                       color: UIColor.color(fromHex: color),
                       emoji: emoji,
                       schedule: scheduleArray
        )
    }
}
