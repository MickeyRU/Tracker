//
//  CategoriesModel.swift
//  Tracker
//
//  Created by Павел Афанасьев on 31.07.2023.
//

import Foundation

final class CategoriesModel {
    private let categoryStore = TrackerCategoryStore()
    
    func loadCategoriesFromCoreData() -> [Category] {
        return categoryStore.categories.filter { categoryEntity in
            // Проверка на наличие закрепленных трекеров в категории
            if let trackers = categoryEntity.trackers as? Set<TrackerCoreData>, trackers.contains(where: { $0.isPinned }) {
                return false
            }
            return true
        }.map { Category(name: $0.name!, isSelected: false) }
    }

    func addNewCategory(category: TrackerCategory) {
        try? categoryStore.addNewCategory(category)
    }
    
    func setupDelegate(vc: CategoriesListViewModel) {
        self.categoryStore.setDelegate(delegateForStore: vc)
    }
}
