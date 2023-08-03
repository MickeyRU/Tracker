//
//  DataProvider.swift
//  Tracker
//
//  Created by Павел Афанасьев on 13.07.2023.
//

import UIKit
import CoreData

protocol DataProviderDelegate: AnyObject {
    func didChangeContent()
}

protocol DataProviderProtocol: AnyObject {
    var numberOfSections: Int { get }
    var numberOfTrackers: Int { get }

    func numberOfRowsInSection(section: Int) -> Int
    func nameOfSection(section: Int) -> String
    
    func fetchCategory(name: String) -> TrackerCategoryCoreData?
    func createCategory(category: TrackerCategory) throws -> TrackerCategoryCoreData
    
    func addTracker(tracker: Tracker, trackerCategoryCoreData: TrackerCategoryCoreData) throws
    func getTrackerCoreData(indexPath: IndexPath) -> TrackerCoreData
    func getTrackerObject(indexPath: IndexPath) -> Tracker?
    
    func addNewTrackerRecord(trackerRecord: TrackerRecord, trackerCoreData: TrackerCoreData) throws
    func deleteRecord(date: Date, trackerID: String) throws
    func countRecordForTracker(trackerID: String) -> Int
    func trackerTrackedToday(date: Date, trackerID: String) -> Bool
    
    func addFiltersForFetchResultController(searchText: String, date: Date) throws
    
    func setUpDelegates(trackersViewController: TrackersViewController)
}

final class DataProvider: NSObject {
    weak var delegate: DataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordsStore: TrackerRecordStoreProtocol
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: #keyPath(TrackerCoreData.category.name),
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        return fetchedResultsController
    }()
    
    init(trackerStore: TrackerStoreProtocol,
         trackerRecordsStore: TrackerRecordStoreProtocol,
         trackerCategoryStore: TrackerCategoryStoreProtocol,
         delegate: DataProviderDelegate?) {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordsStore = trackerRecordsStore
        self.delegate = delegate
    }
}

extension DataProvider: DataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    var numberOfTrackers: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }

    
    func numberOfRowsInSection(section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func nameOfSection(section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }
    
    func fetchCategory(name: String) -> TrackerCategoryCoreData? {
        trackerCategoryStore.fetchCategory(name: name)
    }
    
    func createCategory(category: TrackerCategory) throws -> TrackerCategoryCoreData {
        do {
            let newCategory = try trackerCategoryStore.createCategory(category: category)
            return newCategory
        } catch {
            fatalError("Failed to create new category: \(error)")
        }
    }
    
    func addTracker(tracker: Tracker, trackerCategoryCoreData: TrackerCategoryCoreData) throws {
        do {
            try trackerStore.add(tracker: tracker, trackerCategoryCoreData: trackerCategoryCoreData)
        } catch {
            fatalError("Failed to addTracker: \(error)")
        }
    }
    
    func getTrackerObject(indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        guard let tracker = try? trackerStore.tracker(from: trackerCoreData) else { return nil }
        return tracker
    }
    
    func getTrackerCoreData(indexPath: IndexPath) -> TrackerCoreData {
        fetchedResultsController.object(at: indexPath)
    }
    
    func addNewTrackerRecord(trackerRecord: TrackerRecord, trackerCoreData: TrackerCoreData) throws {
        do {
            try trackerRecordsStore.add(newRecord: trackerRecord, for: trackerCoreData)
        } catch {
            fatalError("Failed to addTrackerRecord: \(error)")
        }
    }
    
    func deleteRecord(date: Date, trackerID: String) throws {
        do {
            try trackerRecordsStore.deleteRecord(date: date, trackerID: trackerID)
        } catch {
            fatalError("Failed to deleteTrackerRecord: \(error)")
        }
    }
    
    func countRecordForTracker(trackerID: String) -> Int {
        trackerRecordsStore.countRecordForTracker(trackerID: trackerID)
    }
    
    func trackerTrackedToday(date: Date, trackerID: String) -> Bool {
        trackerRecordsStore.trackerTrackedToday(date: date, trackerID: trackerID)
    }
    
    func addFiltersForFetchResultController(searchText: String, date: Date) throws {
        let dayNumber = WeekDay.getWeekDayInNumber(for: date)

        var predicates: [NSPredicate] = []
        let predicateForDate = NSPredicate(format: "%K CONTAINS[n] %@",
                                           #keyPath(TrackerCoreData.schedule), dayNumber)
        predicates.append(predicateForDate)
        
        if !searchText.isEmpty {
            let predicateForSearchText = NSPredicate(format: "%K CONTAINS[n] %@",
                                                     #keyPath(TrackerCoreData.name), searchText)
            predicates.append(predicateForSearchText)
        }
        
        do {
            fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch data with Predicates in method addFiltersForFetchResultController: \(error)")
        }
    }
    
    func setUpDelegates(trackersViewController: TrackersViewController) {
        self.delegate = trackersViewController
        self.trackerRecordsStore.delegate = trackersViewController
    }
}

extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didChangeContent()
    }
}
