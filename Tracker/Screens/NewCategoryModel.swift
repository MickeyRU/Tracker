//
//  NewCategoryModel.swift
//  Tracker
//
//  Created by Павел Афанасьев on 03.08.2023.
//

import Foundation

final class NewCategoryModel {
    private let requiredLength = 1
    
    func didEnter(nameFieldText: String) -> Result<Bool, Error> {
        do {
            try validate(text: nameFieldText)
        } catch {
            return.failure(error)
        }
        let isSaveNameAllowed = isSaveNameAllowed(for: nameFieldText)
        return.success(isSaveNameAllowed)
    }
    
    private func validate(text: String) throws {
        if text.count < requiredLength {
            throw NameFieldErrors.shortString
        }
    }
    
    private func isSaveNameAllowed(for textFiledText: String) -> Bool {
        textFiledText.count >= requiredLength ? true : false
    }
}
