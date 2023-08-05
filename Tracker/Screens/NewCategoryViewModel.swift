//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by Павел Афанасьев on 03.08.2023.
//

import Foundation

final class NewCategoryViewModel {
    private let model: NewCategoryModel
    
    @Observable
    private(set) var isNameFieldFilled = false
    
    init(model: NewCategoryModel) {
        self.model = model
    }
    
    func checkNameFieldFilled(text: String?) {
        guard let text = text else { return }
        
        let result = model.didEnter(nameFieldText: text)
        
        switch result {
        case .success(let result):
            isNameFieldFilled = result
            
        case .failure(let error):
            isNameFieldFilled = false
            print(error.localizedDescription)
        }
    }
}
