//
//  TrackerOptionsCell.swift
//  Tracker
//
//  Created by Павел Афанасьев on 19.06.2023.
//

import UIKit

final class TrackerOptionsCell: UITableViewCell {
    static let reuseIdentifier = "TrackerOptionsCell"
    
    private let choseButton: UIButton = {
        let button = UIButton()
        button.setImage(Images.choseButtonImage, for: .normal)
        button.addTarget(self, action: #selector(choseButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private var cellNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        
        contentView.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCellNameLabel(nameLabel: String) {
        self.cellNameLabel.text = nameLabel
    }
    
    @objc
    private func choseButtonDidTapped() {
        // ToDo: - Действие после выбора "Категории"
    }
    
    private func setupViews() {
        [choseButton, cellNameLabel].forEach { contentView.addViewsWithNoTAMIC($0) }
        
        NSLayoutConstraint.activate([
            choseButton.widthAnchor.constraint(equalToConstant: 24),
            choseButton.heightAnchor.constraint(equalTo: choseButton.widthAnchor, multiplier: 1),
            choseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            choseButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            cellNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellNameLabel.trailingAnchor.constraint(equalTo: choseButton.leadingAnchor, constant: 1)
        ])
    }
}
