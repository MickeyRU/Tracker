//
//  DataProvider.swift
//  Tracker
//
//  Created by Павел Афанасьев on 13.07.2023.
//

import UIKit
import CoreData

protocol DataProviderProtocol: AnyObject {
    var numberOfSections: Int { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
}

final class DataProvider: NSObject {
    
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
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(trackerStore: TrackerStoreProtocol,
         trackerCategoryStore: TrackerCategoryStoreProtocol,
         trackerRecordsStore: TrackerRecordStoreProtocol
    ) {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordsStore = trackerRecordsStore
    }
}

extension DataProvider: DataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
}

extension DataProvider: NSFetchedResultsControllerDelegate {
    
}
