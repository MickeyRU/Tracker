//
//  GenerateColorsHelper.swift
//  Tracker
//
//  Created by Павел Афанасьев on 01.07.2023.
//

import UIKit

final class ColorsHelper {
    static let shared = ColorsHelper()
    
    func GenerateColors() -> [UIColor] {
        var colors = [UIColor]()
        
        for color in 1...18 {
            guard let color = UIColor(named: "\(color)") else {
                print ("Ошибка создания цветов")
                return colors
            }
            colors.append(color)
        }
        return colors
    }
}
