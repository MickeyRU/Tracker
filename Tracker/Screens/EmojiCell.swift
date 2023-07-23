//
//  EmojiCell.swift
//  Tracker
//
//  Created by Павел Афанасьев on 30.06.2023.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCell"
    
    private let emojiTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 31)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addViewsWithNoTAMIC(emojiTextLabel)
        
        NSLayoutConstraint.activate([
            emojiTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            emojiTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            emojiTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
            emojiTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func configCell(emoji: String) {
        self.emojiTextLabel.text = emoji
    }
    
    func didSelectEmoji(isSelected: Bool) {
        if isSelected == true {
            self.backgroundColor = UIColor.systemGray5
            self.layer.cornerRadius = 16
        } else {
            self.backgroundColor = UIColor.clear
        }
    }
}
