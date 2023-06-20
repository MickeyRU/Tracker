//
//  Collection + Extensions.swift
//  Tracker
//
//  Created by Павел Афанасьев on 19.06.2023.
//

import UIKit

extension Collection {
    // Позволяет безопасно гулять по индексам при работе с коллекциями
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
