//
//  CategoriesListViewMod.swift
//  Tracker
//
//  Created by Павел Афанасьев on 31.07.2023.
//

import Foundation

final class CategoriesListViewModel {
    
    ///   ViewModel (Модель представления)
    ///   преобразует данные Model для отображения во View, то есть в пользовательском интерфейсе;
    ///   оповещает View об изменении своего состояния;
    ///   содержит функции, через вызовы которых View может изменять Model;
    ///   НЕ управляет View и ничего не знает о пользовательском интерфейсе.
    
    @Observable
    private(set)var categories: [Category] = []
    
    private let model: CategoriesModel
    
    init(model: CategoriesModel) {
        self.model = model
        model.setupDelegate(vc: self)
    }
    
    func loadCategoriesList() {
        let existedCategories = model.loadCategoriesFromCoreData()
        convertDataToUI(with: existedCategories)
    }
    
    func addNewCategory(category: TrackerCategory) {
        model.addNewCategory(category: category)
    }
    
    func selectCategory(index: Int) {
        categories[index].isSelected = true
    }
    
    private func convertDataToUI(with categories: [Category]?) {
        if let categories = categories {
            for element in categories {
                let category = Category(name: element.name, isSelected: element.isSelected)
                self.categories.append(category)
            }
        }
    }
}

extension CategoriesListViewModel: TrackerCategoryStoreDelegate {
    func categoriesDidUpdate() {
        categories.removeAll()
        loadCategoriesList()
    }
}
