//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Павел Афанасьев on 13.07.2023.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreProtocol: AnyObject {
    var categories: [TrackerCategoryCoreData] {
        get
    }
    
    func fetchCategory(name: String) -> TrackerCategoryCoreData?
    func createCategory(category: TrackerCategory) throws -> TrackerCategoryCoreData
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    override init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {

        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
}

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    var categories: [TrackerCategoryCoreData] {
        return self.fetchedResultsController.fetchedObjects ?? []
    }
    
    func fetchCategory(name: String) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerCategoryCoreData.name), name)
        
        guard let categories = try? context.fetch(request) else { return nil }
        return categories.first
    }
    
    func createCategory(category: TrackerCategory) throws -> TrackerCategoryCoreData {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.name = category.name
        try context.save()
        return trackerCategoryCoreData
    }
}
