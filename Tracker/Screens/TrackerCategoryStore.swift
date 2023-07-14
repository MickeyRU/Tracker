//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Павел Афанасьев on 13.07.2023.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreProtocol: AnyObject {
    func addCategory(trackerCategory: TrackerCategory) throws -> TrackerCategoryCoreData
    func fetchCategory(by name: String) -> TrackerCategoryCoreData?
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    override init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}

extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func addCategory(trackerCategory: TrackerCategory) throws -> TrackerCategoryCoreData {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.name = trackerCategory.name
        try context.save()
        return trackerCategoryCoreData
    }
    
    func fetchCategory(by name: String) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.name), name)
        
        guard let categories = try? context.fetch(request) else { return nil }
        return categories.first
    }
}
