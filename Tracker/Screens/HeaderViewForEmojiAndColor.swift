//
//  HeaderViewForEmojiAndColor.swift
//  Tracker
//
//  Created by Павел Афанасьев on 01.07.2023.
//

import UIKit

final class HeaderViewForEmojiAndColor: UICollectionReusableView {
   private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHeaderView(text: String) {
        self.titleLabel.text = text
    }
    
    private func setupViews() {
        addViewsWithNoTAMIC(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant:  28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
