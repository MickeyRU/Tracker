//
//  PlaceholderView.swift
//  Tracker
//
//  Created by Павел Афанасьев on 27.06.2023.
//

import UIKit
final class PlaceholderView: UIView {
    private let emptyOnScreenLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let emptyOnScreenImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.emptyOnScreenImage
        return imageView
    }()
    
    init(title: String) {
        self.emptyOnScreenLabel.text  = title
        super.init(frame: .zero)
        
        addViewsWithNoTAMIC(emptyOnScreenLabel)
        addViewsWithNoTAMIC(emptyOnScreenImage)
        
        NSLayoutConstraint.activate([
            emptyOnScreenImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyOnScreenImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            emptyOnScreenLabel.topAnchor.constraint(equalTo: emptyOnScreenImage.bottomAnchor, constant: 8),
            emptyOnScreenLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emptyOnScreenLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
