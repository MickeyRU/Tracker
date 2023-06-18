//
//  UIView + Extensions.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

extension UIView {
    func addViewsWithNoTAMIC(_ view: UIView){
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
}

