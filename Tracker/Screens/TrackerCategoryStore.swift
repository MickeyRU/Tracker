//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Павел Афанасьев on 13.07.2023.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func categoriesDidUpdate()
}

protocol TrackerCategoryStoreProtocol: AnyObject {
    var categories: [TrackerCategoryCoreData] {
        get
    }
    
    func fetchCategory(name: String) -> TrackerCategoryCoreData?
    func createCategory(category: TrackerCategory) throws -> TrackerCategoryCoreData
    func addNewCategory(_ trackerCategory: TrackerCategory) throws
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    
    override init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func setDelegate(delegateForStore: TrackerCategoryStoreDelegate) {
        delegate = delegateForStore
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {

        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
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
    
    func addNewCategory(_ trackerCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.name = trackerCategory.name
        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.categoriesDidUpdate()
    }
}
