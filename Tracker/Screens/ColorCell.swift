//
//  ColorCell.swift
//  Tracker
//
//  Created by Павел Афанасьев on 01.07.2023.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addViewsWithNoTAMIC(colorView)
        
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6)
        ])
    }
    
    func configCell(color: UIColor) {
        self.colorView.backgroundColor = color
    }
    
    func didSelectColor(isSelected: Bool) {
        if isSelected {
            self.layer.borderWidth = 3
            self.layer.cornerRadius = 8
            self.layer.borderColor = self.colorView.backgroundColor?.cgColor.copy(alpha: 0.3)
        } else {
            self.layer.borderWidth = 0
        }
    }
}
