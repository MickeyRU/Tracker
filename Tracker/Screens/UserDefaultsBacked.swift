//
//  UserDefaultsBacked.swift
//  Tracker
//
//  Created by Павел Афанасьев on 31.07.2023.
//

import Foundation

@propertyWrapper
struct UserDefaultsBacked<Value> {
    let key: String
    let storage: UserDefaults = .standard
    
    var wrappedValue: Value? {
        get {
            storage.value(forKey: key) as? Value
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}
