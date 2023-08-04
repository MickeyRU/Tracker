//
//  CategoriesModel.swift
//  Tracker
//
//  Created by Павел Афанасьев on 31.07.2023.
//

import Foundation

final class CategoriesModel {
    private let categoryStore = TrackerCategoryStore()
    
    func saveCategoriesToCoreData(category: Category) {
        // Метод для сохранения данных в Core Data (вызывать метод TrackerCategoryStore)
    }
    
    func loadCategoriesFromCoreData() -> [Category] {
        return categoryStore.categories.compactMap {
            guard
                let name = $0.name
            else { return nil }
            return Category(name: name, isSelected: false)
        }
    }
    
    func addNewCategory(category: TrackerCategory) {
        try? categoryStore.addNewCategory(category)
    }
    
    func setupDelegate(vc: CategoriesListViewModel) {
        self.categoryStore.setDelegate(delegateForStore: vc)
    }
}
