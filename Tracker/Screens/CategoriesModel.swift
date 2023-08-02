//
//  CategoriesModel.swift
//  Tracker
//
//  Created by Павел Афанасьев on 31.07.2023.
//

import Foundation

final class CategoriesModel {
    
    private let categoryStore = TrackerCategoryStore()
    
    /// Model (Модель):
    /// хранит состояние данных из предметной области приложения, то есть той области человеческой деятельности, для которой мы создаём приложение (доставка цветов, обмен сообщениями и так далее);
    /// обрабатывает их в соответствии с логикой предметной области.
    
    
    func saveCategoriesToCoreData(category: Category) {
        // Метод для сохранения данных в Core Data (вызывать метод TrackerCategoryStore)
    }
    
    func loadCategoriesFromCoreData() -> [TrackerCategory]? {
        // Метод для получения данных из Core Data (вызывать метод TrackerCategoryStore)
        return nil
    }
}
