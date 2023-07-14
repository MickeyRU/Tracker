//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Павел Афанасьев on 13.07.2023.
//

import UIKit
import CoreData

protocol TrackerRecordStoreProtocol {
    func addRecord(trackerRecord: TrackerRecord, for tracker: TrackerCoreData) throws
    func deleteRecord(date: Date, trackerID: String)
    func trackerTrackedToday(date: Date, trackerID: String) -> Bool
    func countRecordForTracker(trackerID: String) -> Int
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
    override init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}

extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func addRecord(trackerRecord: TrackerRecord, for tracker: TrackerCoreData) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = trackerRecord.date
        trackerRecordCoreData.tracker = tracker
        try context.save()
    }
    
    func deleteRecord(date: Date, trackerID: String) {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.tracker.trackerID), trackerID,
                                        #keyPath(TrackerRecordCoreData.date), date as NSDate
        )
        guard let recordsForTacker = try? context.fetch(request) else { return }
        recordsForTacker.forEach { trackerRecordCoreData in
            context.delete(trackerRecordCoreData)
        }
    }
    
    func trackerTrackedToday(date: Date, trackerID: String) -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.tracker.trackerID), trackerID,
                                        #keyPath(TrackerRecordCoreData.date), date as NSDate
        )
        guard let recordsForTacker = try? context.fetch(request) else { return false }
        return !recordsForTacker.isEmpty    }
    
    func countRecordForTracker(trackerID: String) -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = true
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerRecordCoreData.tracker.trackerID), trackerID
        )
        guard let recordCount = try? context.fetch(request) else { return 0 }
        return recordCount.count
    }
}
