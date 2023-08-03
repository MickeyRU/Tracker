//
//  NameFieldErrors.swift
//  Tracker
//
//  Created by Павел Афанасьев on 03.08.2023.
//

import Foundation

enum NameFieldErrors: Error {
    case shortString
    
    var localizedDescription: String {
        switch self {
        case .shortString: return "Поле должно содержать не менее 1 символа!"
        }
    }
}
