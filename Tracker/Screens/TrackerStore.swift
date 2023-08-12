//
//  TrackerStore.swift
//  Tracker
//
//  Created by Павел Афанасьев on 13.07.2023.
//

import UIKit
import CoreData

protocol TrackerStoreProtocol: AnyObject {
    func fetchTracker(id: String) -> TrackerCoreData?
    func addTracker(tracker: Tracker, trackerCategoryCoreData: TrackerCategoryCoreData) throws
    func deleteTracker(trackerCoreData: TrackerCoreData) throws
    func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker
    func updateTracker(trackerCoreData: TrackerCoreData, trackerCategoryCoreData: TrackerCategoryCoreData) throws
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    
    override init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}

extension TrackerStore: TrackerStoreProtocol {
    func fetchTracker(id: String) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest() as NSFetchRequest<TrackerCoreData>
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), id)
        do {
            let trackers = try context.fetch(request)
            if let firstTracker = trackers.first {
                return firstTracker
            } else {
                return nil
            }
        } catch {
            print("Ошибка при выполнении запроса: \(error.localizedDescription)")
            return nil
        }
    }

    func addTracker(tracker: Tracker, trackerCategoryCoreData: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerID = tracker.id.uuidString
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = UIColor.hexString(from: tracker.color)
        let scheduleString = tracker.schedule.map { $0.numberValue }
        trackerCoreData.schedule = scheduleString.map(String.init).joined(separator: ", ")
        trackerCoreData.category = trackerCategoryCoreData
        trackerCoreData.isPinned = tracker.isPinned
        try context.save()
    }
    
    func deleteTracker(trackerCoreData: TrackerCoreData) throws {
        context.delete(trackerCoreData)
        try context.save()
    }
    
    func updateTracker(trackerCoreData: TrackerCoreData, trackerCategoryCoreData: TrackerCategoryCoreData) throws {
        trackerCoreData.category = trackerCategoryCoreData
        try context.save()
    }
    
    func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let emojies = trackerCoreData.emoji else {
            fatalError("Error with emoji")
        }
        guard let colorHex = trackerCoreData.colorHex else {
            fatalError("Error with colorHex")
        }
        guard let trackerID = trackerCoreData.trackerID else {
            fatalError("Error with trackerID")
        }
        guard let trackerUUID = UUID(uuidString: trackerID) else {
            fatalError("Error with UUID")
        }
        guard let name = trackerCoreData.name else {
            fatalError("Error with name")
        }
        guard let scheduleString = trackerCoreData.schedule else {
            fatalError("Error with scheduleString")
        }
        
        // Разделим строку на отдельные числа, используя разделитель
        let numbersArray = scheduleString.components(separatedBy: ", ")

        // Преобразуйте каждое число в элемент перечисления WeekDay
        let schedule: [WeekDay] = numbersArray.compactMap { numberString in
            if let number = Int(numberString) {
                // Проверяем, существует ли элемент перечисления WeekDay с соответствующим числовым значением
                return WeekDay.allCases.first { $0.numberValue == number }
            }
            return nil
        }
        
        return Tracker(id: trackerUUID,
                       name: name,
                       color: UIColor.color(fromHex: colorHex),
                       emoji: emojies,
                       schedule: schedule,
                       isPinned: trackerCoreData.isPinned)
    }
}
