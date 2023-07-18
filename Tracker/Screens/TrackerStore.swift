//
//  TrackerStore.swift
//  Tracker
//
//  Created by Павел Афанасьев on 13.07.2023.
//

import UIKit
import CoreData

protocol TrackerStoreProtocol: AnyObject {
    func add(tracker: Tracker, trackerCategoryCoreData: TrackerCategoryCoreData) throws
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    
    override init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}

extension TrackerStore: TrackerStoreProtocol {
    func add(tracker: Tracker, trackerCategoryCoreData: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id.uuidString
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.toHexString
        let scheduleString = tracker.schedule.map { $0.numberValue }
        trackerCoreData.schedule = scheduleString.map(String.init).joined(separator: ", ")
        trackerCoreData.category = trackerCategoryCoreData
        try context.save()
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let emojies = trackerCoreData.emoji else {
            fatalError("Error with emoji")
        }
        guard let colorHex = trackerCoreData.color else {
            fatalError("Error with colorHex")
        }
        guard let trackerID = trackerCoreData.id else {
            fatalError("Error with trackerID")
        }
        guard let name = trackerCoreData.name else {
            fatalError("Error with name")
        }
        guard let scheduleString = trackerCoreData.schedule else {
            fatalError("Error with scheduleString")
        }
        
        let weekdaysString = "2, 4, 6"

        // Разделим строку на отдельные числа, используя разделитель
        let numbersArray = weekdaysString.components(separatedBy: ", ")

        // Преобразуйте каждое число в элемент перечисления WeekDay
        let schedule: [WeekDay] = numbersArray.compactMap { numberString in
            if let number = Int(numberString) {
                // Проверяем, существует ли элемент перечисления WeekDay с соответствующим числовым значением
                return WeekDay.allCases.first { $0.numberValue == number }
            }
            return nil
        }

        return Tracker(id: UUID(uuidString: trackerID)!,
                       name: name,
                       color: UIColor.color(fromHex: colorHex),
                       emoji: emojies,
                       schedule: schedule)
    }
}
