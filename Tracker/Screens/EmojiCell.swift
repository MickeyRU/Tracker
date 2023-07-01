//
//  EmojiCell.swift
//  Tracker
//
//  Created by Павел Афанасьев on 30.06.2023.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiAndColorCell"
    
    private lazy var emojiTextLabel: UILabel = {
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
            emojiTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiTextLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
    
    func configCell(emoji: String) {
        self.emojiTextLabel.text = emoji
    }
    
    func emojiIsSelected(isSelected: Bool) {
        if isSelected == true {
            self.backgroundColor = UIColor.systemGray5
            self.layer.cornerRadius = 16
        } else {
            self.backgroundColor = UIColor.clear
        }
    }
}
