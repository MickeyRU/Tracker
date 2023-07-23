//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Павел Афанасьев on 13.07.2023.
//

import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords(completedTrackers: [TrackerRecord])
}

protocol TrackerRecordStoreProtocol: AnyObject {
    var delegate: TrackerRecordStoreDelegate? { get set }
    func add(newRecord: TrackerRecord, for trackerCoreData: TrackerCoreData?) throws
    func deleteRecord(date: Date, trackerID: String) throws
    
    func countRecordForTracker(trackerID: String) -> Int
    func trackerTrackedToday(date: Date, trackerID: String) -> Bool
}

final class TrackerRecordStore: NSObject {
    weak var delegate: TrackerRecordStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var completedTrackers: [TrackerRecord] = []
    
    init(delegate: TrackerRecordStoreDelegate?) {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.delegate = delegate
    }
}

extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func add(newRecord: TrackerRecord, for trackerCoreData: TrackerCoreData?) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.trackerID = newRecord.trackerID.uuidString
        trackerRecordCoreData.date = newRecord.date
        trackerRecordCoreData.tracker = trackerCoreData
        try context.save()
        completedTrackers.append(newRecord)
        delegate?.didUpdateRecords(completedTrackers: completedTrackers)
    }
    
    func deleteRecord(date: Date, trackerID: String) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.trackerID), trackerID,
                                        #keyPath(TrackerRecordCoreData.date), date as NSDate
        )
        guard let recordsForTacker = try? context.fetch(request) else { return }
        recordsForTacker.forEach { trackerRecordCoreData in
            context.delete(trackerRecordCoreData)
        }
        try context.save()
        completedTrackers.removeAll()
        delegate?.didUpdateRecords(completedTrackers: completedTrackers)
    }
    
    func countRecordForTracker(trackerID: String) -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = true
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerRecordCoreData.trackerID), trackerID)
        guard let recordCount = try? context.fetch(request) else { return 0 }
        return recordCount.count
    }
    
    func trackerTrackedToday(date: Date, trackerID: String) -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.trackerID), trackerID,
                                        #keyPath(TrackerRecordCoreData.date), date as NSDate
        )
        guard let recordsForTacker = try? context.fetch(request) else { return false }
        return !recordsForTacker.isEmpty
   }
}
