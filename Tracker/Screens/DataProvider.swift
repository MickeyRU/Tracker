//
//  DataProvider.swift
//  Tracker
//
//  Created by Павел Афанасьев on 13.07.2023.
//

import UIKit
import CoreData

protocol DataProviderDelegate: AnyObject {
    func trackersStoreDidUpdate()
}

protocol DataProviderProtocol: AnyObject {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(section: Int) -> Int
    func nameOfSection(section: Int) -> String
    
    func addTracker(tracker: Tracker, category: TrackerCategoryCoreData) throws
    func addCategory(category: TrackerCategory) throws -> TrackerCategoryCoreData
    func addTrackerRecord(trackerRecord: TrackerRecord, for tracker: TrackerCoreData) throws
    func deleteRecord(date: Date, trackerID: String)
    
    func getTrackerCoreData(at indexPath: IndexPath) -> TrackerCoreData
    func getTrackerObject(at indexPath: IndexPath) -> Tracker?
}

final class DataProvider: NSObject {
    weak var delegate: DataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordsStore: TrackerRecordStoreProtocol
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.category, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: #keyPath(TrackerCoreData.category.name),
                                                                  cacheName: nil)
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
   private enum StoreErrors: Error {
        case badRequestToDB
        case failedToInitializeContext
        case addElementToDBError(Error)
        case readElementFromDBError(Error)
        case saveContextError
    }
    
    init(trackerStore: TrackerStore, trackerCategoryStore: TrackerCategoryStore, trackerRecordsStore: TrackerRecordStore, delegate: DataProviderDelegate) {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordsStore = trackerRecordsStore
        self.delegate = delegate
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func nameOfSection(section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }
    
    func addTracker(tracker: Tracker, category: TrackerCategoryCoreData) throws {
        do {
            try trackerStore.saveTracker(tracker: tracker, in: category)
        } catch {
            throw StoreErrors.addElementToDBError(error)
        }
    }
    
    func addCategory(category: TrackerCategory) throws -> TrackerCategoryCoreData {
        do {
            let newCategory = try trackerCategoryStore.addCategory(trackerCategory: category)
            return newCategory
        } catch {
            throw StoreErrors.addElementToDBError(error)
        }
    }
    
    func addTrackerRecord(trackerRecord: TrackerRecord, for tracker: TrackerCoreData) throws {
        do {
            try trackerRecordsStore.addRecord(trackerRecord: trackerRecord, for: tracker)
        } catch {
            throw StoreErrors.addElementToDBError(error)
        }
    }
    
    func deleteRecord(date: Date, trackerID: String) {
        trackerRecordsStore.deleteRecord(date: date, trackerID: trackerID)
    }
    
    func getTrackerCoreData(at indexPath: IndexPath) -> TrackerCoreData {
        fetchedResultsController.object(at: indexPath)
    }
    
    func getTrackerObject(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        guard let tracker = try? trackerStore.getTracker(from: trackerCoreData) else {
            return nil
        }
        return tracker
    }
}


// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
    
}
