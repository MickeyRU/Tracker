//
//  CategoryCell.swift
//  Tracker
//
//  Created by Павел Афанасьев on 01.08.2023.
//

import UIKit

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "CategoryCell"
    
    private let selectedImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.selectedImage
        return imageView
    }()
    
    private var cellNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configCell(nameLabel: String) {
        self.cellNameLabel.text = nameLabel
    }
    
    private func setupViews() {
        [cellNameLabel, selectedImage].forEach { contentView.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            cellNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            selectedImage.centerYAnchor.constraint(equalTo: cellNameLabel.centerYAnchor),
            selectedImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}

